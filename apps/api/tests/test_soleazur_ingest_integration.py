"""soleazur → ingest → prava baza, kraj-do-kraja — ADR 0001 korak 4, redefinisan cilj
(CLAUDE.md §7): "soleazur skrepuje, ingest upiše, u bazi stoje prave ponude."

Ova sesija nema mrežni izlaz ka soleazur.rs (§4.4/§7 CLAUDE.md), pa se prava HTML stranica
ne može uživo preuzeti — koristi se isti fixture koji `test_soleazur.py` već koristi
(snimljen iz pravog DOM-a 16.08.2026). Razlika od `test_ingest_contract.py`: tamo je
`OfferIn` RUČNO sastavljen (proverava ugovor, svako polje). Ovde `OfferIn` dolazi iz
PRAVOG parsera nad pravim HTML-om (proverava da stvaran izlaz adaptera prolazi kroz
stvaran ingest bez izmene i bez odbačenih ponuda — najbliže ovoj sesiji što može doći do
stvarnog "soleazur skrepuje, ingest upiše" bez žive mreže).
"""

from __future__ import annotations

import os
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from travelcore.models import IngestBatch
from travelscrape.adapters.soleazur import parse_price_page

DATABASE_URL = os.environ.get("DATABASE_URL")
pytestmark = pytest.mark.skipif(not DATABASE_URL, reason="nema DATABASE_URL")

_FIXTURE = (
    Path(__file__).resolve().parents[3]
    / "apps"
    / "scrapers"
    / "tests"
    / "fixtures"
    / "soleazur"
    / "display_prices.html"
)


@pytest.fixture
def client() -> TestClient:
    from travelapi.app import app

    return TestClient(app)


def _auth_headers() -> dict[str, str]:
    from travelapi.config import settings

    return {"X-Api-Key": settings.ingest_api_key}


def test_real_soleazur_fixture_ingests_cleanly(client: TestClient) -> None:
    from travelapi import db

    offers = parse_price_page(_FIXTURE.read_text(encoding="utf-8"))
    assert len(offers) > 0  # fixture mora stvarno nešto da parsira, inače test ništa ne dokazuje

    start_resp = client.post(
        "/internal/runs", json={"source_slug": "soleazur-grcka"}, headers=_auth_headers()
    )
    assert start_resp.status_code == 200
    run_id = start_resp.json()["run_id"]

    batch = IngestBatch(run_id=run_id, source_slug="soleazur-grcka", offers=offers)
    resp = client.post(
        "/internal/ingest/offers", json=batch.model_dump(mode="json"), headers=_auth_headers()
    )
    assert resp.status_code == 200
    result = resp.json()
    assert result["received"] == len(offers)
    assert result["failed"] == 0
    assert result["errors"] == []
    assert result["created"] + result["updated"] + result["unchanged"] == len(offers)

    finish_resp = client.post(
        f"/internal/runs/{run_id}/finish",
        json={"status": "OK", "items_found": len(offers), "force": True},
        headers=_auth_headers(),
    )
    assert finish_resp.status_code == 200

    with db.transaction() as conn:
        rows = conn.execute(
            """
            SELECT o.title, o.is_active, o.min_price_rsd IS NOT NULL AS has_min_price_rsd,
                   a.name AS accommodation_name, d.departure_count
            FROM offer o
            JOIN source s ON s.id = o.source_id
            LEFT JOIN accommodation a ON a.id = o.accommodation_id
            LEFT JOIN LATERAL (
                SELECT COUNT(*) AS departure_count FROM departure WHERE offer_id = o.id
            ) d ON TRUE
            WHERE s.slug = 'soleazur-grcka' AND o.external_id = ANY(%(ids)s)
            """,
            {"ids": [offer.external_id for offer in offers]},
        ).fetchall()

    assert len(rows) == len(offers)
    assert all(row["is_active"] for row in rows)
    assert all(row["accommodation_name"] is not None for row in rows)
    assert all(row["departure_count"] > 0 for row in rows)

    # Ponovan ingest ISTOG fixture-a -> sve UNCHANGED (content_hash detekcija), ne CREATED.
    resp_again = client.post(
        "/internal/ingest/offers", json=batch.model_dump(mode="json"), headers=_auth_headers()
    )
    assert resp_again.status_code == 200
    assert resp_again.json()["unchanged"] == len(offers)
    assert resp_again.json()["created"] == 0
