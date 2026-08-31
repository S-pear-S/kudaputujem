"""Generički helper za čitanje enum kolona iz baze — Odluka B, CLAUDE.md §7 korak 4.

Kotlinov `fromDb(value: String?)` (companion metod na 7 enuma) je tiho svodio nepoznatu
vrednost na podrazumevanu. Samo po sebi odbranjivo — jedan pokvaren red ne sme da obori
celu pretragu — ali se spaja sa time da nijedna enum kolona danas nema CHECK ograničenje
(Faza B, još nije urađena): greška iz skrepera uđe u bazu, pri čitanju se tiho pretvori u
nešto uverljivo, niko ne sazna. Rezerva ostaje (i dalje ne rušimo upit), ali prestaje da
bude tiha — upozorenje u log kad se aktivira. Kad Faza B postavi CHECK, ovo upozorenje
praktično nikad neće da se javi; ako se ipak javi, nešto zaobilazi bazu i treba da se vidi
isti dan.
"""

from __future__ import annotations

import logging
from enum import Enum

log = logging.getLogger(__name__)


def from_db[E: Enum](
    enum_cls: type[E], value: str | None, *, default: E, table: str, column: str
) -> E | None:
    """`None` na ulazu vraća `None`, bez upozorenja — NULL-abilna kolona nije greška.

    Kotlin meša ova dva slučaja u istom potpisu (`fromDb(value: String?)` vraća uvek
    podrazumevanu vrednost i za `null` i za nepoznat string) — to je greška koju NE
    prenosimo (CLAUDE.md §7, Odluka B).
    """
    if value is None:
        return None
    try:
        return enum_cls(value)
    except ValueError:
        log.warning(
            "Nepoznata vrednost %r za %s (tabela=%s, kolona=%s) — koristim rezervu %s",
            value,
            enum_cls.__name__,
            table,
            column,
            default,
        )
        return default
