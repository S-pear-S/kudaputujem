# Privremeni re-eksport. Brise se u koraku 1c.
"""Tekstualna normalizacija — telo je u `travelcore.normalize.text` (ADR 0001)."""

from __future__ import annotations

from travelcore.normalize.text import (
    canonical_accommodation_name,
    clean,
    deaccent,
    from_cyrillic,
    normalize,
    normalize_keep_symbols,
    slugify,
    strip_stars,
)

__all__ = [
    "canonical_accommodation_name",
    "clean",
    "deaccent",
    "from_cyrillic",
    "normalize",
    "normalize_keep_symbols",
    "slugify",
    "strip_stars",
]
