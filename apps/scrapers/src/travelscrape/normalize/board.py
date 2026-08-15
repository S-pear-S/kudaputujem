"""Mapiranje usluge ishrane u kanonski BoardType.

Srpske agencije koriste bar 40 zapisa za istih 6 stvari. Redosled provere je bitan:
duži i specifičniji obrasci prvi, jer "all inclusive" sadrži "all", a "ultra all
inclusive" sadrži "all inclusive".
"""

from __future__ import annotations

import re

from ..core.enums import BoardType
from .text import normalize

# (regex, BoardType) — proverava se redom, prvi pogodak pobeđuje.
_RULES: list[tuple[re.Pattern[str], BoardType]] = [
    # UAI mora pre AI
    (re.compile(r"\b(ultra all ?in\w*|uai|ultra ai|ultra sve uklju\w*)\b"), BoardType.UAI),
    (re.compile(r"\b(all ?in\w*|ai|sve uklju\w*|sve ukljuceno)\b"), BoardType.AI),
    # Pun pansion
    (re.compile(r"\b(pun pansion|puni pansion|pansion pun|full ?board|fb|pu)\b"), BoardType.FB),
    # Polupansion
    (re.compile(r"\b(polupansion|polu pansion|half ?board|hb|pp)\b"), BoardType.HB),
    # Noćenje sa doručkom
    (
        re.compile(
            r"\b(nocenje sa doruckom|nocenje s doruckom|nocenje i dorucak|"
            r"bed and breakfast|bed ?& ?breakfast|dorucak|breakfast|bb|nd)\b"
        ),
        BoardType.BB,
    ),
    # Najam / bez ishrane
    (
        re.compile(
            r"\b(najam|bez ishrane|bez usluge|samo smestaj|samo nocenje|"
            r"sopstvena ishrana|self ?catering|room ?only|ro|na|so|sc)\b"
        ),
        BoardType.RO,
    ),
]

# Ljudski čitljive oznake za frontend.
LABELS_SR: dict[BoardType, str] = {
    BoardType.RO: "Najam (bez ishrane)",
    BoardType.BB: "Noćenje s doručkom",
    BoardType.HB: "Polupansion",
    BoardType.FB: "Pun pansion",
    BoardType.AI: "All inclusive",
    BoardType.UAI: "Ultra all inclusive",
    BoardType.NONE: "Nije navedeno",
}


def parse_board(text: str | None) -> BoardType:
    """'polupansion' -> HB, 'ND' -> BB, 'ALL IN' -> AI, nepoznato -> NONE."""
    if not text:
        return BoardType.NONE
    norm = normalize(text)
    if not norm:
        return BoardType.NONE
    for pattern, board in _RULES:
        if pattern.search(norm):
            return board
    return BoardType.NONE


def parse_board_strict(text: str | None) -> BoardType:
    """Kao parse_board, ali baca izuzetak umesto NONE.

    Koristi se u adapterima gde znamo da polje MORA da postoji — bolje da runda
    padne nego da tiho upišemo pogrešnu uslugu.
    """
    board = parse_board(text)
    if board is BoardType.NONE and text and text.strip():
        raise ValueError(f"nepoznata usluga ishrane: {text!r}")
    return board


def board_rank(board: BoardType) -> int:
    """Za sortiranje 'od slabije ka bogatijoj usluzi'."""
    order = {
        BoardType.NONE: 0,
        BoardType.RO: 1,
        BoardType.BB: 2,
        BoardType.HB: 3,
        BoardType.FB: 4,
        BoardType.AI: 5,
        BoardType.UAI: 6,
    }
    return order[board]
