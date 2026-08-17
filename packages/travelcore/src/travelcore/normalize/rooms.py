"""Parsiranje oznaka soba u kapacitet.

Ovo je najsuptilniji deo normalizacije. Srpska notacija:

    1/1          jednokrevetna
    1/2          dvokrevetna
    1/2+1        dvokrevetna + pomoćni ležaj
    1/2+2        dvokrevetna + dva pomoćna
    1/3          trokrevetna
    1/4          četvorokrevetna
    1/2 FR       francuski ležaj (i dalje 2 osobe)
    A2/4         apartman, minimalno 2, maksimalno 4 osobe
    SU 2/4       studio 2-4
    AP2+2        apartman 2 + 2 pomoćna
    2/4          isto kao A2/4 kad je iz konteksta apartman

Ključno pravilo: ako je brojilac 1, radi se o hotelskoj notaciji "1/N = soba za N".
Ako je brojilac veći od 1, radi se o "min/max" notaciji apartmana.
"""

from __future__ import annotations

import re
from dataclasses import dataclass

from .text import normalize_keep_symbols

_WORD_CAPACITY = {
    "jednokrevetna": 1,
    "jednokrevetni": 1,
    "single": 1,
    "dvokrevetna": 2,
    "dvokrevetni": 2,
    "double": 2,
    "twin": 2,
    "trokrevetna": 3,
    "trokrevetni": 3,
    "triple": 3,
    "cetvorokrevetna": 4,
    "cetvorokrevetni": 4,
    "quad": 4,
    "petokrevetna": 5,
    "sestokrevetna": 6,
}

_UNIT_HINTS = ("apartman", "apart", "studio", "ap", "su", "a", "vila", "kuca", "bungalov", "mobilna")

# 1/2+1 , 1/2 + 1 , 2/4 , A2/4 , AP 2+2 , SU2/4
_FRACTION_RE = re.compile(r"(?<!\d)(\d)\s*/\s*(\d)(?:\s*\+\s*(\d))?")
_PLUS_RE = re.compile(r"(?<!\d)(\d)\s*\+\s*(\d)(?!\d)")
_SINGLE_NUM_RE = re.compile(r"(?<!\d)(\d)\s*(?:os\w*|pax|pers\w*|kreveta?)(?!\d)")


@dataclass(frozen=True)
class RoomCapacity:
    """Kapacitet jedne smeštajne jedinice.

    adults      koliko punih ležaja (osnovni kapacitet)
    extra       koliko pomoćnih ležaja
    total       ukupno mesta
    is_unit     da li se plaća cela jedinica (apartman) umesto po osobi
    confident   da li smo sigurni; ako nije, adapter treba da loguje upozorenje
    """

    adults: int
    extra: int = 0
    is_unit: bool = False
    confident: bool = True

    @property
    def total(self) -> int:
        return self.adults + self.extra


def parse_room_code(code: str | None, *, assume_unit: bool | None = None) -> RoomCapacity:
    """Iz sirove oznake sobe izvlači kapacitet.

    assume_unit:
        True  -> tretiraj kao apartman/studio (cena po jedinici)
        False -> tretiraj kao hotelsku sobu
        None  -> pogodi iz teksta
    """
    if not code or not code.strip():
        return RoomCapacity(adults=2, confident=False)

    norm = normalize_keep_symbols(code)
    tokens = norm.split()
    is_unit = assume_unit if assume_unit is not None else any(
        t in _UNIT_HINTS for t in tokens
    ) or bool(re.match(r"^(a|ap|su|st)\d", norm.replace(" ", "")))

    # 1) razlomak
    m = _FRACTION_RE.search(norm)
    if m:
        numerator = int(m.group(1))
        denominator = int(m.group(2))
        plus = int(m.group(3)) if m.group(3) else 0

        if numerator == 1:
            # hotelska notacija: 1/N = soba za N osoba
            return RoomCapacity(adults=denominator, extra=plus, is_unit=is_unit)
        # apartmanska notacija: min/max
        base = numerator
        extra = max(0, denominator - numerator) + plus
        return RoomCapacity(adults=base, extra=extra, is_unit=True)

    # 2) N+M
    m = _PLUS_RE.search(norm)
    if m:
        return RoomCapacity(adults=int(m.group(1)), extra=int(m.group(2)), is_unit=is_unit)

    # 3) reč
    for token in tokens:
        if token in _WORD_CAPACITY:
            base = _WORD_CAPACITY[token]
            extra = 1 if re.search(r"\+\s*1|pomocn\w+", norm) else 0
            return RoomCapacity(adults=base, extra=extra, is_unit=is_unit)

    # 4) "za 4 osobe"
    m = _SINGLE_NUM_RE.search(norm)
    if m:
        return RoomCapacity(adults=int(m.group(1)), is_unit=is_unit)

    # 5) goli broj na kraju ("apartman 4")
    m = re.search(r"(?<!\d)(\d)(?!\d)\s*$", norm)
    if m and is_unit:
        return RoomCapacity(adults=int(m.group(1)), is_unit=True)

    return RoomCapacity(adults=2, confident=False, is_unit=is_unit)


_CHILD_AGE_RE = re.compile(
    r"(?:dete|deca|djeca|dijete|child\w*)\D{0,15}?"
    r"(?:od\s*(\d{1,2})\s*(?:do|-)\s*(\d{1,2})|do\s*(\d{1,2})|(\d{1,2})\s*-\s*(\d{1,2}))"
)
_INFANT_RE = re.compile(r"\b(beba|bebe|infant|do\s*2\s*god|0\s*-\s*2)\b")


def parse_child_ages(text: str | None) -> tuple[int | None, int | None]:
    """'dete do 12 god' -> (0, 11); 'deca 2-11' -> (2, 11); ništa -> (None, None).

    Napomena: 'do 12' na srpskim sajtovima skoro uvek znači 'do navršenih 12',
    tj. gornja granica je 11. Ovo je konvencija koju svesno primenjujemo.
    """
    if not text:
        return (None, None)
    norm = normalize_keep_symbols(text)

    m = _CHILD_AGE_RE.search(norm)
    if m:
        if m.group(1) and m.group(2):
            return (int(m.group(1)), int(m.group(2)))
        if m.group(3):
            return (0, max(0, int(m.group(3)) - 1))
        if m.group(4) and m.group(5):
            return (int(m.group(4)), int(m.group(5)))

    if _INFANT_RE.search(norm):
        return (0, 1)
    return (None, None)


def is_single_supplement(text: str | None) -> bool:
    if not text:
        return False
    norm = normalize_keep_symbols(text)
    return bool(
        re.search(r"(doplata za jednokrevetnu|single (supplement|use)|1/1 doplata|samac)", norm)
    )
