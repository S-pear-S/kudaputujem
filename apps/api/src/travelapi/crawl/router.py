"""Endpointi koje koriste skreperi. Zaštićeni `X-Api-Key` zaglavljem (vidi `travelapi.app`).

Tok jedne runde:
    POST /internal/runs                    -> dobija run_id i podešavanja izvora
    POST /internal/ingest/offers  (više puta, u batch-evima; ingest modul, sledeći deo)
    POST /internal/runs/{id}/finish        -> deaktivira što nije viđeno, proverava SUSPECT
"""

from __future__ import annotations

from fastapi import APIRouter

from . import service
from .models import FinishRunRequest, FinishRunResponse, StartRunRequest, StartRunResponse

router = APIRouter(prefix="/internal", tags=["crawl"])


@router.post("/runs")
def start_run(request: StartRunRequest) -> StartRunResponse:
    return service.start(request)


@router.post("/runs/{run_id}/finish")
def finish_run(run_id: int, request: FinishRunRequest) -> FinishRunResponse:
    return service.finish(run_id, request)
