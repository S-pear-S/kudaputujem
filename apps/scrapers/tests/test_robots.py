"""Testovi za poštovanje `robots.txt` — nalaz S1 iz `instrukcije/noveodluke.md`.

Pravilo 7 u `CLAUDE.md` tvrdi da se `robots.txt` poštuje i da `Disallow` znači da se
izvor ne uključuje. Provera je bila ugrađena ali praktično ugašena, na pet načina:

1. `HttpFetcher.get` je imao `check_robots: bool = False`, a nijedan od tri poziva u
   adapterima ga nije predavao — dakle nijedan stvarni zahtev nije prošao proveru.
2. Kad `robots.txt` nije dohvaćen, u keš je išlo `None`, a `is_allowed` je vraćalo
   `True` — nedostupan `robots.txt` je značio "dozvoljeno".
3. Status odgovora se nije proveravao, pa se telo stranice greške (404/500, često
   HTML) parsiralo kao da su pravila. Ishod se sada razlikuje po statusu: 404 je
   `ALLOW_NO_ROBOTS` (po RFC 9309 "unavailable" znači da skreper sme), a 5xx,
   timeout i mrežna greška su `DENY`. Telo se ni u jednom od tih slučajeva ne
   parsira.
4. Preflight u `pipeline.py` je gradio `https://{domain}/` i proveravao samo putanju
   `/`, pa je `Disallow: /lm/` prolazio.
5. `crawl_delay` iz `robots.txt` se nikad nije čitao — koristio se fiksni
   `min_request_delay_s` iz podešavanja bez obzira na to što sajt traži više.

Svi testovi ispod su pisani PRE ispravke i provereno je da padaju na starom kodu —
vidi `instrukcije/noveodluke.md`, odeljak "Faza 0". Bez mreže: `httpx.AsyncClient` je
zamenjen lažnim objektom koji vraća unaprijed zadat `robots.txt`.
"""

from __future__ import annotations

from typing import Any

import httpx
import pytest
from travelcore.enums import RobotsVerdict

from travelscrape.core.fetch import (
    USER_AGENT,
    HttpFetcher,
    RobotsDisallowedError,
    _RobotsCache,
)

# ---------------------------------------------------------------------------
# Lažni klijent — vraća zadat robots.txt bez mreže
# ---------------------------------------------------------------------------


class _FakeClient:
    """Minimalni zamenik `httpx.AsyncClient` za `_RobotsCache`."""

    def __init__(
        self,
        body: str = "",
        status_code: int = 200,
        raises: Exception | None = None,
    ) -> None:
        self._body = body
        self._status = status_code
        self._raises = raises
        self.calls: list[str] = []

    async def get(self, url: str, **kwargs: Any) -> httpx.Response:
        self.calls.append(url)
        if self._raises is not None:
            raise self._raises
        return httpx.Response(
            status_code=self._status,
            text=self._body,
            request=httpx.Request("GET", url),
        )


_ROBOTS_BLOKIRA_LM = """\
User-agent: *
Disallow: /lm/
Crawl-delay: 10
"""

_ROBOTS_DOZVOLJAVA_SVE = """\
User-agent: *
Allow: /
"""


# ---------------------------------------------------------------------------
# 1. Nedostupan robots.txt znači ODBIJ, ne "dozvoljeno"
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_nedostupan_robots_se_odbija() -> None:
    """Mrežna greška pri dohvatanju `robots.txt` mora da znači zabranu.

    Stari kod je upisivao `None` u keš i vraćao `True` (`parser is None or ...`),
    dakle sajt koji je privremeno nedostupan postajao je "dozvoljen".
    """
    cache = _RobotsCache()
    client = _FakeClient(raises=httpx.ConnectError("nema mreže"))

    allowed = await cache.is_allowed("https://primer.rs/stranica", client)  # type: ignore[arg-type]

    assert allowed is False


@pytest.mark.asyncio
async def test_nedostupan_robots_se_ne_kesira_kao_trajna_zabrana() -> None:
    """Neuspeh se ne pamti kao odluka — sledeći poziv pokušava ponovo.

    Da se keširalo, jedan prolazni mrežni problem bi ugasio izvor do kraja procesa.
    """
    cache = _RobotsCache()
    pao = _FakeClient(raises=httpx.ConnectError("nema mreže"))
    assert await cache.is_allowed("https://primer.rs/a", pao) is False  # type: ignore[arg-type]

    radi = _FakeClient(body=_ROBOTS_DOZVOLJAVA_SVE)
    assert await cache.is_allowed("https://primer.rs/a", radi) is True  # type: ignore[arg-type]
    assert radi.calls == ["https://primer.rs/robots.txt"]


# ---------------------------------------------------------------------------
# 2. Status odgovora se proverava, i 404 se razlikuje od 5xx
#
# IZMENA SPECIFIKACIJE, ne popravka testa (nije Z55). Prva verzija ovog fajla je
# tvrdila da 404 znači zabranu. Vlasnik je odlučio drugačije
# (`instrukcije/noveodluke2.md`, odeljak 1): po RFC 9309 je 4xx "unavailable" i
# znači da skreper SME, a 5xx je "unreachable" i znači zabranu. Fail-closed na 404
# ne čuva ničiju izraženu želju, jer izražene želje nema, a kupuje gubitak izvora.
# Stroga odluka se premešta na `tos_verdict`, gde nosi pravnu težinu.
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_404_dozvoljava_ali_ne_parsira_telo() -> None:
    """404 daje `ALLOW_NO_ROBOTS`, i telo odgovora se pri tom ne čita.

    Telo namerno sadrži tekst koji `RobotFileParser` čita kao "sve dozvoljeno",
    da se vidi razlika između "pravila kažu da smem" (`ALLOW_EXPLICIT`) i
    "pravila ne postoje" (`ALLOW_NO_ROBOTS`). Oba puštaju zahtev, ali nisu isti
    dokazni položaj.
    """
    cache = _RobotsCache()
    client = _FakeClient(body=_ROBOTS_DOZVOLJAVA_SVE, status_code=404)

    verdict = await cache.verdict("https://primer.rs/stranica", client)  # type: ignore[arg-type]

    assert verdict is RobotsVerdict.ALLOW_NO_ROBOTS
    assert verdict.allows_fetch is True
    # Telo nije parsirano, pa `crawl_delay` ne postoji ni ako ga telo navodi.
    assert cache.crawl_delay("https://primer.rs/stranica") is None


@pytest.mark.asyncio
async def test_404_se_kesira_jer_je_odgovor_a_ne_neuspeh() -> None:
    """Jedan zahtev za `robots.txt` po domenu, ne po stranici."""
    cache = _RobotsCache()
    client = _FakeClient(status_code=404)

    await cache.verdict("https://primer.rs/a", client)  # type: ignore[arg-type]
    await cache.verdict("https://primer.rs/b", client)  # type: ignore[arg-type]

    assert client.calls == ["https://primer.rs/robots.txt"]


@pytest.mark.asyncio
async def test_status_500_je_zabrana() -> None:
    """5xx je "unreachable" po RFC 9309 — potpuna zabrana, i telo se ne čita."""
    cache = _RobotsCache()
    client = _FakeClient(body=_ROBOTS_DOZVOLJAVA_SVE, status_code=500)

    assert await cache.verdict("https://primer.rs/x", client) is RobotsVerdict.DENY  # type: ignore[arg-type]


@pytest.mark.asyncio
async def test_status_403_je_zabrana() -> None:
    """403 nije 404: sajt je odgovorio, i odgovor nije "nema pravila"."""
    cache = _RobotsCache()
    client = _FakeClient(status_code=403)

    assert await cache.verdict("https://primer.rs/x", client) is RobotsVerdict.DENY  # type: ignore[arg-type]


# ---------------------------------------------------------------------------
# 2b. Verdikt razlikuje dva različita dokazna položaja
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_izricita_dozvola_se_razlikuje_od_odsustva_pravila() -> None:
    """`ALLOW_EXPLICIT` i `ALLOW_NO_ROBOTS` oba puštaju, ali nisu isto.

    Razlika nije kozmetička: ako se ikad odluči "uzimamo samo izvore koji
    izričito dozvoljavaju", sa ovom razlikom je to upit, a bez nje je ponovno
    dohvatanje svih izvora.
    """
    cache = _RobotsCache()
    postoji = _FakeClient(body=_ROBOTS_DOZVOLJAVA_SVE)
    assert await cache.verdict("https://ima.rs/x", postoji) is RobotsVerdict.ALLOW_EXPLICIT  # type: ignore[arg-type]

    nema = _FakeClient(status_code=404)
    assert await cache.verdict("https://nema.rs/x", nema) is RobotsVerdict.ALLOW_NO_ROBOTS  # type: ignore[arg-type]


@pytest.mark.asyncio
async def test_unknown_ne_dozvoljava() -> None:
    """Odsustvo provere nije dokaz da smemo — `UNKNOWN` ne pušta zahtev."""
    assert RobotsVerdict.UNKNOWN.allows_fetch is False
    assert RobotsVerdict.DENY.allows_fetch is False


# ---------------------------------------------------------------------------
# 3. Proverava se TAČNA putanja, ne samo koren
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_disallow_podputanje_blokira_tacnu_putanju() -> None:
    """`Disallow: /lm/` mora da blokira `/lm/display_prices.php`.

    Ovo je stvarni slučaj: soleazur adapter dohvata baš `/lm/display_prices.php`,
    a preflight je proveravao samo `https://soleazur.rs/`.
    """
    cache = _RobotsCache()
    client = _FakeClient(body=_ROBOTS_BLOKIRA_LM)

    assert await cache.is_allowed("https://primer.rs/lm/display_prices.php", client) is False  # type: ignore[arg-type]


@pytest.mark.asyncio
async def test_koren_prolazi_dok_je_podputanja_blokirana() -> None:
    """Isti `robots.txt`: koren je dozvoljen, pa provera korena ne otkriva zabranu.

    Ovaj test je razlog zbog kog preflight nije bio dovoljan — oba poziva idu na
    isti sajt i daju različit odgovor.
    """
    cache = _RobotsCache()
    client = _FakeClient(body=_ROBOTS_BLOKIRA_LM)

    assert await cache.is_allowed("https://primer.rs/", client) is True  # type: ignore[arg-type]
    assert await cache.is_allowed("https://primer.rs/lm/x.php", client) is False  # type: ignore[arg-type]


# ---------------------------------------------------------------------------
# 4. crawl_delay iz robots.txt se čita i ima prednost kad je veći
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_crawl_delay_se_cita_iz_robots() -> None:
    """`Crawl-delay: 10` mora da se pročita, jer sajt traži više od našeg minimuma."""
    cache = _RobotsCache()
    client = _FakeClient(body=_ROBOTS_BLOKIRA_LM)
    await cache.is_allowed("https://primer.rs/", client)  # type: ignore[arg-type]

    assert cache.crawl_delay("https://primer.rs/") == pytest.approx(10.0)


@pytest.mark.asyncio
async def test_crawl_delay_je_none_kad_ga_robots_ne_navodi() -> None:
    cache = _RobotsCache()
    client = _FakeClient(body=_ROBOTS_DOZVOLJAVA_SVE)
    await cache.is_allowed("https://primer.rs/", client)  # type: ignore[arg-type]

    assert cache.crawl_delay("https://primer.rs/") is None


# ---------------------------------------------------------------------------
# 5. HttpFetcher.get proverava robots PODRAZUMEVANO, bez argumenta pozivaoca
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_podrazumevano_proverava_robots(monkeypatch: pytest.MonkeyPatch) -> None:
    """`get(url)` bez ikakvog argumenta mora da digne grešku kad robots zabranjuje.

    Ovo je srž nalaza S1: provera je postojala ali je bila opcija pozivaoca sa
    podrazumevanim `False`, pa je nijedan adapter nije koristio.
    """
    fetcher = HttpFetcher(allowed_domains=None)

    async def nikad(*args: object, **kwargs: object) -> httpx.Response:
        raise AssertionError("zahtev ne sme da bude poslat kad robots zabranjuje")

    async def zabranjeno(url: str, client: object) -> bool:
        return False

    monkeypatch.setattr(fetcher._robots, "is_allowed", zabranjeno)
    monkeypatch.setattr(fetcher, "_do_get", nikad)

    async with fetcher:
        with pytest.raises(RobotsDisallowedError):
            await fetcher.get("https://primer.rs/lm/display_prices.php")


@pytest.mark.asyncio
async def test_get_prolazi_kad_robots_dozvoljava(monkeypatch: pytest.MonkeyPatch) -> None:
    """Dozvoljeno ostaje dozvoljeno — ispravka ne sme da ugasi ispravan slučaj."""
    fetcher = HttpFetcher(allowed_domains=None)

    async def ok(url: str, **kwargs: object) -> httpx.Response:
        return httpx.Response(200, text="<html/>", request=httpx.Request("GET", url))

    async def dozvoljeno(url: str, client: object) -> bool:
        return True

    monkeypatch.setattr(fetcher._robots, "is_allowed", dozvoljeno)
    monkeypatch.setattr(fetcher, "_do_get", ok)

    async with fetcher:
        resp = await fetcher.get("https://primer.rs/stranica")

    assert resp.status_code == 200


@pytest.mark.asyncio
async def test_user_agent_je_nas_bot() -> None:
    """`robots.txt` se čita za naše ime, ne za `*` — pravilo 7 traži jasan UA."""
    assert "KudaPutujemBot" in USER_AGENT
    assert "kudaputujem.rs/bot" in USER_AGENT
