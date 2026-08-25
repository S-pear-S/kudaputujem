"""Adapter za oktopod.rs — apartmani/hoteli u Grčkoj, cloudhosting.rs platforma.

Izvor jedne ponude: `https://www.oktopod.rs/sr/putovanje/<slug>/<id>`
Platforma:  deljeni hosting `vs<broj>.cloudhosting.rs`, generator tabela `CSSTableGenerator`
Težina:     4/5

## Struktura, potvrđena u pravom browseru 16.08.2026. (fixture iz DOM-a)

Stranica hotela ima **po jednu `<table class="CSSTableGenerator">` za svaku dužinu
boravka** (u fixture-u: 10 i 7 noći). Obe tabele su istog oblika:

```
red 0   <td colspan=N> naslov paketa — nosi tip prevoza ("...autobuski prevoz")
red 1   <td rowspan=3>Struktura</td> <td rowspan=3>Broj pomoćnih ležaja</td>
        <td rowspan=3>Broj plativih osoba</td> <td colspan=M>PERIOD BORAVKA / BROJ NOĆENJA</td>
red 2   broj noćenja po periodu (M ćelija, obično sve iste)
red 3   datumi perioda, oblik "20.05. 30.05." — dva datuma, BEZ crtice između
red 4+  struktura, pomoćni ležaji, plative osobe, pa cena po periodu (M ćelija)
```

Dve tabele na stranici NISU dva prevoza nego dve DUŽINE boravka. I dalje se grupišu
po prevozu (ne pretpostavljamo da su uvek iste) da se izbegne isti problem kao kod
soleazur adaptera: `departure` ima UNIQUE `(offer_id, start_date, end_date,
departure_place_raw)`, pa dve tabele sa istim terminom i različitim prevozom moraju
dati dva različita offer-a. U ovom fixture-u obe tabele su `BUS`.

## `Broj plativih osoba`, ne izvedeni kapacitet

Za `1/3+1 STD` piše `4` — sva četiri gosta plaćaju PUNU cenu iz ćelije, bez popusta
za pomoćni ležaj. To je suprotno od onoga što `parse_room_code()` pretpostavlja
(hotelska notacija `1/N+K` obično znači da je `K` pomoćni ležaj sa drugom cenom).
Zato se `capacity_adults` uzima direktno iz kolone „Broj plativih osoba", a ne iz
oznake sobe. Oznaka sobe (`room_code`) se i dalje čita iz teksta, samo za prikaz.

## Format cene

`170*`, `200`, `-` — broj je cena po plativoj osobi za ceo boravak. `-` znači da ta
soba u tom terminu nema ponudu. `*` iza cene znači uslovan period (fusnota na
stranici, van fixture-a) — cena se svejedno uzima, samo se beleži u `notes`.
`1/2 STD RENOV*` — tu je zvezdica deo IMENA strukture, ne cene.

## Valuta — POTVRĐENO

Cenovnik ne piše simbol valute (za razliku od soleazur `€`), ali u zaglavlju sajta
stoji kurs `1€ = 117.34 RSD` — sve cene u cenovnim tabelama su EUR. Ne konvertovati.

## Doplata za klimu

Detalj stranica ima stavku van cenovne tabele: `AC - uz doplatu na licu mesta od
6€ dnevno`. To je `SurchargeIn`, ne deo cene aranžmana: `payable=ON_SITE`,
`currency=EUR`, `amount=6`. Nema fixture sa ovim delom DOM-a još — parsira se
generičkim pretraživanjem teksta cele stranice po frazi, ne po selektoru.

## discover() ide preko sitemap-a — POTVRĐENO

`https://www.oktopod.rs/sitemap.xml` postoji: 1427 `<loc>` unosa, od kojih 1093
oblika `/sr/putovanje/<slug>/<id>` — to je ceo katalog. Broj na kraju kategorijskih
URL-ova (`/sr/grcka-apartmani/4`) je ID kategorije, ne paginacija — nema strane 2,
pa se te URL-ove ne dira. `discover()` čita sitemap i filtrira po `/sr/putovanje/`
obrascu; nema generičke ekstrakcije linkova sa listing stranica.
"""

from __future__ import annotations

import re
from collections.abc import AsyncGenerator
from dataclasses import dataclass
from datetime import date
from decimal import Decimal, InvalidOperation
from typing import ClassVar

from selectolax.parser import HTMLParser, Node
from travelcore.enums import (
    AccommodationKind,
    BoardType,
    Payable,
    PriceSlot,
    PricingBasis,
    ProductKind,
    SurchargeCode,
    SurchargeKind,
    SurchargeUnit,
    TransportType,
)
from travelcore.models import AccommodationIn, DepartureIn, OfferIn, PriceIn, SurchargeIn
from travelcore.normalize.dates import parse_date_range
from travelcore.normalize.text import slugify

from travelscrape.core import BaseAdapter, HttpFetcher, register

_BASE = "https://www.oktopod.rs"
_SITEMAP_URL = f"{_BASE}/sitemap.xml"
_LOC_RE = re.compile(r"<loc>\s*([^<\s]+)\s*</loc>", re.IGNORECASE)
_DETAIL_PATH_RE = re.compile(r"/sr/putovanje/[^/\"'#?]+/\d+/?$")

_PRICE = re.compile(r"(\d+(?:[.,]\d+)?)\s*(\*)?")
_ID_FROM_URL = re.compile(r"/sr/putovanje/([^/]+)/(\d+)")
_AC_SURCHARGE = re.compile(
    r"\bAC\b[^\n\d€]{0,40}?(\d+(?:[.,]\d+)?)\s*€\s*dnevno", re.IGNORECASE
)

_TRANSPORT_WORDS: tuple[tuple[str, TransportType], ...] = (
    ("avio", TransportType.PLANE),
    ("sopstven", TransportType.OWN),
    ("autobus", TransportType.BUS),
    ("bus", TransportType.BUS),
)


@dataclass(frozen=True)
class _Period:
    start_date: date
    end_date: date
    nights: int


@dataclass
class _RoomPrice:
    room_raw: str
    room_code: str
    capacity_adults: int
    aux_beds: int
    amount: Decimal
    conditional: bool


# ---------------------------------------------------------------------------
# Naslov i identitet objekta
# ---------------------------------------------------------------------------


def _cell_text(node: Node) -> str:
    return " ".join(node.text(separator=" ", strip=True).split())


def _parse_title(html_title: str) -> tuple[str, str] | None:
    """`VILA PENNY / HANIOTI — Oktopod Travel` -> `("VILA PENNY", "HANIOTI")`."""
    head = html_title.split("—")[0].split("-")[0] if "—" in html_title else html_title
    if "/" not in head:
        return None
    name, _, destination = head.partition("/")
    name, destination = name.strip(), destination.strip()
    return (name, destination) if name and destination else None


def _kind(name: str) -> AccommodationKind:
    lowered = name.lower()
    if "vila" in lowered or "villa" in lowered:
        return AccommodationKind.VILLA
    if "apartman" in lowered or "studio" in lowered:
        return AccommodationKind.APARTMENT
    if "hotel" in lowered:
        return AccommodationKind.HOTEL
    return AccommodationKind.OTHER


def _external_id_from_url(url: str) -> str | None:
    match = _ID_FROM_URL.search(url)
    return match.group(2) if match else None


def _transport_from_title(text: str) -> TransportType:
    lowered = text.lower()
    for word, kind in _TRANSPORT_WORDS:
        if word in lowered:
            return kind
    # Nijedna reč prevoza nije prepoznata — na dosad viđenim stranicama je uvek
    # bio autobus, pa je to bezbednija pretpostavka od TransportType.NONE.
    return TransportType.BUS


def _extract_ac_surcharge(page_text: str) -> SurchargeIn | None:
    """`AC - uz doplatu na licu mesta od 6€ dnevno` -> doplata za klimu.

    Nema fixture sa ovim delom DOM-a, pa se traži po tekstu cele stranice
    (frazi), ne po selektoru — bezbednije nego pogađati tag/klasu bez dokaza.
    """
    match = _AC_SURCHARGE.search(page_text)
    if not match:
        return None
    try:
        amount = Decimal(match.group(1).replace(",", "."))
    except InvalidOperation:
        return None
    return SurchargeIn(
        code=SurchargeCode.OTHER,
        name="Klima uređaj (AC)",
        kind=SurchargeKind.OPTIONAL,
        unit=SurchargeUnit.PER_UNIT_PER_NIGHT,
        amount=amount,
        currency="EUR",
        payable=Payable.ON_SITE,
        raw_text=match.group(0),
    )


# ---------------------------------------------------------------------------
# Parsiranje jedne CSSTableGenerator tabele
# ---------------------------------------------------------------------------


def _parse_periods(header_row: Node, dates_row: Node, reference: date) -> list[_Period | None]:
    nights_cells = [_cell_text(c) for c in header_row.css("td, th")]
    date_cells = [_cell_text(c) for c in dates_row.css("td, th")]

    periods: list[_Period | None] = []
    # Index-based, ne zip(): broj kolona prati ceo red, pa dve liste treba da
    # budu iste dužine po konstrukciji, ali se ovako izbegava i ruff B905
    # (zip bez strict=) i strict= kwarg koji ne postoji pre Python 3.10.
    for i in range(min(len(nights_cells), len(date_cells))):
        nights_text, date_text = nights_cells[i], date_cells[i]
        date_range = parse_date_range(date_text, reference=reference)
        if date_range is None or not nights_text.strip().isdigit():
            periods.append(None)
            continue
        start, end = date_range
        periods.append(_Period(start_date=start, end_date=end, nights=int(nights_text.strip())))
    return periods


def _room_code(raw: str) -> str:
    """`1/2 STD` -> `1/2-std`, `1/2 STD RENOV*` -> `1/2-std-renov`.

    Samo brojčani razlomak NIJE dovoljan kod: `1/2 STD` i `1/2 STD RENOV*` imaju
    istu kapacitetsku oznaku ali su različiti tipovi sobe sa različitom cenom —
    da su oba svedena na `1/2`, dve `price_option` bi delile `room_code` unutar
    istog termina i tiho izgubile razliku (nema UNIQUE ograničenje da to spreči).
    """
    text = raw.strip()
    match = re.search(r"\d\s*/\s*\d(?:\s*\+\s*\d)?", text)
    if not match:
        return slugify(text, max_length=20)

    fraction = match.group(0).replace(" ", "")
    suffix = (text[: match.start()] + text[match.end() :]).rstrip("*").strip()
    suffix_slug = slugify(suffix, max_length=30) if suffix else ""
    return f"{fraction}-{suffix_slug}" if suffix_slug else fraction


def _parse_price_cell(text: str) -> tuple[Decimal, bool] | None:
    text = text.strip()
    if not text or text == "-":
        return None
    match = _PRICE.match(text)
    if not match:
        return None
    try:
        amount = Decimal(match.group(1).replace(",", "."))
    except InvalidOperation:
        return None
    if amount <= 0:
        return None
    return (amount, bool(match.group(2)))


def _parse_int(text: str) -> int | None:
    text = text.strip()
    if not text or text == "-":
        return 0 if text == "-" else None
    return int(text) if text.isdigit() else None


def _parse_table(
    table: Node, reference: date
) -> tuple[TransportType, list[_Period | None], list[list[_RoomPrice | None]]]:
    """Vraća (prevoz, periodi, red-po-red cene) za jednu `CSSTableGenerator` tabelu."""
    rows = table.css("tr")
    if len(rows) < 4:
        return (TransportType.BUS, [], [])

    title = _cell_text(rows[0])
    transport = _transport_from_title(title)
    periods = _parse_periods(rows[2], rows[3], reference)

    room_rows: list[list[_RoomPrice | None]] = []
    for row in rows[4:]:
        cells = row.css("td, th")
        if len(cells) < 3:
            continue
        room_raw = _cell_text(cells[0])
        if not room_raw:
            continue
        aux_beds = _parse_int(_cell_text(cells[1])) or 0
        payable = _parse_int(_cell_text(cells[2]))
        if payable is None:
            # Bez pouzdanog broja plativih osoba ne izmišljamo kapacitet.
            continue

        code = _room_code(room_raw)
        price_cells = cells[3:]

        row_prices: list[_RoomPrice | None] = []
        for index in range(len(periods)):
            if index >= len(price_cells):
                row_prices.append(None)
                continue
            parsed = _parse_price_cell(_cell_text(price_cells[index]))
            if parsed is None:
                row_prices.append(None)
                continue
            amount, conditional = parsed
            row_prices.append(
                _RoomPrice(
                    room_raw=room_raw,
                    room_code=code,
                    capacity_adults=payable,
                    aux_beds=aux_beds,
                    amount=amount,
                    conditional=conditional,
                )
            )
        room_rows.append(row_prices)

    return (transport, periods, room_rows)


# ---------------------------------------------------------------------------
# Sklapanje ponude
# ---------------------------------------------------------------------------

_TRANSPORT_SUFFIX = {
    TransportType.BUS: "bus",
    TransportType.OWN: "own",
    TransportType.PLANE: "avio",
    TransportType.TRAIN: "voz",
    TransportType.FERRY: "trajekt",
    TransportType.MINIVAN: "minibus",
}

_TRANSPORT_LABEL = {
    TransportType.BUS: "autobus",
    TransportType.OWN: "sopstveni prevoz",
    TransportType.PLANE: "avion",
    TransportType.TRAIN: "voz",
    TransportType.FERRY: "trajekt",
    TransportType.MINIVAN: "minibus",
}


def parse_hotel_page(html: str, url: str, reference: date | None = None) -> list[OfferIn]:
    """Parsira jednu `/sr/putovanje/<slug>/<id>` stranicu. Koriste je adapter i testovi.

    `reference` je datum u odnosu na koji se pogađa godina termina bez godine u
    tekstu (isto pravilo kao `normalize.dates.parse_date_range`). Adapter ga
    ostavlja na `date.today()`; testovi ga fiksiraju da fixture bude stabilan.
    """
    reference = reference or date.today()
    tree = HTMLParser(html)
    title_node = tree.css_first("title")
    parsed_title = _parse_title(_cell_text(title_node)) if title_node else None
    if parsed_title is None:
        return []
    name, destination = parsed_title

    external_id = _external_id_from_url(url) or slugify(f"{destination}-{name}")

    # transport -> lista (period, [_RoomPrice])
    by_transport: dict[TransportType, list[tuple[_Period, list[_RoomPrice]]]] = {}
    seen_keys: dict[TransportType, set[tuple[date, date]]] = {}

    for table in tree.css("table.CSSTableGenerator"):
        transport, periods, room_rows = _parse_table(table, reference)
        for index, period in enumerate(periods):
            if period is None:
                continue
            prices = [
                cell
                for row in room_rows
                if index < len(row) and (cell := row[index]) is not None
            ]
            if not prices:
                continue
            key = (period.start_date, period.end_date)
            seen = seen_keys.setdefault(transport, set())
            if key in seen:
                # Isti termin se već pojavio za ovaj prevoz (druga tabela) — UNIQUE
                # (offer_id, start_date, end_date, departure_place_raw) bi pukao.
                continue
            seen.add(key)
            by_transport.setdefault(transport, []).append((period, prices))

    if not by_transport:
        return []

    ac_surcharge = _extract_ac_surcharge(tree.body.text(separator=" ") if tree.body else "")
    surcharges = [ac_surcharge] if ac_surcharge else []

    offers: list[OfferIn] = []
    for transport, entries in by_transport.items():
        departures = [
            DepartureIn(
                external_id=f"{period.start_date:%Y%m%d}-{period.nights}n",
                start_date=period.start_date,
                end_date=period.end_date,
                nights=period.nights,
                transport_type=transport,
                board_type=BoardType.RO,
                prices=[
                    PriceIn(
                        room_code=p.room_code,
                        room_name=p.room_raw,
                        # capacity_adults ovde NIJE "koliko odraslih staje u
                        # osnovne ležaje" (kako ga OccupancySolver inače čita) —
                        # to je oktopodov "Broj plativih osoba", koliko osoba
                        # SE NAPLAĆUJE. Za oktopod je cena po plativoj osobi ista
                        # bez obzira na koji ležaj gost spava, pa se ova dva
                        # pojma slučajno poklapaju: capacity_extra=0, sve osobe
                        # u "osnovnom" ležaju, solver pomnoži cenu sa tim brojem
                        # i dobije isti rezultat kao oktopodov obračun. Prvi
                        # izvor koji upiše STVARAN broj osnovnih ležaja i pravu
                        # decu na pomoćnim daje DRUGAČIJU logiku za istu kolonu —
                        # vidi CLAUDE.md §7 Faza B, "capacity_adults/_extra/_total
                        # nemaju zajedničko značenje preko izvora" i integracioni
                        # test test_oktopod_solver_integration.py (poruka 12).
                        capacity_adults=p.capacity_adults,
                        capacity_extra=0,
                        slot=PriceSlot.ADULT,
                        pricing_basis=PricingBasis.PER_PERSON_PER_STAY,
                        board_type=BoardType.RO,
                        amount=p.amount,
                        currency="EUR",
                        notes=(
                            f"pomoćni ležaji: {p.aux_beds}"
                            + (", uslovan period" if p.conditional else "")
                        ),
                    )
                    for p in prices
                ],
            )
            for period, prices in entries
        ]

        suffix = _TRANSPORT_SUFFIX.get(transport, transport.value.lower())
        offers.append(
            OfferIn(
                source_slug=OktopodAdapter.source_slug,
                external_id=f"{external_id}__{suffix}",
                product_kind=ProductKind.PACKAGE,
                title=f"{name}, {destination} — {_TRANSPORT_LABEL.get(transport, transport.value)}",
                url=url,
                country_raw="Grčka",
                destination_raw=destination,
                transport_type=transport,
                board_type=BoardType.RO,
                currency="EUR",
                accommodation=AccommodationIn(
                    name=name,
                    kind=_kind(name),
                    destination_raw=destination,
                    external_id=slugify(name),
                ),
                departures=departures,
                surcharges=surcharges,
                raw_attributes={"cenovnik": "CSSTableGenerator"},
            )
        )

    return offers


def detail_urls_from_sitemap(xml_text: str) -> list[str]:
    """Filtrira `sitemap.xml` na `/sr/putovanje/<slug>/<id>` unose. Koriste je adapter i testovi.

    Potvrđeno 16.08.2026: 1427 `<loc>` unosa ukupno, 1093 oblika `/sr/putovanje/...` —
    to je ceo katalog, nema potrebe za dodatnom paginacijom ili listing stranicama.
    """
    seen: dict[str, None] = {}
    for match in _LOC_RE.finditer(xml_text):
        loc = match.group(1).strip()
        if _DETAIL_PATH_RE.search(loc):
            seen.setdefault(loc, None)
    return list(seen)


@register
class OktopodAdapter(BaseAdapter):
    """cloudhosting.rs multi-tenant, jedna stranica po hotelu, više dužina boravka."""

    source_slug: ClassVar[str] = "oktopod-grcka"
    allowed_domains: ClassVar[set[str]] = {"oktopod.rs", "www.oktopod.rs"}

    async def scrape(self, fetcher: HttpFetcher) -> AsyncGenerator[OfferIn, None]:
        sitemap_resp = await fetcher.get(_SITEMAP_URL)
        detail_urls = detail_urls_from_sitemap(sitemap_resp.text)

        for url in detail_urls:
            resp = await fetcher.get(url)
            for offer in parse_hotel_page(resp.text, url):
                yield offer
