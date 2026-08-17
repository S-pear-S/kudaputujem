# Privremeni re-eksport. Brise se u koraku 1c.
"""Ugovor između skrepera i API-ja — telo je u `travelcore.models` (ADR 0001)."""

from __future__ import annotations

from travelcore.models import (
    AccommodationIn,
    DepartureIn,
    IngestBatch,
    IngestResult,
    OfferIn,
    PriceIn,
    RawOffer,
    RunSummary,
    SurchargeIn,
    TransportLegIn,
)

__all__ = [
    "AccommodationIn",
    "DepartureIn",
    "IngestBatch",
    "IngestResult",
    "OfferIn",
    "PriceIn",
    "RawOffer",
    "RunSummary",
    "SurchargeIn",
    "TransportLegIn",
]
