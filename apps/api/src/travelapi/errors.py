"""Tipizovane greške — prevod `common/Errors.kt`.

Poruka je na srpskom (vidi je krajnji korisnik/skreper koji čita odgovor), `code` je na
engleskom (čita ga log i, kasnije, frontend). Isti obrazac kao Kotlin `ApiException`
hijerarhija + `GlobalExceptionHandler`, ovde kao FastAPI exception handleri.
"""

from __future__ import annotations

import logging
from datetime import UTC, datetime

from fastapi import FastAPI, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from pydantic import BaseModel

log = logging.getLogger(__name__)


class ApiError(Exception):
    """Bazna klasa za sve očekivane greške. `status_code`/`code` nose HTTP odgovor."""

    status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR
    code: str = "error"

    def __init__(self, message: str) -> None:
        super().__init__(message)
        self.message = message


class NotFoundError(ApiError):
    status_code = status.HTTP_404_NOT_FOUND

    def __init__(self, what: str, code: str = "not_found") -> None:
        super().__init__(f"{what} nije pronađeno")
        self.code = code


class BadRequestError(ApiError):
    status_code = status.HTTP_400_BAD_REQUEST

    def __init__(self, message: str, code: str = "bad_request") -> None:
        super().__init__(message)
        self.code = code


class ConflictError(ApiError):
    status_code = status.HTTP_409_CONFLICT

    def __init__(self, message: str, code: str = "conflict") -> None:
        super().__init__(message)
        self.code = code


class RateLimitError(ApiError):
    status_code = status.HTTP_429_TOO_MANY_REQUESTS
    code = "rate_limited"

    def __init__(self, message: str = "Previše zahteva. Pokušajte kasnije.") -> None:
        super().__init__(message)


class ErrorResponse(BaseModel):
    error: str
    code: str
    path: str
    timestamp: datetime
    details: dict[str, str] | None = None


def register_exception_handlers(app: FastAPI) -> None:
    """Registruje handlere. Poziva se jednom pri pravljenju FastAPI aplikacije."""

    @app.exception_handler(ApiError)
    async def _handle_api_error(request: Request, exc: ApiError) -> JSONResponse:
        # Očekivane greške se ne loguju kao ERROR — inače alarmi postanu šum.
        log.debug("%s na %s: %s", exc.code, request.url.path, exc.message)
        body = ErrorResponse(
            error=exc.message, code=exc.code, path=request.url.path, timestamp=_now()
        )
        return JSONResponse(status_code=exc.status_code, content=body.model_dump(mode="json"))

    @app.exception_handler(RequestValidationError)
    async def _handle_validation_error(
        request: Request, exc: RequestValidationError
    ) -> JSONResponse:
        details = {
            ".".join(str(part) for part in err["loc"] if part != "body"): err["msg"]
            for err in exc.errors()
        }
        body = ErrorResponse(
            error="Neispravni podaci u zahtevu",
            code="validation_failed",
            path=request.url.path,
            timestamp=_now(),
            details=details,
        )
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST, content=body.model_dump(mode="json")
        )

    @app.exception_handler(Exception)
    async def _handle_unexpected(request: Request, exc: Exception) -> JSONResponse:
        log.exception("Neočekivana greška na %s", request.url.path)
        # Poruka izuzetka NIKAD ne ide korisniku — može da sadrži SQL, putanje, imena kolona.
        body = ErrorResponse(
            error="Došlo je do greške na serveru",
            code="internal_error",
            path=request.url.path,
            timestamp=_now(),
        )
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, content=body.model_dump(mode="json")
        )


def _now() -> datetime:
    return datetime.now(UTC)
