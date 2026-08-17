"""Tekstualna normalizacija.

`normalize()` MORA da daje isti rezultat kao SQL funkcija `norm_text()` iz V1 migracije,
inače alias tabele neće pogađati. Test `test_text.py::test_matches_sql_norm_text` to čuva.
"""

from __future__ import annotations

import re
import unicodedata

# Srpska latinica -> ASCII. NFKD sam ne razlaže đ/Đ.
_LATIN = {
    "č": "c", "ć": "c", "ž": "z", "š": "s", "đ": "dj",
    "Č": "C", "Ć": "C", "Ž": "Z", "Š": "S", "Đ": "Dj",
}

# Ćirilica -> latinica. Agencije povremeno pišu ćirilicom, pogotovo domaće destinacije.
_CYRILLIC = {
    "а": "a", "б": "b", "в": "v", "г": "g", "д": "d", "ђ": "dj", "е": "e", "ж": "z",
    "з": "z", "и": "i", "ј": "j", "к": "k", "л": "l", "љ": "lj", "м": "m", "н": "n",
    "њ": "nj", "о": "o", "п": "p", "р": "r", "с": "s", "т": "t", "ћ": "c", "у": "u",
    "ф": "f", "х": "h", "ц": "c", "ч": "c", "џ": "dz", "ш": "s",
}

_WS_RE = re.compile(r"\s+")
_NON_ALNUM_RE = re.compile(r"[^a-z0-9]+")
_SLUG_RE = re.compile(r"[^a-z0-9]+")


def from_cyrillic(text: str) -> str:
    out = []
    for ch in text:
        lower = ch.lower()
        if lower in _CYRILLIC:
            mapped = _CYRILLIC[lower]
            out.append(mapped.capitalize() if ch.isupper() else mapped)
        else:
            out.append(ch)
    return "".join(out)


def deaccent(text: str) -> str:
    text = from_cyrillic(text)
    for src, dst in _LATIN.items():
        text = text.replace(src, dst)
    decomposed = unicodedata.normalize("NFKD", text)
    return "".join(ch for ch in decomposed if not unicodedata.combining(ch))


def clean(text: str | None) -> str | None:
    """Skida nbsp, višestruke razmake, zero-width karaktere i krajnje interpunkcije."""
    if text is None:
        return None
    text = text.replace("\xa0", " ").replace("​", "").replace(" ", " ")
    text = _WS_RE.sub(" ", text).strip()
    return text or None


def normalize(text: str) -> str:
    """Kanonski oblik za poklapanje. Isto kao SQL norm_text()."""
    return _NON_ALNUM_RE.sub(" ", deaccent(text).lower()).strip()


_KEEP_SYMBOLS_RE = re.compile(r"[^a-z0-9/+\-().]+")


def normalize_keep_symbols(text: str) -> str:
    """Kao normalize(), ali čuva `/ + - ( ) .`.

    Oznake soba (`1/2+1`, `A2/4`) i opsezi uzrasta (`2-11`) gube smisao ako im
    obrišemo separatore, pa se za njih koristi ova varijanta.
    """
    return _WS_RE.sub(" ", _KEEP_SYMBOLS_RE.sub(" ", deaccent(text).lower())).strip()


def slugify(text: str, max_length: int = 80) -> str:
    slug = _SLUG_RE.sub("-", deaccent(text).lower()).strip("-")
    slug = re.sub(r"-+", "-", slug)
    if len(slug) > max_length:
        slug = slug[:max_length].rstrip("-")
    return slug


def strip_stars(name: str) -> tuple[str, float | None]:
    """Odvaja zvezdice od imena hotela.

    'Hotel Porto Matina 3*'      -> ('Hotel Porto Matina', 3.0)
    'Blue Sea 4*+'               -> ('Blue Sea', 4.5)
    'Sunrise Resort *****'       -> ('Sunrise Resort', 5.0)
    'Vila Marija'                -> ('Vila Marija', None)
    """
    text = clean(name) or ""

    m = re.search(r"(\d)\s*\*\s*(\+)?\s*$", text)
    if m:
        stars = float(m.group(1)) + (0.5 if m.group(2) else 0.0)
        return (clean(text[: m.start()]) or text, stars)

    m = re.search(r"(\*{1,5})\s*(\+)?\s*$", text)
    if m:
        stars = float(len(m.group(1))) + (0.5 if m.group(2) else 0.0)
        return (clean(text[: m.start()]) or text, stars)

    m = re.search(r"\b(\d)\s*(?:zvezdic\w*|zvjezdic\w*|stars?)\s*$", text, re.IGNORECASE)
    if m:
        return (clean(text[: m.start()]) or text, float(m.group(1)))

    return (text, None)


_HOTEL_PREFIXES = (
    "hotel", "hotels", "aparthotel", "apart hotel", "vila", "villa", "apartmani",
    "apartments", "apartman", "studio", "studios", "resort", "hostel", "pansion",
    "guest house", "kuca", "smestaj",
)


def canonical_accommodation_name(name: str) -> str:
    """Ime hotela svedeno na oblik po kome poredimo dva sajta.

    'Hotel Porto Matina 3*' i 'PORTO MATINA HOTEL' -> 'porto matina'
    """
    base, _ = strip_stars(name)
    norm = normalize(base)
    tokens = [t for t in norm.split() if t not in _HOTEL_PREFIXES]
    return " ".join(tokens) if tokens else norm
