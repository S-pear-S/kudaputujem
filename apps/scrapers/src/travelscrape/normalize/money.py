"""Parsiranje cena sa srpskih sajtova.

Zamke koje smo videli u praksi:
    "1.234,00 EUR"   srpski format: tačka = hiljade, zarez = decimala
    "1,234.00 EUR"   engleski format na istom sajtu (kad je tema uvezena)
    "od 199 €"       prefiks "od"
    "199,00€"        bez razmaka
    "24.500 din"     dinari bez decimala
    "349 - 599 EUR"  opseg; uzimamo minimum i vraćamo oba
    "Na upit"        nema cene
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from decimal import Decimal, InvalidOperation

CURRENCY_SYMBOLS = {
    "€": "EUR",
    "eur": "EUR",
    "euro": "EUR",
    "evra": "EUR",
    "evro": "EUR",
    "e": "EUR",
    "rsd": "RSD",
    "din": "RSD",
    "dinara": "RSD",
    "din.": "RSD",
    "дин": "RSD",
    "$": "USD",
    "usd": "USD",
    "£": "GBP",
    "gbp": "GBP",
    "chf": "CHF",
    "hrk": "HRK",
    "bam": "BAM",
    "km": "BAM",
}

_NO_PRICE = re.compile(
    r"\b(na upit|upit|po dogovoru|nema cene|rasprodato|popunjeno|sold ?out)\b",
    re.IGNORECASE,
)

_NUMBER_RE = re.compile(r"\d[\d\s., ']*\d|\d")


@dataclass(frozen=True)
class Money:
    amount: Decimal
    currency: str

    def __str__(self) -> str:
        return f"{self.amount} {self.currency}"


class PriceParseError(ValueError):
    pass


def detect_currency(text: str, default: str = "EUR") -> str:
    lowered = text.lower()
    # Duži kodovi prvi, da "eur" ne pogodi pre "euro".
    for token in sorted(CURRENCY_SYMBOLS, key=len, reverse=True):
        if token in lowered:
            return CURRENCY_SYMBOLS[token]
    return default


def parse_amount(raw: str) -> Decimal:
    """Pretvara jedan broj iz teksta u Decimal, sam pogađa separatore.

    Pravilo: poslednji separator je decimalni AKO iza njega ima tačno 1 ili 2 cifre
    I ima još separatora ispred ili je vodeći deo kraći od 4 cifre. Inače je hiljadni.
    """
    text = raw.strip().replace("\xa0", "").replace(" ", "").replace("'", "")
    if not text:
        raise PriceParseError(f"prazan broj: {raw!r}")

    last_dot = text.rfind(".")
    last_comma = text.rfind(",")

    if last_dot == -1 and last_comma == -1:
        cleaned = text
    else:
        sep_pos = max(last_dot, last_comma)
        sep = text[sep_pos]
        decimals = len(text) - sep_pos - 1
        other = text.count("." if sep == "," else ",")

        is_decimal_sep = decimals in (1, 2) and (other > 0 or text.count(sep) == 1)
        # "1.234" sa 3 cifre iza je uvek hiljadni separator.
        if decimals == 3:
            is_decimal_sep = False

        if is_decimal_sep:
            head = text[:sep_pos].replace(".", "").replace(",", "")
            cleaned = f"{head}.{text[sep_pos + 1:]}"
        else:
            cleaned = text.replace(".", "").replace(",", "")

    try:
        return Decimal(cleaned)
    except InvalidOperation as exc:
        raise PriceParseError(f"ne mogu da parsiram broj iz {raw!r}") from exc


def parse_price(text: str | None, default_currency: str = "EUR") -> Money | None:
    """Vraća prvu (najmanju) cenu iz teksta, ili None ako je 'na upit'."""
    if not text:
        return None
    if _NO_PRICE.search(text):
        return None

    matches = _NUMBER_RE.findall(text)
    if not matches:
        return None

    currency = detect_currency(text, default_currency)
    amounts: list[Decimal] = []
    for m in matches:
        try:
            value = parse_amount(m)
        except PriceParseError:
            continue
        # Godine i brojevi noći nisu cene.
        if 1900 <= value <= 2100 and value == value.to_integral_value():
            continue
        amounts.append(value)

    if not amounts:
        return None
    return Money(amount=min(amounts), currency=currency)


def parse_price_range(
    text: str | None, default_currency: str = "EUR"
) -> tuple[Money, Money] | None:
    """Za tekst tipa '349 - 599 EUR' vraća (min, max). Za jednu cenu vraća (x, x)."""
    if not text or _NO_PRICE.search(text):
        return None

    currency = detect_currency(text, default_currency)
    amounts: list[Decimal] = []
    for m in _NUMBER_RE.findall(text):
        try:
            value = parse_amount(m)
        except PriceParseError:
            continue
        if 1900 <= value <= 2100 and value == value.to_integral_value():
            continue
        amounts.append(value)

    if not amounts:
        return None
    return (Money(min(amounts), currency), Money(max(amounts), currency))


_DISCOUNT_RE = re.compile(
    r"(first\s*minute|last\s*minute|early\s*book\w*|akcij\w*|popust\w*|"
    r"-\s*\d{1,2}\s*%|\d{1,2}\s*%\s*popust\w*|specijaln\w+\s+ponud\w+)",
    re.IGNORECASE,
)


def detect_discount(text: str | None) -> str | None:
    if not text:
        return None
    m = _DISCOUNT_RE.search(text)
    return m.group(0).strip() if m else None
