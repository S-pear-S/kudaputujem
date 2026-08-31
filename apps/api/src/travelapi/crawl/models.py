"""Ugovor za `/internal/runs*`.

`OfferIn`/`IngestBatch`/`IngestResult`/`RunSummary` dolaze direktno iz `travelcore.models` —
to je OGLEDALO deljeno sa skreperom (§4.2). Ovi DTO-ovi nisu: `start_run`/`finish_run` oblik
je API-only, isto kao u Kotlinu (`ingest/IngestDto.kt` je imao `StartRunRequest`/
`StartRunResponse`/`FinishRunRequest`/`FinishRunResponse` samo u `apps/api`, ne u zajedničkom
ugovoru), pa žive ovde, ne u `travelcore`.
"""

from __future__ import annotations

from typing import Any

from pydantic import BaseModel, Field


class StartRunRequest(BaseModel):
    source_slug: str
    trigger_kind: str = "MANUAL"
    scraper_version: str | None = None


class StartRunResponse(BaseModel):
    run_id: int
    source_id: int
    source_slug: str
    crawl_delay_ms: int
    max_concurrency: int
    requires_browser: bool
    config: dict[str, Any]


class FinishRunRequest(BaseModel):
    status: str = "OK"
    pages_fetched: int = 0
    items_found: int = 0
    items_failed: int = 0
    error_message: str | None = None
    stats: dict[str, Any] = Field(default_factory=dict)
    # Preskače SUSPECT proveru. Koristi se kad je pad ponuda stvaran (kraj sezone).
    force: bool = False


class FinishRunResponse(BaseModel):
    run_id: int
    status: str
    items_expired: int
    message: str
