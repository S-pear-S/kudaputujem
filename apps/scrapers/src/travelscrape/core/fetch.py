"""Siguran HTTP klijent sa SSRF zastitom i rate limitom.

Sve HTTP komunikacije sa scraped sajtovima idu kroz ovaj modul.
Adapteri NE smeju koristiti httpx direktno.
"""

from __future__ import annotations

import asyncio
import ipaddress
import logging
import socket
from contextlib import asynccontextmanager
from typing import AsyncGenerator
from urllib.robotparser import RobotFileParser

import httpx
from tenacity import (
    retry,
    retry_if_exception_type,
    stop_after_attempt,
    wait_exponential,
)

from .settings import Settings, settings as default_settings

log = logging.getLogger(__name__)

USER_AGENT = (
    "KudaPutujemBot/0.1 (+https://kudaputujem.rs/bot; kontakt@kudaputujem.rs)"
)


# ---------------------------------------------------------------------------
# Greske
# ---------------------------------------------------------------------------


class FetchError(RuntimeError):
    """Bazna klasa za greske fetchera."""


class SsrfError(FetchError):
    """URL je odbijen zbog SSRF zastite."""


class RobotsDisallowedError(FetchError):
    """robots.txt zabranjuje scrapovanje ovog URL-a."""


class RateLimitedError(FetchError):
    """Server vratio 429 Too Many Requests."""


# ---------------------------------------------------------------------------
# Rate limiter po domenu
# ---------------------------------------------------------------------------


class _DomainLimiter:
    """Enforces min delay and max concurrent requests per domain."""

    def __init__(self, min_delay: float, max_concurrent: int) -> None:
        self._min_delay = min_delay
        self._sem = asyncio.Semaphore(max_concurrent)
        self._next_allowed: float = 0.0
        self._lock = asyncio.Lock()

    @asynccontextmanager
    async def throttle(self) -> AsyncGenerator[None, None]:
        # Cekamo slobodan slot za delay
        async with self._lock:
            now = asyncio.get_event_loop().time()
            wait = self._next_allowed - now
            if wait > 0:
                await asyncio.sleep(wait)
            self._next_allowed = asyncio.get_event_loop().time() + self._min_delay

        # Cekamo slobodan concurrency slot
        async with self._sem:
            yield


# ---------------------------------------------------------------------------
# Robots.txt kesh
# ---------------------------------------------------------------------------


class _RobotsCache:
    def __init__(self) -> None:
        self._cache: dict[str, RobotFileParser | None] = {}

    async def is_allowed(self, url: str, client: httpx.AsyncClient) -> bool:
        """True ako robots.txt dozvoljava scrapovanje url-a."""
        parsed = httpx.URL(url)
        base = f"{parsed.scheme}://{parsed.host}"
        if base not in self._cache:
            robots_url = f"{base}/robots.txt"
            try:
                resp = await client.get(robots_url, follow_redirects=True)
                parser = RobotFileParser()
                parser.parse(resp.text.splitlines())
                self._cache[base] = parser
                log.debug("robots.txt ucitan: %s", robots_url)
            except Exception as exc:
                log.debug("robots.txt nije dostupan za %s: %s", base, exc)
                self._cache[base] = None

        parser = self._cache[base]
        return parser is None or parser.can_fetch(USER_AGENT, url)


# ---------------------------------------------------------------------------
# SSRF zastita
# ---------------------------------------------------------------------------

def _is_forbidden_ip(ip_str: str) -> bool:
    """True ako je IP adresa privatna, loopback, link-local ili slicno."""
    try:
        addr = ipaddress.ip_address(ip_str)
    except ValueError:
        return True
    return (
        addr.is_private
        or addr.is_loopback
        or addr.is_link_local
        or addr.is_multicast
        or addr.is_unspecified
    )


def _validate_ssrf(host: str, allowed_domains: set[str] | None) -> None:
    """Baca SsrfError ako je host u zabranjenom opsegu ili izvan allowliste."""
    if allowed_domains is not None and host not in allowed_domains:
        raise SsrfError(
            f"Domen {host!r} nije u allowlistu za ovaj izvor. "
            f"Dozvoljeni: {sorted(allowed_domains)}"
        )
    try:
        infos = socket.getaddrinfo(host, None)
    except socket.gaierror as exc:
        raise SsrfError(f"Ne mogu razresiti {host!r}: {exc}") from exc
    for info in infos:
        ip = info[4][0]
        if _is_forbidden_ip(ip):
            raise SsrfError(
                f"IP {ip!r} za {host!r} je u zabranjenom opsegu (SSRF zastita)"
            )


# ---------------------------------------------------------------------------
# Glavni fetcher
# ---------------------------------------------------------------------------


class HttpFetcher:
    """Bezbedan async HTTP klijent za adaptere.

    Parametri:
        allowed_domains: Skup dozvoljenih domena za ovaj izvor.
                         None znaci "dozvoli sve" — koristi se samo za recon.
        settings: Konfiguracija; koristi se globalna instanca ako nije data.
    """

    def __init__(
        self,
        allowed_domains: set[str] | None,
        settings: Settings | None = None,
    ) -> None:
        self._allowed = allowed_domains
        self._cfg = settings or default_settings
        self._limiters: dict[str, _DomainLimiter] = {}
        self._robots = _RobotsCache()
        self._client: httpx.AsyncClient | None = None

    # -- context manager -------------------------------------------------------

    async def __aenter__(self) -> HttpFetcher:
        self._client = httpx.AsyncClient(
            headers={"User-Agent": USER_AGENT},
            follow_redirects=True,
            timeout=self._cfg.request_timeout_s,
            verify=True,
            event_hooks={"request": [self._on_request]},
        )
        return self

    async def __aexit__(self, *args: object) -> None:
        if self._client:
            await self._client.aclose()

    # -- javni API -------------------------------------------------------------

    async def get(
        self,
        url: str,
        *,
        check_robots: bool = False,
        params: dict | None = None,
        headers: dict | None = None,
    ) -> httpx.Response:
        """GET sa rate limitom, SSRF zastitom i opcionom robots.txt proverom."""
        assert self._client is not None, "HttpFetcher mora biti korisćen kao context manager"

        host = httpx.URL(url).host
        limiter = self._get_limiter(host)

        async with limiter.throttle():
            if check_robots:
                if not await self._robots.is_allowed(url, self._client):
                    raise RobotsDisallowedError(f"robots.txt zabranjuje: {url}")

            resp = await self._do_get(url, params=params, headers=headers)
            if resp.status_code == 429:
                raise RateLimitedError(f"429 Too Many Requests: {url}")
            resp.raise_for_status()
            return resp

    async def check_robots(self, base_url: str) -> bool:
        """Vraca True ako robots.txt dozvoljava scrapovanje base_url-a."""
        assert self._client is not None
        return await self._robots.is_allowed(base_url, self._client)

    # -- interni pomocnici -----------------------------------------------------

    async def _on_request(self, request: httpx.Request) -> None:
        """httpx event hook — poziva se pre svakog zahteva, uklj. preusmeravanje."""
        _validate_ssrf(request.url.host, self._allowed)

    def _get_limiter(self, host: str) -> _DomainLimiter:
        if host not in self._limiters:
            self._limiters[host] = _DomainLimiter(
                min_delay=self._cfg.min_request_delay_s,
                max_concurrent=self._cfg.max_concurrent_per_domain,
            )
        return self._limiters[host]

    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=2, max=10),
        retry=retry_if_exception_type((httpx.TimeoutException, httpx.NetworkError)),
        reraise=True,
    )
    async def _do_get(
        self,
        url: str,
        params: dict | None = None,
        headers: dict | None = None,
    ) -> httpx.Response:
        assert self._client is not None
        log.debug("GET %s", url)
        return await self._client.get(url, params=params, headers=headers)
