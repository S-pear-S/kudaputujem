"""Testovi normalizacije. Svaki primer je stvarni oblik viđen na srpskim sajtovima."""

from __future__ import annotations

from datetime import date
from decimal import Decimal

import pytest

from travelscrape.core.enums import BoardType, TransportType
from travelscrape.normalize.board import parse_board
from travelscrape.normalize.dates import parse_date, parse_date_range, parse_duration
from travelscrape.normalize.money import detect_currency, parse_amount, parse_price
from travelscrape.normalize.rooms import parse_child_ages, parse_room_code
from travelscrape.normalize.text import (
    canonical_accommodation_name,
    from_cyrillic,
    normalize,
    slugify,
    strip_stars,
)
from travelscrape.normalize.transport import parse_transport, parse_transport_options

# ---------------------------------------------------------------- text


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("Čačak", "cacak"),
        ("Đerdap", "djerdap"),
        ("Vrnjačka Banja", "vrnjacka banja"),
        ("HOTEL  Porto   Matina", "hotel porto matina"),
        ("Sitonija-Halkidiki", "sitonija halkidiki"),
        ("Београд", "beograd"),
        ("Нови Сад", "novi sad"),
    ],
)
def test_normalize(raw: str, expected: str) -> None:
    assert normalize(raw) == expected


def test_from_cyrillic_keeps_case() -> None:
    assert from_cyrillic("Ниш") == "Nis"


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("Vrnjačka Banja", "vrnjacka-banja"),
        ("Šarm el Šeik", "sarm-el-seik"),
        ("1/2 + 1", "1-2-1"),
    ],
)
def test_slugify(raw: str, expected: str) -> None:
    assert slugify(raw) == expected


@pytest.mark.parametrize(
    ("raw", "name", "stars"),
    [
        ("Hotel Porto Matina 3*", "Hotel Porto Matina", 3.0),
        ("Blue Sea 4*+", "Blue Sea", 4.5),
        ("Sunrise Resort *****", "Sunrise Resort", 5.0),
        ("Vila Marija", "Vila Marija", None),
        ("Apollo Beach 4 zvezdice", "Apollo Beach", 4.0),
    ],
)
def test_strip_stars(raw: str, name: str, stars: float | None) -> None:
    assert strip_stars(raw) == (name, stars)


def test_canonical_accommodation_name_matches_across_sites() -> None:
    a = canonical_accommodation_name("Hotel Porto Matina 3*")
    b = canonical_accommodation_name("PORTO MATINA HOTEL")
    c = canonical_accommodation_name("porto matina")
    assert a == b == c == "porto matina"


# ---------------------------------------------------------------- money


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("1.234,00", Decimal("1234.00")),
        ("1,234.00", Decimal("1234.00")),
        ("1.234", Decimal("1234")),
        ("199", Decimal("199")),
        ("199,50", Decimal("199.50")),
        ("24.500", Decimal("24500")),
        ("1 234,56", Decimal("1234.56")),
    ],
)
def test_parse_amount(raw: str, expected: Decimal) -> None:
    assert parse_amount(raw) == expected


@pytest.mark.parametrize(
    ("raw", "amount", "currency"),
    [
        ("od 199 €", Decimal("199"), "EUR"),
        ("349,00 EUR", Decimal("349.00"), "EUR"),
        ("24.500 din", Decimal("24500"), "RSD"),
        ("1.234,00 EUR", Decimal("1234.00"), "EUR"),
        ("349 - 599 EUR", Decimal("349"), "EUR"),
        ("199,00€", Decimal("199.00"), "EUR"),
    ],
)
def test_parse_price(raw: str, amount: Decimal, currency: str) -> None:
    money = parse_price(raw)
    assert money is not None
    assert money.amount == amount
    assert money.currency == currency


@pytest.mark.parametrize("raw", ["Na upit", "cena na upit", "RASPRODATO", ""])
def test_parse_price_none(raw: str) -> None:
    assert parse_price(raw) is None


def test_parse_price_ignores_year() -> None:
    money = parse_price("Leto 2026 od 349 EUR")
    assert money is not None
    assert money.amount == Decimal("349")


def test_detect_currency_default() -> None:
    assert detect_currency("349") == "EUR"
    assert detect_currency("349 dinara") == "RSD"


# ---------------------------------------------------------------- board


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("polupansion", BoardType.HB),
        ("Polu pansion", BoardType.HB),
        ("PP", BoardType.HB),
        ("HB", BoardType.HB),
        ("pun pansion", BoardType.FB),
        ("PU", BoardType.FB),
        ("noćenje sa doručkom", BoardType.BB),
        ("ND", BoardType.BB),
        ("bed & breakfast", BoardType.BB),
        ("ALL INCLUSIVE", BoardType.AI),
        ("all in", BoardType.AI),
        ("ULTRA ALL INCLUSIVE", BoardType.UAI),
        ("UAI", BoardType.UAI),
        ("najam", BoardType.RO),
        ("bez ishrane", BoardType.RO),
        ("samo smeštaj", BoardType.RO),
        ("", BoardType.NONE),
        ("nešto deseto", BoardType.NONE),
    ],
)
def test_parse_board(raw: str, expected: BoardType) -> None:
    assert parse_board(raw) is expected


def test_uai_wins_over_ai() -> None:
    assert parse_board("Ultra All Inclusive") is BoardType.UAI


# ---------------------------------------------------------------- transport


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("autobusom", TransportType.BUS),
        ("Autobuski prevoz", TransportType.BUS),
        ("avionom", TransportType.PLANE),
        ("čarter let", TransportType.PLANE),
        ("sopstveni prevoz", TransportType.OWN),
        ("svojim prevozom", TransportType.OWN),
        ("bez prevoza", TransportType.OWN),
        ("kombi", TransportType.MINIVAN),
        ("vozom", TransportType.TRAIN),
        ("", TransportType.NONE),
    ],
)
def test_parse_transport(raw: str, expected: TransportType) -> None:
    assert parse_transport(raw) is expected


def test_parse_transport_options_multiple() -> None:
    options = parse_transport_options("autobusom ili sopstvenim prevozom")
    assert set(options) == {TransportType.BUS, TransportType.OWN}


# ---------------------------------------------------------------- rooms


@pytest.mark.parametrize(
    ("raw", "adults", "extra", "is_unit"),
    [
        ("1/1", 1, 0, False),
        ("1/2", 2, 0, False),
        ("1/2+1", 2, 1, False),
        ("1/2 + 2", 2, 2, False),
        ("1/3", 3, 0, False),
        ("1/4", 4, 0, False),
        ("dvokrevetna soba", 2, 0, False),
        ("trokrevetna", 3, 0, False),
        ("A2/4", 2, 2, True),
        ("SU 2/4", 2, 2, True),
        ("apartman 2+2", 2, 2, True),
    ],
)
def test_parse_room_code(raw: str, adults: int, extra: int, is_unit: bool) -> None:
    cap = parse_room_code(raw)
    assert (cap.adults, cap.extra, cap.is_unit) == (adults, extra, is_unit)
    assert cap.confident


def test_parse_room_code_unknown_is_flagged() -> None:
    cap = parse_room_code("soba sa pogledom na more")
    assert not cap.confident
    assert cap.adults == 2


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("dete do 12 godina", (0, 11)),
        ("deca 2-11", (2, 11)),
        ("dete od 2 do 6 godina", (2, 6)),
        ("beba do 2 god", (0, 1)),
        ("odrasla osoba", (None, None)),
    ],
)
def test_parse_child_ages(raw: str, expected: tuple[int | None, int | None]) -> None:
    assert parse_child_ages(raw) == expected


# ---------------------------------------------------------------- dates

REF = date(2026, 5, 1)


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("15.07.2026.", date(2026, 7, 15)),
        ("15.07.2026", date(2026, 7, 15)),
        ("15/07/2026", date(2026, 7, 15)),
        ("2026-07-15", date(2026, 7, 15)),
        ("15. jul 2026.", date(2026, 7, 15)),
        ("15. jul", date(2026, 7, 15)),
        ("15.7.26", date(2026, 7, 15)),
    ],
)
def test_parse_date(raw: str, expected: date) -> None:
    assert parse_date(raw, reference=REF) == expected


def test_parse_date_without_year_rolls_forward() -> None:
    # 15. januar je više od 60 dana pre 1. maja 2026 -> mora biti januar 2027.
    assert parse_date("15. januar", reference=REF) == date(2027, 1, 15)


@pytest.mark.parametrize(
    ("raw", "start", "end"),
    [
        ("10.06. - 17.06.2026.", date(2026, 6, 10), date(2026, 6, 17)),
        ("01.07-08.07.2026", date(2026, 7, 1), date(2026, 7, 8)),
        ("2026-07-01 do 2026-07-08", date(2026, 7, 1), date(2026, 7, 8)),
    ],
)
def test_parse_date_range(raw: str, start: date, end: date) -> None:
    assert parse_date_range(raw, reference=REF) == (start, end)


def test_parse_date_range_over_new_year() -> None:
    result = parse_date_range("28.12. - 04.01.2027.", reference=date(2026, 11, 1))
    assert result == (date(2026, 12, 28), date(2027, 1, 4))


@pytest.mark.parametrize(
    ("raw", "days", "nights"),
    [
        ("10 dana / 7 noćenja", 10, 7),
        ("7 noćenja", 8, 7),
        ("4 dana", 4, 3),
        ("bez podataka", None, None),
    ],
)
def test_parse_duration(raw: str, days: int | None, nights: int | None) -> None:
    assert parse_duration(raw) == (days, nights)
