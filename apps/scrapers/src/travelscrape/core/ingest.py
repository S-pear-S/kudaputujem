"""Klijent za komunikaciju sa /internal/* endpointima API-ja.

Skreper NE zna za bazu — sve ide kroz ovaj klijent.
"""

from __future__ import annotations

import logging

import httpx

from .models import IngestBatch, IngestResult, OfferIn, RunSummary
from .settings import Settings, settings as default_settings

log = logging.getLogger(__name__)


class IngestClient:
    """Tanki HTTP klijent oko /internal API endpointa."""

    def __init__(self, settings: Settings | None = None) -> None:
        self._cfg = settings or default_settings
        self._client: httpx.Client | None = None

    def __enter__(self) -> IngestClient:
        self._client = httpx.Client(
            base_url=self._cfg.api_url,
            headers={
                "X-API-Key": self._cfg.ingest_api_key,
                "Content-Type": "application/json",
            },
            timeout=60.0,
        )
        return self

    def __exit__(self, *args: object) -> None:
        if self._client:
            self._client.close()

    # -- javni API -------------------------------------------------------------

    def start_run(self, source_slug: str) -> int:
        """Otvara novu crawl runu. Vraca run_id."""
        resp = self._post("/internal/runs", {"sourceSlug": source_slug})
        run_id: int = resp["runId"]
        log.info("Runa #%d otvorena za %s", run_id, source_slug)
        return run_id

    def send_batch(
        self,
        run_id: int,
        offers: list[OfferIn],
        *,
        dry_run: bool = False,
    ) -> IngestResult:
        """Salje batch ponuda API-ju. Vraca rezultat ingesta."""
        batch = IngestBatch(
            run_id=run_id,
            source_slug=offers[0].source_slug if offers else "",
            offers=offers,
            dry_run=dry_run,
        )
        data = self._post(
            "/internal/ingest/offers",
            batch.model_dump(mode="json"),
        )
        result = IngestResult(**data)
        log.debug(
            "Batch %d ponuda: +%d ~%d =%d !%d",
            len(offers),
            result.created,
            result.updated,
            result.unchanged,
            result.failed,
        )
        return result

    def finish_run(self, run_id: int, summary: RunSummary) -> None:
        """Zatvara runu i salje finalni summary."""
        self._post(
            f"/internal/runs/{run_id}/finish",
            summary.model_dump(mode="json"),
        )
        log.info(
            "Runa #%d zatvorena: status=%s, ponuda=%d",
            run_id,
            summary.status,
            summary.items_found,
        )

    # -- interni pomocnici -----------------------------------------------------

    def _post(self, path: str, body: dict) -> dict:
        assert self._client is not None, "IngestClient mora biti koriscen kao context manager"
        resp = self._client.post(path, json=body)
        if not resp.is_success:
            raise RuntimeError(
                f"API greska {resp.status_code} na {path}: {resp.text[:200]}"
            )
        return resp.json()
