"""Adapter za soleazur.rs — last minute cenovnik za Grčku.

Izvor:      https://soleazur.rs/lm/display_prices.php
Platforma:  sopstveni PHP CMS
robots.txt: `User-agent: *` / `Disallow:` — potpuno otvoren
Težina:     2/5

Cela ponuda je na jednoj stranici. Javna stranica `/last-minute-grcka` je učitava
u `<iframe>`, ali se taj URL otvara i direktno, bez sesije i bez tokena, pa adapter
radi **jedan GET**.

## Struktura, potvrđena u pravom browseru 16.08.2026.

```
<h2>Neos Marmaras leto 2026</h2>          ← destinacija + godina
<table class="table table-bordered table-sm">
  <thead><tr>
    <th>Objekat</th><th>Soba</th>
    <th>11 dana/10 noci<br>Termin boravka 28.08.-07.09.<br>Sopstveni prevoz/Bus prevoz</th>
    ...jedna <th> po terminu
  </tr></thead>
  <tbody>
    <tr><td rowspan="3"><h6><a>Ridos house</a></h6></td><td>Studio 1/3+1</td><td>/</td>…</tr>
    <tr><td>Mezoneta 1/4</td><td>265€ (x€) / 335€</td>…</tr>   ← BEZ ćelije objekta
```

Dve stvari koje ruše naivni parser:

1. **`rowspan` na imenu objekta.** Redovi posle prvog imaju jednu ćeliju manje.
   Ako se čita `cells[0]` kao objekat, na tim redovima se pročita soba, a kao soba
   se pročita cena. Zato adapter računa pomak po redu, a ne po fiksnom indeksu.

2. **Broj prevoza po koloni nije konstantan.** Halkidiki ima `Sopstveni prevoz/Bus prevoz`
   (dve cene u ćeliji, razdvojene sa `/`), a Kefalonija ima kolone sa samo
   `Avio prevoz` (jedna cena, bez `/`). Broj delova ćelije prati zaglavlje te kolone.

## Format cene

```
209€ (235€) / 275€ (305€)
 │      │      │      └── puna, bus
 │      │      └───────── akcijska, bus
 │      └──────────────── puna, sopstveni
 └─────────────────────── akcijska, sopstveni
```

- `/` kao cela ćelija ili prazna ćelija = nema ponude za taj termin
- `x€` = cena nije objavljena; taj deo se preskače
- `619€ (585€)` = puna cena NIŽA od akcijske. To je greška u podacima na sajtu i
  stvarno se javlja. Ne pretpostavljamo `original > amount`.

## Cena je PO OSOBI

Stranica `/hoteli/<slug>` piše doslovno: `CENA ARANŽMANA PO OSOBI`, uz
`smeštaj 10 noćenja (usluga najam)`. Zato `slot=ADULT`, `PER_PERSON_PER_STAY`,
`board_type=RO`. Ranija pretpostavka da se apartmani plaćaju po jedinici je bila
pogrešna i proverena je na izvoru.

## Zašto jedan offer po prevozu

`departure` ima UNIQUE `(offer_id, start_date, end_date, departure_place_raw)`, a
`transport_type` nije deo tog ključa. Ista soba u istom terminu ima dve cene, za
sopstveni i za bus prevoz. Da se ne bi kršio indeks, agencijska ponuda se deli na
dve naše: `…__own` i `…__bus`. To odgovara i stvarnosti — agencija ih prodaje kao
dva različita aranžmana.
"""

from __future__ import annotations

import re
from collections.abc import AsyncGenerator
from dataclasses import dataclass, field
from datetime import date
from decimal import Decimal, InvalidOperation
from typing import ClassVar

from selectolax.parser import HTMLParser, Node
from travelcore.enums import (
    AccommodationKind,
    BoardType,
    PriceSlot,
    PricingBasis,
    ProductKind,
    TransportType,
)
from travelcore.models import AccommodationIn, DepartureIn, OfferIn, PriceIn
from travelcore.normalize.rooms import parse_room_code
from travelcore.normalize.text import slugify

from travelscrape.core import BaseAdapter, HttpFetcher, register

_BASE = "https://soleazur.rs"
_PRICES_URL = f"{_BASE}/lm/display_prices.php"

_DATE_RANGE = re.compile(r"(\d{1,2})\.(\d{1,2})\.\s*-\s*(\d{1,2})\.(\d{1,2})\.")
_YEAR = re.compile(r"\b(20\d{2})\b")
_NIGHTS = re.compile(r"(\d{1,2})\s*noc", re.IGNORECASE)
_DAYS = re.compile(r"(\d{1,2})\s*dan", re.IGNORECASE)
# "209€", "209 €", "209€ (235€)" — zagrada je opciona
_PRICE = re.compile(
    r"(\d+(?:[.,]\d+)?)\s*€(?:\s*\(\s*(\d+(?:[.,]\d+)?|x)\s*€\s*\))?", re.IGNORECASE
)
_SUFFIX = re.compile(r"\s*(leto|zima|letovanje|zimovanje)\s*\d{4}\s*$", re.IGNORECASE)

# Redosled je bitan: "sopstveni" pre "bus" jer zaglavlje glasi "Sopstveni prevoz/Bus prevoz".
_TRANSPORT_WORDS: tuple[tuple[str, TransportType], ...] = (
    ("sopstven", TransportType.OWN),
    ("bus", TransportType.BUS),
    ("avio", TransportType.PLANE),
    ("voz", TransportType.TRAIN),
)


@dataclass(frozen=True)
class _Period:
    """Jedna kolona cenovnika — jedan termin."""

    start_date: date
    end_date: date
    nights: int
    transports: tuple[TransportType, ...]


@dataclass
class _Price:
    transport: TransportType
    amount: Decimal
    original: Decimal | None


@dataclass
class _Room:
    raw: str
    code: str
    adults: int
    extra: int
    #: indeks u listi perioda -> cene za taj period
    prices: dict[int, list[_Price]] = field(default_factory=dict)


@dataclass
class _Object:
    """Jedan smeštajni objekat sa svim svojim sobama."""

    name: str
    rooms: list[_Room] = field(default_factory=list)


# ---------------------------------------------------------------------------
# Parsiranje zaglavlja
# ---------------------------------------------------------------------------


def _transports(text: str) -> tuple[TransportType, ...]:
    lowered = text.lower()
    found = [kind for word, kind in _TRANSPORT_WORDS if word in lowered]
    return tuple(found) or (TransportType.OWN,)


def _period_from_header(text: str, year: int) -> _Period | None:
    """`11 dana/10 noci Termin boravka 28.08.-07.09. Sopstveni prevoz/Bus prevoz`."""
    match = _DATE_RANGE.search(text)
    if not match:
        return None

    day_from, month_from, day_to, month_to = (int(g) for g in match.groups())
    year_to = year if month_to >= month_from else year + 1
    try:
        start = date(year, month_from, day_from)
        end = date(year_to, month_to, day_to)
    except ValueError:
        return None

    nights_match = _NIGHTS.search(text)
    if nights_match:
        nights = int(nights_match.group(1))
    else:
        days_match = _DAYS.search(text)
        nights = int(days_match.group(1)) - 1 if days_match else (end - start).days

    return _Period(start, end, nights, _transports(text))


def _parse_header(table: Node, year: int) -> list[_Period]:
    row = table.css_first("thead tr") or table.css_first("tr")
    if row is None:
        return []
    # Prve dve kolone su uvek "Objekat" i "Soba".
    cells = row.css("th, td")[2:]
    periods = [_period_from_header(_cell_text(cell), year) for cell in cells]
    return [p for p in periods if p is not None]


# ---------------------------------------------------------------------------
# Parsiranje cena
# ---------------------------------------------------------------------------


def _to_decimal(raw: str | None) -> Decimal | None:
    if not raw or raw.lower() == "x":
        return None
    try:
        return Decimal(raw.replace(",", "."))
    except InvalidOperation:
        return None


def _parse_price_cell(text: str, period: _Period) -> list[_Price]:
    """Razlaže ćeliju na cene, po jedna za svaki prevoz iz zaglavlja kolone."""
    text = text.strip()
    if not text or text == "/":
        return []

    # Delimo na "/" jer u cenovnoj ćeliji nema oznaka soba tipa "1/2".
    # Broj delova prati zaglavlje: dva prevoza -> dva dela, jedan prevoz -> jedan.
    parts = [p.strip() for p in text.split("/")]
    out: list[_Price] = []

    # strict=False je namerno: ćelija sme imati manje delova nego što zaglavlje
    # najavljuje (npr. '265€ (x€) / 335€' gde drugi deo nema zagradu).
    for part, transport in zip(parts, period.transports, strict=False):
        if not part:
            continue
        match = _PRICE.search(part)
        if not match:
            continue
        amount = _to_decimal(match.group(1))
        if amount is None or amount <= 0:
            continue
        out.append(_Price(transport, amount, _to_decimal(match.group(2))))

    return out


# ---------------------------------------------------------------------------
# Parsiranje tela tabele
# ---------------------------------------------------------------------------


def _cell_text(cell: Node) -> str:
    """Tekst ćelije sa razmakom umesto `<br>`, bez višestrukih razmaka."""
    return " ".join(cell.text(separator=" ", strip=True).split())


def _object_name(cell: Node) -> str:
    heading = cell.css_first("h6")
    return _cell_text(heading) if heading is not None else _cell_text(cell)


def _parse_body(table: Node, periods: list[_Period]) -> list[_Object]:
    """Grupiše redove po objektu, poštujući `rowspan` na prvoj ćeliji.

    Ključ: broj ćelija u redu kaže da li red počinje imenom objekta.
    Pun red ima `2 + len(periods)` ćelija, nastavak ima jednu manje.
    """
    rows = table.css("tbody tr") or table.css("tr")[1:]
    expected_full = 2 + len(periods)

    objects: list[_Object] = []
    current: _Object | None = None

    for row in rows:
        cells = row.css("td, th")
        if not cells:
            continue

        starts_object = len(cells) >= expected_full
        if starts_object:
            name = _object_name(cells[0])
            if not name:
                continue
            current = _Object(name=name)
            objects.append(current)
            room_cell, price_cells = cells[1], cells[2:]
        else:
            if current is None:
                # Tabela počinje nastavkom — podaci su neupotrebljivi, preskačemo.
                continue
            room_cell, price_cells = cells[0], cells[1:]

        room_raw = _cell_text(room_cell)
        if not room_raw:
            continue

        capacity = parse_room_code(room_raw)
        room = _Room(
            raw=room_raw,
            code=_room_code(room_raw, capacity.adults, capacity.extra),
            adults=capacity.adults,
            extra=capacity.extra,
        )

        for index, period in enumerate(periods):
            if index >= len(price_cells):
                break
            prices = _parse_price_cell(_cell_text(price_cells[index]), period)
            if prices:
                room.prices[index] = prices

        if room.prices:
            current.rooms.append(room)

    return [obj for obj in objects if obj.rooms]


def _room_code(raw: str, adults: int, extra: int) -> str:
    """`Studio 1/3+1 dvoriste D1 i D2` -> `1/3+1`."""
    match = re.search(r"\d\s*/\s*\d(?:\s*\+\s*\d)?", raw)
    if match:
        return match.group(0).replace(" ", "")
    return f"1/{adults}" + (f"+{extra}" if extra else "")


# ---------------------------------------------------------------------------
# Sklapanje ponuda
# ---------------------------------------------------------------------------


def _kind(name: str) -> AccommodationKind:
    lowered = name.lower()
    if "hotel" in lowered:
        return AccommodationKind.HOTEL
    if "vila" in lowered or "villa" in lowered:
        return AccommodationKind.VILLA
    if "mezoneta" in lowered or "apartman" in lowered or "studio" in lowered:
        return AccommodationKind.APARTMENT
    return AccommodationKind.OTHER


_TRANSPORT_SUFFIX = {
    TransportType.OWN: "own",
    TransportType.BUS: "bus",
    TransportType.PLANE: "avio",
    TransportType.TRAIN: "voz",
}

_TRANSPORT_LABEL = {
    TransportType.OWN: "sopstveni prevoz",
    TransportType.BUS: "bus",
    TransportType.PLANE: "avion",
    TransportType.TRAIN: "voz",
}


def _build_offers(obj: _Object, periods: list[_Period], destination: str) -> list[OfferIn]:
    """Jedan objekat -> po jedna ponuda za svaki tip prevoza koji se u njemu javlja."""
    # transport -> {indeks perioda -> [(soba, cena)]}
    grouped: dict[TransportType, dict[int, list[tuple[_Room, _Price]]]] = {}
    for room in obj.rooms:
        for index, prices in room.prices.items():
            for price in prices:
                grouped.setdefault(price.transport, {}).setdefault(index, []).append((room, price))

    offers: list[OfferIn] = []
    base_slug = slugify(f"{destination}-{obj.name}")

    for transport, by_period in grouped.items():
        departures: list[DepartureIn] = []

        for index, pairs in sorted(by_period.items()):
            period = periods[index]
            departures.append(
                DepartureIn(
                    external_id=f"{period.start_date:%Y%m%d}-{_TRANSPORT_SUFFIX[transport]}",
                    start_date=period.start_date,
                    end_date=period.end_date,
                    nights=period.nights,
                    transport_type=transport,
                    board_type=BoardType.RO,
                    is_last_minute=True,
                    prices=[
                        PriceIn(
                            room_code=room.code,
                            room_name=room.raw,
                            capacity_adults=room.adults,
                            capacity_extra=room.extra,
                            slot=PriceSlot.ADULT,
                            pricing_basis=PricingBasis.PER_PERSON_PER_STAY,
                            board_type=BoardType.RO,
                            amount=price.amount,
                            original_amount=price.original,
                            # Popust postoji samo ako je puna cena zaista veća.
                            # Na sajtu se javlja i obrnut slučaj, npr. 619€ (585€).
                            is_promo=price.original is not None and price.original > price.amount,
                            currency="EUR",
                        )
                        for room, price in pairs
                    ],
                )
            )

        if not departures:
            continue

        offers.append(
            OfferIn(
                source_slug=SoleAzurAdapter.source_slug,
                external_id=f"{base_slug}__{_TRANSPORT_SUFFIX[transport]}",
                product_kind=ProductKind.PACKAGE,
                title=f"{obj.name}, {destination} — {_TRANSPORT_LABEL[transport]}",
                url=_PRICES_URL,
                country_raw="Grčka",
                destination_raw=destination,
                transport_type=transport,
                board_type=BoardType.RO,
                currency="EUR",
                accommodation=AccommodationIn(
                    name=obj.name,
                    kind=_kind(obj.name),
                    destination_raw=destination,
                    external_id=slugify(obj.name),
                ),
                departures=departures,
                raw_attributes={"last_minute": True, "cenovnik": "lm/display_prices.php"},
            )
        )

    return offers


def parse_price_page(html: str, default_year: int = 2026) -> list[OfferIn]:
    """Parsira ceo `/lm/display_prices.php`. Koriste je i adapter i testovi."""
    tree = HTMLParser(html)
    offers: list[OfferIn] = []

    # Redosled dokumenta je OBAVEZAN — naslov destinacije važi za tabelu koja
    # ga sledi. `css("h2, table")` NE vraća redosled dokumenta nego prvo sve h2
    # pa sve table, pa bi svaka tabela dobila poslednju destinaciju.
    # `traverse()` obilazi stablo u redosledu dokumenta.
    destination = "Grčka"
    year = default_year

    for node in tree.root.traverse(include_text=False):
        if node.tag not in ("h2", "table"):
            continue
        if node.tag == "h2":
            text = _cell_text(node)
            match = _YEAR.search(text)
            if match:
                year = int(match.group(1))
            name = _SUFFIX.sub("", text).strip()
            if name:
                destination = name
            continue

        periods = _parse_header(node, year)
        if not periods:
            continue
        for obj in _parse_body(node, periods):
            offers.extend(_build_offers(obj, periods, destination))

    return offers


@register
class SoleAzurAdapter(BaseAdapter):
    """Jedan GET na `/lm/display_prices.php` daje ceo katalog. Bez paginacije."""

    source_slug: ClassVar[str] = "soleazur-grcka"
    allowed_domains: ClassVar[set[str]] = {"soleazur.rs", "www.soleazur.rs"}
    expected_min_items: ClassVar[int] = 20

    async def scrape(self, fetcher: HttpFetcher) -> AsyncGenerator[OfferIn, None]:
        resp = await fetcher.get(_PRICES_URL)
        for offer in parse_price_page(resp.text):
            yield offer
