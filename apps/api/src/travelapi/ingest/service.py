"""Prima batch ponuda od skrepera — prevod `ingest/IngestService.kt`.

Jedna loša ponuda ne obara ceo batch — greška se broji i vraća u odgovoru sa
`external_id`-jem, da skreper može tačno da kaže koja stranica je problem. Batch koji bi pao
ceo bi značio da adapter ne može da napreduje dok se ne popravi jedan hotel sa čudnim
HTML-om, a to je pogrešna razmena.

Otpornost ovde pokriva ono što PYDANTIC ne može da proveri unapred: greške u bazi
(constraint, konekcija) i eventualna poslovna pravila koja zavise od stanja baze, ne samo
od oblika JSON-a. Ono što pydantic već validira pri parsiranju HTTP tela (obavezna polja,
datumi u ispravnom redosledu, ...) nikad ne stigne ovamo kao pojedinačna loša stavka —
FastAPI odbija CEO zahtev sa 422 pre nego što handler i vidi batch (isto ponašanje kao
Kotlinov `@Valid @RequestBody`).

`search`/`pricing/price_index` NISU deo ovog prolaza (ADR 0001 korak 4, cilj promenjen —
CLAUDE.md §7) — Kotlinov poziv `priceIndex.rebuildForOffers(...)` na kraju NAMERNO izostaje,
nije zaboravljen.
"""

from __future__ import annotations

import logging

import psycopg
from travelcore.models import IngestBatch, IngestResult

from .. import db
from ..config import settings
from ..crawl.service import find_source
from ..errors import BadRequestError
from . import writer

log = logging.getLogger(__name__)


def ingest(batch: IngestBatch) -> IngestResult:
    if len(batch.offers) > settings.max_offers_per_batch:
        raise BadRequestError(
            f"Batch ima {len(batch.offers)} ponuda, maksimum je {settings.max_offers_per_batch}",
            "batch_too_large",
        )

    source = find_source(batch.source_slug)
    errors: list[str] = []
    created = updated = unchanged = failed = 0
    completeness_sum = 0.0

    for offer in batch.offers:
        completeness_sum += offer.completeness_score()
        if batch.dry_run:
            continue

        try:
            result = writer.write(offer, source.id, source.agency_id)
        except psycopg.Error:
            failed += 1
            errors.append(f"{offer.external_id}: greška u bazi")
            log.error(
                "Greška u bazi za ponudu %s sa izvora %s", offer.external_id, source.slug,
                exc_info=True,
            )
        except ValueError as exc:
            failed += 1
            errors.append(f"{offer.external_id}: {exc}")
            log.warning("Odbijena ponuda %s sa izvora %s: %s", offer.external_id, source.slug, exc)
        else:
            if result.outcome is writer.Outcome.CREATED:
                created += 1
            elif result.outcome is writer.Outcome.UPDATED:
                updated += 1
            else:
                unchanged += 1

    if not batch.dry_run:
        with db.transaction() as conn:
            conn.execute(
                """
                UPDATE crawl_run SET
                    items_created = items_created + %(created)s,
                    items_updated = items_updated + %(updated)s,
                    items_failed = items_failed + %(failed)s
                WHERE id = %(run_id)s
                """,
                {"created": created, "updated": updated, "failed": failed, "run_id": batch.run_id},
            )

    avg_completeness = round(completeness_sum / len(batch.offers), 3) if batch.offers else 0.0
    log.debug(
        "Batch %d ponuda sa izvora %s: +%d ~%d =%d !%d, prosečna popunjenost %.1f%%",
        len(batch.offers), source.slug, created, updated, unchanged, failed, avg_completeness * 100,
    )

    return IngestResult(
        received=len(batch.offers),
        created=created,
        updated=updated,
        unchanged=unchanged,
        failed=failed,
        errors=errors[:50],
    )
