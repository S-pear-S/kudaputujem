"""Životni ciklus jedne runde skrepovanja — prevod `crawl/CrawlRunService.kt`.

## Zašto postoji SUSPECT status

Skreper koji baci grešku je lako primetiti. Skreper koji tiho vrati 40 umesto 3000 ponuda
je katastrofa, jer bi deaktivirao 2960 ispravnih ponuda i korisnik bi video praznu pretragu.
Zato se svaka runda poredi sa prosekom prethodnih; ako je znatno ispod, runda se označi kao
SUSPECT i **ništa se ne deaktivira**. Podaci ostaju stari, ali tačni. Vidi §4.6.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass
from datetime import datetime
from typing import Any

import psycopg
from psycopg.types.json import Jsonb
from travelcore.enums import CrawlStatus, SourceHealth

from .. import db
from ..common.from_db import from_db
from ..config import settings
from ..errors import BadRequestError, NotFoundError
from .models import FinishRunRequest, FinishRunResponse, StartRunRequest, StartRunResponse

log = logging.getLogger(__name__)

_HEALTH_BY_STATUS: dict[CrawlStatus, SourceHealth] = {
    CrawlStatus.OK: SourceHealth.OK,
    CrawlStatus.SUSPECT: SourceHealth.DEGRADED,
    CrawlStatus.FAILED: SourceHealth.FAILING,
}


@dataclass(frozen=True)
class SourceRow:
    id: int
    agency_id: int
    slug: str
    crawl_delay_ms: int
    max_concurrency: int
    requires_browser: bool
    expected_min_items: int
    robots_allowed: bool
    is_enabled: bool
    config: dict[str, Any]


def find_source(slug: str) -> SourceRow:
    with db.transaction() as conn:
        row = conn.execute(
            """
            SELECT id, agency_id, slug, crawl_delay_ms, max_concurrency, requires_browser,
                   expected_min_items, robots_allowed, is_enabled, config
            FROM source WHERE slug = %(slug)s
            """,
            {"slug": slug},
        ).fetchone()

    if row is None:
        raise NotFoundError(f"Izvor '{slug}'", "source_not_found")

    return SourceRow(
        id=row["id"],
        agency_id=row["agency_id"],
        slug=row["slug"],
        crawl_delay_ms=row["crawl_delay_ms"],
        max_concurrency=row["max_concurrency"],
        requires_browser=row["requires_browser"],
        expected_min_items=row["expected_min_items"],
        robots_allowed=row["robots_allowed"],
        is_enabled=row["is_enabled"],
        config=row["config"],
    )


def start(request: StartRunRequest) -> StartRunResponse:
    source = find_source(request.source_slug)

    if not source.is_enabled:
        raise BadRequestError(f"Izvor '{source.slug}' je isključen")
    if not source.robots_allowed:
        raise BadRequestError(f"robots.txt izvora '{source.slug}' ne dozvoljava skrepovanje")

    with db.transaction() as conn:
        inserted = conn.execute(
            """
            INSERT INTO crawl_run (source_id, status, trigger_kind, scraper_version)
            VALUES (%(source_id)s, 'RUNNING', %(trigger_kind)s, %(version)s)
            RETURNING id
            """,
            {
                "source_id": source.id,
                "trigger_kind": request.trigger_kind,
                "version": request.scraper_version,
            },
        ).fetchone()
        if inserted is None:  # pragma: no cover — RETURNING id posle uspešnog INSERT-a ne izostaje
            raise RuntimeError("INSERT ... RETURNING id nije vratio red")
        run_id: int = inserted["id"]

        conn.execute(
            "UPDATE source SET last_run_at = now(), updated_at = now() WHERE id = %(id)s",
            {"id": source.id},
        )

    log.info("Runda %d pokrenuta za izvor %s", run_id, source.slug)

    return StartRunResponse(
        run_id=run_id,
        source_id=source.id,
        source_slug=source.slug,
        crawl_delay_ms=source.crawl_delay_ms,
        max_concurrency=source.max_concurrency,
        requires_browser=source.requires_browser,
        config=source.config,
    )


def finish(run_id: int, request: FinishRunRequest) -> FinishRunResponse:
    with db.transaction() as conn:
        row = conn.execute(
            "SELECT source_id, started_at, items_created, items_updated FROM crawl_run "
            "WHERE id = %(id)s",
            {"id": run_id},
        ).fetchone()
        if row is None:
            raise NotFoundError(f"Runda {run_id}", "run_not_found")

        source_id: int = row["source_id"]
        started_at: datetime = row["started_at"]
        items_written: int = row["items_created"] + row["items_updated"]

        requested_status = from_db(
            CrawlStatus,
            request.status,
            default=CrawlStatus.OK,
            table="crawl_run",
            column="status (iz zahteva skrepera)",
        )
        if requested_status is None:  # request.status je uvek str, ovo se ne dešava
            requested_status = CrawlStatus.OK

        suspect = (
            not request.force
            and requested_status is CrawlStatus.OK
            and _is_suspiciously_low(conn, source_id, run_id, items_written)
        )

        final_status: CrawlStatus
        if requested_status is not CrawlStatus.OK:
            final_status = requested_status
        elif suspect:
            final_status = CrawlStatus.SUSPECT
        else:
            final_status = CrawlStatus.OK

        expired = (
            _expire_unseen(conn, source_id, started_at) if final_status is CrawlStatus.OK else 0
        )

        conn.execute(
            """
            UPDATE crawl_run SET
                status = %(status)s, finished_at = now(), pages_fetched = %(pages)s,
                items_found = %(found)s, items_failed = %(failed)s, items_expired = %(expired)s,
                error_message = %(error)s, stats = %(stats)s
            WHERE id = %(id)s
            """,
            {
                "id": run_id,
                "status": final_status.value,
                "pages": request.pages_fetched,
                "found": request.items_found,
                "failed": request.items_failed,
                "expired": expired,
                "error": request.error_message,
                "stats": Jsonb(request.stats),
            },
        )

        _update_source_health(conn, source_id, final_status)

    message = _finish_message(final_status, expired, items_written)
    log.info("Runda %d završena: %s (%s)", run_id, final_status.value, message)
    return FinishRunResponse(
        run_id=run_id, status=final_status.value, items_expired=expired, message=message
    )


def _is_suspiciously_low(
    conn: psycopg.Connection[db.Row], source_id: int, run_id: int, items_written: int
) -> bool:
    """Poredi sa prosekom poslednjih rundi, ne sa nulom."""
    expected_row = conn.execute(
        "SELECT expected_min_items FROM source WHERE id = %(id)s", {"id": source_id}
    ).fetchone()
    expected_min_items: int = expected_row["expected_min_items"] if expected_row else 1

    if items_written < expected_min_items:
        return True

    avg_row = conn.execute(
        """
        SELECT AVG(items_created + items_updated) AS avg
        FROM (
            SELECT items_created, items_updated FROM crawl_run
            WHERE source_id = %(source_id)s AND id <> %(run_id)s AND status = 'OK'
            ORDER BY started_at DESC LIMIT %(window)s
        ) recent
        """,
        {"source_id": source_id, "run_id": run_id, "window": settings.history_window},
    ).fetchone()
    average = avg_row["avg"] if avg_row else None
    if average is None:
        return False  # prva runda nema sa čim da se poredi

    return items_written < float(average) * settings.suspect_ratio


def _expire_unseen(conn: psycopg.Connection[db.Row], source_id: int, started_at: datetime) -> int:
    cursor = conn.execute(
        """
        UPDATE offer SET is_active = FALSE, updated_at = now()
        WHERE source_id = %(source_id)s AND is_active AND last_seen_at < %(started_at)s
        """,
        {"source_id": source_id, "started_at": started_at},
    )
    return cursor.rowcount


def _update_source_health(
    conn: psycopg.Connection[db.Row], source_id: int, status: CrawlStatus
) -> None:
    health = _HEALTH_BY_STATUS.get(status, SourceHealth.UNKNOWN)
    conn.execute(
        """
        UPDATE source SET
            health_status = %(health)s,
            last_success_at = CASE WHEN %(is_ok)s THEN now() ELSE last_success_at END,
            updated_at = now()
        WHERE id = %(id)s
        """,
        {"id": source_id, "health": health.value, "is_ok": status is CrawlStatus.OK},
    )


def _finish_message(status: CrawlStatus, expired: int, items_written: int) -> str:
    if status is CrawlStatus.OK:
        return f"Runda uspešna. Deaktivirano {expired} ponuda koje više nisu na sajtu."
    if status is CrawlStatus.SUSPECT:
        return (
            f"Runda je vratila sumnjivo malo rezultata ({items_written}). "
            "Ništa nije deaktivirano. Proveri adapter, pa pokreni sa force=true ako je pad stvaran."
        )
    return f"Runda završena sa statusom {status.value}."
