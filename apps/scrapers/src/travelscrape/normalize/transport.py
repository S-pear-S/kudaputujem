# Privremeni re-eksport. Brise se u koraku 1c.
"""Mapiranje načina prevoza — telo je u `travelcore.normalize.transport` (ADR 0001)."""

from __future__ import annotations

from travelcore.normalize.transport import (
    LABELS_SR,
    parse_transport,
    parse_transport_options,
)

__all__ = [
    "LABELS_SR",
    "parse_transport",
    "parse_transport_options",
]
