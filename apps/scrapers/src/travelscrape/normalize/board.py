# Privremeni re-eksport. Brise se u koraku 1c.
"""Mapiranje usluge ishrane — telo je u `travelcore.normalize.board` (ADR 0001)."""

from __future__ import annotations

from travelcore.normalize.board import (
    LABELS_SR,
    board_rank,
    parse_board,
    parse_board_strict,
)

__all__ = [
    "LABELS_SR",
    "board_rank",
    "parse_board",
    "parse_board_strict",
]
