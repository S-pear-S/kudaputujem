"""Adapter za soleazur.rs.

Izvor: /lm/display_prices.php — jedna PHP stranica sa svim last-minute cenama
Platforma: sopstveni PHP CMS
robots.txt: potpuno otvoren (Disallow: prazno)
Težina: 2/5

Strategija: jedan GET na /lm/display_prices.php daje sve ponude.
HTML tabele su grupisane po destinaciji (h2/h3 naslov + <table>).
Format cene u ćeliji: "209€ (235€) / 275€ (305€)"
  → 209€ LM cena sopstvenim prevozom, (235€) regularna
  → 275€ LM cena busom, (305€) regularna

VERIFIKUJ LOKALNO pre prve produkcijske runde:
- Tačne tagove za naslove sekcija (h2? h3? div.section-title?)
- Da li thead ima jedan ili dva reda zaglavlja
- Redosled kolona Objekat/Soba (da li su spojene u jedan td?)
- Format "/" za nedostupnost vs decimalni separator
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from datetime import date
from decimal import Decimal, InvalidOperation
from typing import AsyncGenerator

from selectolax.parser import HTMLParser, Node

from travelscrape.core import BaseAdapter, HttpFetcher, register
from travelscrape.core.enums import (
    AccommodationKind,
    BoardType,
    PriceSlot,
    PricingBasis,
    ProductKind,
    TransportType,
)
from travelscrape.core.models import (
    AccommodationIn,
    DepartureIn,
    OfferIn,
    PriceIn,
)

_BASE = "https://soleazur.rs"
_PRICES_URL = f"{_BASE}/lm/display_prices.php"

# Regex za parsiranje
_DATE_PAT = re.compile(r"(\d{1,2})\.(\d{1,2})\.")
_YEAR_PAT = re.compile(r"\b(20\d{2})\b")
_PRICE_PAT = re.compile(r"(\d+)\s*€(?:\s*\((\d+)\s*€\))?")
_ROOM_CAP_PAT = re.compile(r"1/(\d+)(?:\+(\d+))?")
_NIGHTS_PAT = re.compile(r"(\d+)\s*(?:d(?:ana)?|noć)", re.IGNORECASE)


# ---------------------------------------------------------------------------
# Interne strukture parsiranja
# ---------------------------------------------------------------------------


@dataclass
class _PeriodCol:
    start_date: date
    end_date: date
    nights: int
    transports: list[TransportType]


@dataclass
class _PriceEntry:
    transport: TransportType
    amount: Decimal
    original_amount: Decimal | None
    is_promo: bool


@dataclass
class _RoomRow:
    room_text: str
    room_code: str
    adults: int
    extra: int
    prices_per_col: list[list[_PriceEntry]]  # indeks odgovara _PeriodCol listi


# ---------------------------------------------------------------------------
# Parsiranje
# ---------------------------------------------------------------------------


def _transports_from_header(text: str) -> list[TransportType]:
    """'Sopstveni/Bus' → [OWN, BUS], 'Avio' → [PLANE], itd."""
    lower = text.lower()
    result: list[TransportType] = []
    if "sopstveni" in lower:
        result.append(TransportType.OWN)
    if "bus" in lower:
        result.append(TransportType.BUS)
    if "avio" in lower:
        result.append(TransportType.PLANE)
    return result or [TransportType.OWN]


def _dates_from_header(text: str, year: int) -> tuple[date, date] | None:
    """'28.08.-07.09.' + year → (date(year,8,28), date(year,9,7))."""
    found = _DATE_PAT.findall(text)
    if len(found) < 2:
        return None
    try:
        d1, m1 = int(found[0][0]), int(found[0][1])
        d2, m2 = int(found[1][0]), int(found[1][1])
        # Prelaz godine: aug→sep je OK, dec→jan treba +1
        y1 = year
        y2 = year if m2 >= m1 else year + 1
        return date(y1, m1, d1), date(y2, m2, d2)
    except ValueError:
        return None


def _parse_price_cell(text: str, col: _PeriodCol) -> list[_PriceEntry]:
    """Parsira tekst ćelije i vraća listu cena po tipu prevoza.

    Format: "209€ (235€) / 275€ (305€)"
    "/" deli tipove prevoza u redosledu col.transports.
    "(X€)" je regularna cena, prva je last-minute.
    Ako ćelija sadrži samo "/" ili je prazna, ponuda nije dostupna.
    """
    text = text.strip()
    # Ćelija "/" ili prazna = nedostupno
    if not text or text == "/" or text.lower() == "x":
        return []

    # Delimo po " / " (sa razmacima) da ne bismo razbili "1/2" u sifri sobe
    parts = re.split(r"\s+/\s+", text)

    entries: list[_PriceEntry] = []
    for i, (part, transport) in enumerate(zip(parts, col.transports)):
        part = part.strip()
        if not part or part == "/" or "x€" in part.lower():
            continue
        m = _PRICE_PAT.search(part)
        if not m:
            continue
        try:
            lm_price = Decimal(m.group(1))
            reg_price = Decimal(m.group(2)) if m.group(2) else None
        except InvalidOperation:
            continue
        if lm_price <= 0:
            continue
        entries.append(_PriceEntry(
            transport=transport,
            amount=lm_price,
            original_amount=reg_price,
            is_promo=reg_price is not None,
        ))

    return entries


def _parse_room(room_text: str) -> tuple[str, int, int]:
    """'Studio 1/3+1 dvorište' → ('1/3+1', adults=3, extra=1)."""
    m = _ROOM_CAP_PAT.search(room_text)
    if m:
        adults = int(m.group(1))
        extra = int(m.group(2) or 0)
        room_code = f"1/{adults}" + (f"+{extra}" if extra else "")
        return room_code, adults, extra
    # Nema standardne šifre (npr. "Superior" soba u hotelu)
    return room_text[:20].strip(), 2, 0


def _accommodation_kind(obj_name: str) -> AccommodationKind:
    lower = obj_name.lower()
    if "hotel" in lower:
        return AccommodationKind.HOTEL
    if "vila" in lower or "villa" in lower:
        return AccommodationKind.VILLA
    return AccommodationKind.APARTMENT


def _safe_slug(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_")


# ---------------------------------------------------------------------------
# Parsiranje stranice
# ---------------------------------------------------------------------------


def parse_price_page(html: str, default_year: int = 2026) -> list[OfferIn]:
    """Parsira /lm/display_prices.php i vraća sve ponude.

    Koristi se i u adapteru i u unit testovima.
    """
    tree = HTMLParser(html)
    offers: list[OfferIn] = []

    # VERIFIKUJ LOKALNO: koji tag nosi naslov destinacije (h2, h3, strong, ...)?
    # Pretpostavljamo da svaka sekcija počinje h2 ili h3 sa imenom destinacije i godinom.
    # Sekcija je praćena <table> koji sledi neposredno.
    #
    # Prolazimo sve elemente po redu i pratimo kontekst.

    current_dest = "Grčka"
    current_year = default_year

    # Gradimo mapu: tražimo sve h2/h3 i sve table u DOM redosledu.
    # selectolax daje elemente u document-order pa iteriramo body.
    body = tree.css_first("body") or tree.root

    for node in body.iter():
        tag = node.tag if hasattr(node, "tag") else ""

        # Naslov sekcije — detektujemo destinaciju i godinu
        if tag in ("h2", "h3", "h4"):
            text = node.text(strip=True)
            m_year = _YEAR_PAT.search(text)
            if m_year:
                current_year = int(m_year.group(1))
            # Čistimo "leto YYYY" i slično da dobijemo samo ime destinacije
            dest = re.sub(r"\s*(leto|zima|letovanje|zimovanje)\s*\d{4}", "", text, flags=re.IGNORECASE).strip()
            if dest:
                current_dest = dest

        # Tabela cena
        if tag != "table":
            continue

        period_cols = _parse_header(node, current_year)
        if not period_cols:
            continue

        object_rows = _parse_body(node, period_cols)
        if not object_rows:
            continue

        for obj_name, rows in object_rows.items():
            _build_offer(
                obj_name=obj_name,
                rows=rows,
                period_cols=period_cols,
                destination=current_dest,
                offers=offers,
            )

    return offers


def _parse_header(table: Node, year: int) -> list[_PeriodCol]:
    """Izvlači kolone perioda iz <thead> ili prvog <tr>."""
    # VERIFIKUJ LOKALNO: thead vs tbody, colspan tretman
    header_row = table.css_first("thead tr") or table.css_first("tr")
    if not header_row:
        return []

    cells = header_row.css("th, td")
    # Prve 2 kolone su "Objekat" i "Soba"
    period_cols: list[_PeriodCol] = []
    for cell in cells[2:]:
        text = cell.text(strip=True)
        if not text:
            continue
        dates = _dates_from_header(text, year)
        if not dates:
            continue
        start_dt, end_dt = dates

        # Broj noći iz zaglavlja ili iz razlike datuma
        m = _NIGHTS_PAT.search(text)
        nights = int(m.group(1)) - 1 if m else (end_dt - start_dt).days

        transports = _transports_from_header(text)
        period_cols.append(_PeriodCol(
            start_date=start_dt,
            end_date=end_dt,
            nights=nights,
            transports=transports,
        ))

    return period_cols


def _parse_body(
    table: Node, period_cols: list[_PeriodCol]
) -> dict[str, list[_RoomRow]]:
    """Grupisanje redova po imenu objekta."""
    result: dict[str, list[_RoomRow]] = {}
    current_obj: str | None = None

    body_rows = table.css("tbody tr") or table.css("tr")[1:]

    for tr in body_rows:
        cells = tr.css("td, th")
        if len(cells) < 3:
            continue

        obj_text = cells[0].text(strip=True)
        room_text = cells[1].text(strip=True)

        if obj_text:
            current_obj = obj_text
        if not current_obj or not room_text:
            continue

        prices_per_col: list[list[_PriceEntry]] = []
        for i, col in enumerate(period_cols):
            cell_idx = i + 2
            if cell_idx >= len(cells):
                prices_per_col.append([])
                continue
            cell_text = cells[cell_idx].text(strip=True)
            prices_per_col.append(_parse_price_cell(cell_text, col))

        room_code, adults, extra = _parse_room(room_text)
        row = _RoomRow(
            room_text=room_text,
            room_code=room_code,
            adults=adults,
            extra=extra,
            prices_per_col=prices_per_col,
        )

        if current_obj not in result:
            result[current_obj] = []
        result[current_obj].append(row)

    return result


def _build_offer(
    obj_name: str,
    rows: list[_RoomRow],
    period_cols: list[_PeriodCol],
    destination: str,
    offers: list[OfferIn],
) -> None:
    """Gradi OfferIn i dodaje u listu."""
    departures: list[DepartureIn] = []

    for row in rows:
        for col_idx, (col, price_entries) in enumerate(zip(period_cols, row.prices_per_col)):
            if not price_entries:
                continue
            for entry in price_entries:
                dep_ext_id = (
                    f"soleazur_{_safe_slug(obj_name)}"
                    f"_{col.start_date.strftime('%Y%m%d')}"
                    f"_{entry.transport.value}"
                )
                price = PriceIn(
                    room_code=row.room_code,
                    room_name=row.room_text,
                    capacity_adults=row.adults,
                    capacity_extra=row.extra,
                    slot=PriceSlot.ADULT,
                    pricing_basis=PricingBasis.PER_PERSON_PER_STAY,
                    amount=entry.amount,
                    original_amount=entry.original_amount,
                    is_promo=entry.is_promo,
                    min_stay_nights=col.nights,
                )
                dep = DepartureIn(
                    external_id=dep_ext_id,
                    start_date=col.start_date,
                    end_date=col.end_date,
                    nights=col.nights,
                    transport_type=entry.transport,
                    is_last_minute=True,
                    prices=[price],
                )
                departures.append(dep)

    if not departures:
        return

    ext_id = f"soleazur_{_safe_slug(destination)}_{_safe_slug(obj_name)}"

    offer = OfferIn(
        source_slug="soleazur-grcka",
        external_id=ext_id,
        product_kind=ProductKind.PACKAGE,
        title=f"{obj_name} — {destination}",
        url=_PRICES_URL,
        country_raw="Grčka",
        destination_raw=destination,
        accommodation=AccommodationIn(
            name=obj_name,
            kind=_accommodation_kind(obj_name),
            destination_raw=destination,
            external_id=ext_id,
        ),
        departures=departures,
    )
    offers.append(offer)


# ---------------------------------------------------------------------------
# Adapter
# ---------------------------------------------------------------------------


@register
class SoleAzurAdapter(BaseAdapter):
    """Adapter za soleazur.rs — last-minute ponude za Grčku.

    Jedan GET na /lm/display_prices.php daje sve ponude.
    Bez paginacije. Crawl runda = jedna stranica.
    """

    source_slug = "soleazur-grcka"
    allowed_domains = {"soleazur.rs", "www.soleazur.rs"}

    async def scrape(self, fetcher: HttpFetcher) -> AsyncGenerator[OfferIn, None]:
        html = await fetcher.get(_PRICES_URL)
        offers = parse_price_page(html)
        for offer in offers:
            yield offer
