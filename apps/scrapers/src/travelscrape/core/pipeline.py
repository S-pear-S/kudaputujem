"""Orkestrira scraping runu od pocetka do kraja.

Tok:
    1. Uzme adapter iz registra
    2. Proveri robots.txt za sve dozvoljene domene
    3. Otvori runu na API-ju
    4. Skrepuje ponude kroz adapter i salje u batchevima
    5. Zatvori runu sa summary-jem
"""

from __future__ import annotations

import asyncio
import logging
import time

from .adapter import BaseAdapter
from .fetch import HttpFetcher, RobotsDisallowedError
from .ingest import IngestClient
from .models import OfferIn, RunSummary
from .settings import Settings, settings as default_settings

log = logging.getLogger(__name__)


class PipelineRunner:
    def __init__(
        self,
        settings: Settings | None = None,
    ) -> None:
        self._cfg = settings or default_settings

    def run(
        self,
        adapter: BaseAdapter,
        *,
        dry_run: bool = False,
        force: bool = False,
        check_robots: bool = True,
    ) -> RunSummary:
        """Pokrece punu crawl runu za adapter. Blokira dok se ne zavrsi."""
        return asyncio.run(
            self._run_async(adapter, dry_run=dry_run, force=force, check_robots=check_robots)
        )

    async def _run_async(
        self,
        adapter: BaseAdapter,
        *,
        dry_run: bool,
        force: bool,
        check_robots: bool,
    ) -> RunSummary:
        source_slug = adapter.source_slug
        allowed = adapter.allowed_domains
        t_start = time.monotonic()

        created = updated = unchanged = failed = 0
        total_completeness = 0.0
        offer_count = 0
        error_msg: str | None = None

        with IngestClient(self._cfg) as ingest:
            run_id = ingest.start_run(source_slug)

            try:
                async with HttpFetcher(allowed, self._cfg) as fetcher:
                    # Provjera robots.txt za sve domene izvora
                    if check_robots:
                        for domain in allowed:
                            url = f"https://{domain}/"
                            allowed_by_robots = await fetcher.check_robots(url)
                            if not allowed_by_robots:
                                raise RobotsDisallowedError(
                                    f"robots.txt zabranjuje scrapovanje {domain!r}. "
                                    "Isključiti izvor ili kontaktirati agenciju."
                                )

                    batch: list[OfferIn] = []

                    async for offer in adapter.scrape(fetcher):
                        batch.append(offer)
                        offer_count += 1
                        total_completeness += offer.completeness_score()

                        if len(batch) >= self._cfg.batch_size:
                            result = ingest.send_batch(run_id, batch, dry_run=dry_run)
                            created += result.created
                            updated += result.updated
                            unchanged += result.unchanged
                            failed += result.failed
                            batch.clear()

                    if batch:
                        result = ingest.send_batch(run_id, batch, dry_run=dry_run)
                        created += result.created
                        updated += result.updated
                        unchanged += result.unchanged
                        failed += result.failed

                status = "OK"

            except RobotsDisallowedError as exc:
                status = "FAILED"
                error_msg = str(exc)
                log.error("Runa #%d prekinuta: %s", run_id, exc)
            except Exception as exc:
                status = "FAILED"
                error_msg = str(exc)
                log.exception("Runa #%d neocekivana greska", run_id)

            duration = time.monotonic() - t_start
            avg_completeness = (total_completeness / offer_count) if offer_count else 0.0

            summary = RunSummary(
                run_id=run_id,
                source_slug=source_slug,
                status=status,
                items_found=offer_count,
                items_created=created,
                items_updated=updated,
                items_failed=failed,
                duration_seconds=round(duration, 2),
                avg_completeness=round(avg_completeness, 3),
                error_message=error_msg,
            )

            ingest.finish_run(run_id, summary)

        return summary
