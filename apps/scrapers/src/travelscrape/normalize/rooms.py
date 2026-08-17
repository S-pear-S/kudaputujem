# Privremeni re-eksport. Brise se u koraku 1c.
"""Parsiranje oznaka soba — telo je u `travelcore.normalize.rooms` (ADR 0001)."""

from __future__ import annotations

from travelcore.normalize.rooms import (
    RoomCapacity,
    is_single_supplement,
    parse_child_ages,
    parse_room_code,
)

__all__ = [
    "RoomCapacity",
    "is_single_supplement",
    "parse_child_ages",
    "parse_room_code",
]
