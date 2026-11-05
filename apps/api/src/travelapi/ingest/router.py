"""`POST /internal/ingest/offers` — prevod ingest dela `IngestController.kt`."""

from __future__ import annotations

from fastapi import APIRouter
from travelcore.models import IngestBatch, IngestResult

from . import service

router = APIRouter(prefix="/internal", tags=["ingest"])


@router.post("/ingest/offers")
def ingest_offers(batch: IngestBatch) -> IngestResult:
    return service.ingest(batch)
