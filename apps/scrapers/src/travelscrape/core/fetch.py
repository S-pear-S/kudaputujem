"""Siguran HTTP klijent sa SSRF zastitom i rate limitom.

Sve HTTP komunikacije sa scraped sajtovima idu kroz ovaj modul.
Adapteri NE smeju koristiti httpx direktno.
"""

from __future__ import annotations

import asyncio
import ipaddress
import logging
import socket
from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager
from urllib.robotparser import RobotFileParser

import httpx
from tenacity import (
    retry,
    retry_if_exception_type,
    stop_after_attempt,
    wait_exponential,
)
from travelcore.enums import RobotsVerdict

from .settings import Settings
from .settings import settings as default_settings

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

    def raise_min_delay(self, seconds: float) -> None:
        """Podize minimalni zastoj, nikad ga ne snizava.

        `Crawl-delay` iz `robots.txt` ima prednost nad nasim minimumom kad je veci
        (nalaz S1: nikad se nije citao). Sajt koji trazi manje od naseg minimuma
        ne dobija brzi crawl — pravilo 7 u `CLAUDE.md` postavlja 2000 ms kao pod,
        ne kao cilj.
        """
        if seconds > self._min_delay:
            log.info(
                "robots.txt trazi Crawl-delay %.1fs, podizem sa %.1fs",
                seconds,
                self._min_delay,
            )
            self._min_delay = seconds

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
    """Kes `robots.txt` po domenu, fail-closed.

    Nalaz S1 (`instrukcije/noveodluke.md`): stara verzija je upisivala `None` u kes
    kad dohvatanje ne uspe i vracala `True`, status odgovora nije proveravala, i
    `crawl_delay` nikad nije citala. Sve tri stvari su sada obrnute.

    **Standard se postuje tamo gde govori, politika stoji u podatku.** Po RFC 9309
    je 4xx "unavailable" i znaci da skreper **sme** da pristupi, a 5xx je
    "unreachable" i znaci potpunu zabranu. Zato 404 ovde daje
    `ALLOW_NO_ROBOTS`, a ne zabranu: fail-closed na 404 ne cuva nicju izrazenu
    zelju, jer izrazene zelje nema, a kupuje gubitak izvora.

    Stroga odluka nije ukinuta, nego **premestena na mesto gde nosi tezinu**:
    dozvola po `robots.txt`-u nije ukljucenje izvora. Uslovi koriscenja su druga i
    pravno teza provera (`tos_verdict`), i izvor bez razresenih uslova ne radi bez
    obzira na to sta `robots.txt` kaze.

    Fail-closed ostaje za: 5xx, timeout, mreznu gresku, i `robots.txt` koji se
    procita pa zabrani.
    """

    def __init__(self) -> None:
        # Vrednost je parser (robots.txt postoji) ili ALLOW_NO_ROBOTS (404).
        # Sentinel je upisan izricito, a ne kao `None`, da se ne bi citao kao
        # "nesto je poslo naopako" — tacno ta dvosmislenost je bila nalaz S1.
        # 5xx, timeout i mrezna greska se NE kesiraju, jer su prolazni: jedan
        # mrezni problem ne sme da ugasi izvor do kraja procesa.
        self._cache: dict[str, RobotFileParser | RobotsVerdict] = {}

    @staticmethod
    def _base(url: str) -> str:
        parsed = httpx.URL(url)
        return f"{parsed.scheme}://{parsed.host}"

    async def verdict(self, url: str, client: httpx.AsyncClient) -> RobotsVerdict:
        """Ishod provere za TACNU putanju iz `url`, ne za koren domena."""
        base = self._base(url)
        entry = self._cache.get(base)

        if entry is None:
            loaded = await self._load(base, client)
            if loaded is RobotsVerdict.DENY:
                return RobotsVerdict.DENY
            self._cache[base] = loaded
            entry = loaded

        if entry is RobotsVerdict.ALLOW_NO_ROBOTS:
            return RobotsVerdict.ALLOW_NO_ROBOTS

        assert isinstance(entry, RobotFileParser)
        # `can_fetch` prima pun URL, pa se proverava putanja koja se stvarno
        # dohvata — ne koren domena (bivsi preflight je proveravao samo `/`).
        if entry.can_fetch(USER_AGENT, url):
            return RobotsVerdict.ALLOW_EXPLICIT
        return RobotsVerdict.DENY

    async def is_allowed(self, url: str, client: httpx.AsyncClient) -> bool:
        """True ako se sa dobijenim ishodom sme poslati zahtev."""
        return (await self.verdict(url, client)).allows_fetch

    def crawl_delay(self, url: str) -> float | None:
        """`Crawl-delay` koji sajt trazi, ili `None` ako ga ne navodi.

        Vraca `None` i kad `robots.txt` nije (jos) procitan ili ne postoji —
        pozivalac tada ostaje na podrazumevanom minimumu iz podesavanja.
        """
        entry = self._cache.get(self._base(url))
        if not isinstance(entry, RobotFileParser):
            return None
        delay = entry.crawl_delay(USER_AGENT)
        return None if delay is None else float(delay)

    async def _load(
        self, base: str, client: httpx.AsyncClient
    ) -> RobotFileParser | RobotsVerdict:
        """Dohvata `robots.txt`. `DENY` znaci "ne smemo i ne kesiraj"."""
        robots_url = f"{base}/robots.txt"
        try:
            resp = await client.get(robots_url, follow_redirects=True)
        except Exception as exc:
            log.warning(
                "robots.txt nedostupan za %s (%s) — izvor se preskace (fail-closed)", base, exc
            )
            return RobotsVerdict.DENY

        # 404 je odgovor, ne neuspeh: sajt nije izrazio zelju. Telo se NE parsira
        # (stranica greske je cesto HTML koji `RobotFileParser` tiho procita kao
        # "nema pravila"), ali ishod je dozvola po standardu.
        if resp.status_code == httpx.codes.NOT_FOUND:
            log.info("robots.txt ne postoji na %s (404) — ALLOW_NO_ROBOTS", base)
            return RobotsVerdict.ALLOW_NO_ROBOTS

        if resp.status_code != httpx.codes.OK:
            log.warning(
                "robots.txt za %s vratio %s — izvor se preskace (fail-closed)",
                base,
                resp.status_code,
            )
            return RobotsVerdict.DENY

        parser = RobotFileParser()
        parser.parse(resp.text.splitlines())
        log.debug("robots.txt ucitan: %s", robots_url)
        return parser


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
        # `getaddrinfo` vraca tuple[int, bytes] za egzoticne adresne familije
        # (npr. AF_PACKET) — za DNS/IP razresavanje ovde se to nikad ne desava,
        # ali ako se ikad desi, tretiramo isto kao neparsiranu adresu: zabrani.
        if not isinstance(ip, str) or _is_forbidden_ip(ip):
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
        check_robots: bool = True,
        params: dict[str, str] | None = None,
        headers: dict[str, str] | None = None,
    ) -> httpx.Response:
        """GET sa rate limitom, SSRF zastitom i OBAVEZNOM robots.txt proverom.

        `check_robots` je podrazumevano `True` — provera je obaveza fetchera, ne
        opcija pozivaoca (nalaz S1: podrazumevano je bilo `False`, i nijedan od tri
        poziva u adapterima ga nije predavao, pa provera nikad nije radila).

        Jedini slucaj u kom se prosledjuje `False` je dohvatanje samog
        `robots.txt`-a ili recon alat koji svesno gleda sta sajt objavljuje pre
        nego sto izvor uopste postoji — i tada se to upisuje na mestu poziva.
        """
        assert self._client is not None, "HttpFetcher mora biti korisćen kao context manager"

        host = httpx.URL(url).host
        limiter = self._get_limiter(host)

        if check_robots:
            if not await self._robots.is_allowed(url, self._client):
                raise RobotsDisallowedError(f"robots.txt zabranjuje: {url}")
            # `Crawl-delay` sajta ima prednost nad nasim minimumom kad je veci.
            # Cita se posle `is_allowed`, jer je tek tada `robots.txt` u kesu.
            requested = self._robots.crawl_delay(url)
            if requested is not None:
                limiter.raise_min_delay(requested)

        async with limiter.throttle():
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
        params: dict[str, str] | None = None,
        headers: dict[str, str] | None = None,
    ) -> httpx.Response:
        assert self._client is not None
        log.debug("GET %s", url)
        return await self._client.get(url, params=params, headers=headers)
