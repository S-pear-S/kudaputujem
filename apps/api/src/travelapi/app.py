"""FastAPI aplikacija — ADR 0001 korak 4.

Entry point za uvicorn: `uvicorn travelapi.app:app`.
"""

from __future__ import annotations

import hmac
import logging
from collections.abc import Awaitable, Callable

from fastapi import FastAPI
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse, Response

from .config import settings
from .crawl.router import router as crawl_router
from .errors import register_exception_handlers
from .ingest.router import router as ingest_router

log = logging.getLogger(__name__)


class ApiKeyMiddleware(BaseHTTPMiddleware):
    """Štiti `/internal/` i `/admin/` `X-Api-Key` zaglavljem — prevod `ApiKeyFilter.kt`.

    Namerno nije pun auth sistem: dva statička ključa, dve zone (§8 pravilo 16 — namerno
    odvojeni, skreper koji procuri ne sme da briše agencije). Poređenje ide preko
    `hmac.compare_digest` (konstantno u vremenu) — obično poređenje stringa curi
    informaciju o tome koliko se prvih karaktera poklapa.
    """

    async def dispatch(
        self, request: Request, call_next: Callable[[Request], Awaitable[Response]]
    ) -> Response:
        path = request.url.path
        if path.startswith("/internal"):
            zone, expected = "internal", settings.ingest_api_key
        elif path.startswith("/admin"):
            zone, expected = "admin", settings.admin_api_key
        else:
            return await call_next(request)

        provided = request.headers.get("x-api-key", "")
        if not hmac.compare_digest(provided, expected):
            # Ne logujemo ključ ni deo ključa. Samo činjenicu i izvor.
            client = request.client.host if request.client else "?"
            log.warning("Odbijen pristup zoni %s sa %s za %s", zone, client, path)
            return JSONResponse(
                status_code=401,
                content={"error": "Neispravan ili nedostajući X-Api-Key", "zone": zone},
            )

        return await call_next(request)


def create_app() -> FastAPI:
    app = FastAPI(title="Kuda putujem API")
    register_exception_handlers(app)
    app.add_middleware(ApiKeyMiddleware)
    app.include_router(crawl_router)
    app.include_router(ingest_router)
    return app


app = create_app()
