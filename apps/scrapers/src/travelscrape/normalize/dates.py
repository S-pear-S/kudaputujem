"""Parsiranje datuma i termina sa srpskih sajtova.

Oblici koje smo videli:
    15.07.2026.            tačka na kraju je srpska konvencija
    15.07.2026
    15.7.26
    15/07/2026
    2026-07-15
    15. jul 2026.
    15. jul                (bez godine — pogađamo najbližu buduću)
    10.06. - 17.06.2026.   opseg gde prvi datum nema godinu
    10.06 - 17.06          opseg bez godina
    01.07-08.07.2026
"""

from __future__ import annotations

import re
from datetime import date, timedelta

from .text import normalize

MONTHS_SR = {
    "januar": 1, "jan": 1,
    "februar": 2, "feb": 2,
    "mart": 3, "mar": 3,
    "april": 4, "apr": 4,
    "maj": 5,
    "jun": 6, "juni": 6,
    "jul": 7, "juli": 7,
    "avgust": 8, "avg": 8, "august": 8,
    "septembar": 9, "sep": 9, "sept": 9,
    "oktobar": 10, "okt": 10,
    "novembar": 11, "nov": 11,
    "decembar": 12, "dec": 12,
}

# Separator mora da bude isti u celom datumu (backreference \2), inače
# "01.07-08.07.2026" pogrešno pročita "-08" kao godinu.
_NUMERIC_RE = re.compile(r"(?<!\d)(\d{1,2})([./-])(\d{1,2})(?:\2(\d{2,4}))?(?!\d)")
_ISO_RE = re.compile(r"(?<!\d)(\d{4})-(\d{1,2})-(\d{1,2})(?!\d)")
_WORD_RE = re.compile(r"(?<!\d)(\d{1,2})\.?\s*([a-z]{3,10})\.?\s*(\d{4})?(?!\d)")


class DateParseError(ValueError):
    pass


def _resolve_year(day: int, month: int, year: int | None, reference: date) -> int:
    if year is not None:
        if year < 100:
            year += 2000
        return year
    # Bez godine: uzimamo najbliži datum koji nije više od 60 dana u prošlosti.
    candidate = date(reference.year, month, day)
    if candidate < reference - timedelta(days=60):
        return reference.year + 1
    return reference.year


def parse_date(text: str | None, *, reference: date | None = None) -> date | None:
    """Vraća prvi datum iz teksta ili None."""
    if not text:
        return None
    reference = reference or date.today()
    norm = normalize(text)

    m = _ISO_RE.search(text)
    if m:
        return _safe_date(int(m.group(1)), int(m.group(2)), int(m.group(3)))

    m = _NUMERIC_RE.search(text)
    if m:
        day, month = int(m.group(1)), int(m.group(3))
        year = _resolve_year(day, month, int(m.group(4)) if m.group(4) else None, reference)
        return _safe_date(year, month, day)

    m = _WORD_RE.search(norm)
    if m and m.group(2) in MONTHS_SR:
        day, month = int(m.group(1)), MONTHS_SR[m.group(2)]
        year = _resolve_year(day, month, int(m.group(3)) if m.group(3) else None, reference)
        return _safe_date(year, month, day)

    return None


def _safe_date(year: int, month: int, day: int) -> date | None:
    try:
        return date(year, month, day)
    except ValueError:
        return None


def parse_date_range(
    text: str | None, *, reference: date | None = None
) -> tuple[date, date] | None:
    """'10.06. - 17.06.2026.' -> (2026-06-10, 2026-06-17).

    Godina se preuzima sa drugog datuma ako je prvi nema. Ako opseg prelazi
    Novu godinu (npr. 28.12 - 04.01), drugi datum dobija sledeću godinu.
    """
    if not text:
        return None
    reference = reference or date.today()

    # ISO prvo — inače numerički obrazac ugrabi "07-01" iz "2026-07-01".
    iso = list(_ISO_RE.finditer(text))
    if len(iso) >= 2:
        start = _safe_date(int(iso[0].group(1)), int(iso[0].group(2)), int(iso[0].group(3)))
        end = _safe_date(int(iso[1].group(1)), int(iso[1].group(2)), int(iso[1].group(3)))
        if start and end:
            return (start, end)

    matches = list(_NUMERIC_RE.finditer(text))
    if len(matches) >= 2:
        a, b = matches[0], matches[1]
        day_a, month_a = int(a.group(1)), int(a.group(3))
        day_b, month_b = int(b.group(1)), int(b.group(3))
        raw_year_a = int(a.group(4)) if a.group(4) else None
        raw_year_b = int(b.group(4)) if b.group(4) else None

        year_b = _resolve_year(day_b, month_b, raw_year_b, reference)
        if raw_year_a is not None:
            year_a = raw_year_a + 2000 if raw_year_a < 100 else raw_year_a
        else:
            # Polazak najčešće nema godinu jer je ista kao povratak.
            year_a = year_b

        start = _safe_date(year_a, month_a, day_a)
        end = _safe_date(year_b, month_b, day_b)
        if start and end:
            if end < start:
                # Termin prelazi Novu godinu. Koji datum pomeramo zavisi od toga
                # koji je od njih imao eksplicitnu godinu.
                if raw_year_a is not None:
                    end = _safe_date(end.year + 1, end.month, end.day) or end
                else:
                    start = _safe_date(start.year - 1, start.month, start.day) or start
            return (start, end)

    single = parse_date(text, reference=reference)
    return (single, single) if single else None


_NIGHTS_RE = re.compile(r"(\d{1,2})\s*(?:noc\w*|nocenj\w*|nights?)")
_DAYS_RE = re.compile(r"(\d{1,2})\s*(?:dan\w*|days?)")


def parse_duration(text: str | None) -> tuple[int | None, int | None]:
    """'10 dana / 7 noćenja' -> (days=10, nights=7)."""
    if not text:
        return (None, None)
    norm = normalize(text)
    nights = int(m.group(1)) if (m := _NIGHTS_RE.search(norm)) else None
    days = int(m.group(1)) if (m := _DAYS_RE.search(norm)) else None
    if nights is None and days is not None:
        nights = max(0, days - 1)
    if days is None and nights is not None:
        days = nights + 1
    return (days, nights)
