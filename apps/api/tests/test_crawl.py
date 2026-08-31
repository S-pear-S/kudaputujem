"""Crawl runde kroz pravi HTTP zahtev, prava baza — traži DATABASE_URL sa primenjenom
`V3__seed_sources.sql` migracijom (`soleazur-grcka`/`oktopod-grcka` u `source` tabeli).

`docker compose up -d postgres` pa `alembic upgrade head` (iz `apps/api`) pre pokretanja.
"""

from __future__ import annotations

import os

import pytest
from fastapi.testclient import TestClient

DATABASE_URL = os.environ.get("DATABASE_URL")
pytestmark = pytest.mark.skipif(not DATABASE_URL, reason="nema DATABASE_URL")


@pytest.fixture
def client() -> TestClient:
    from travelapi.app import app

    return TestClient(app)


def _auth_headers() -> dict[str, str]:
    from travelapi.config import settings

    return {"X-Api-Key": settings.ingest_api_key}


def test_start_run_without_api_key_is_rejected(client: TestClient) -> None:
    resp = client.post("/internal/runs", json={"source_slug": "soleazur-grcka"})
    assert resp.status_code == 401


def test_start_run_unknown_source_returns_404(client: TestClient) -> None:
    resp = client.post(
        "/internal/runs",
        json={"source_slug": "ne-postoji-nikad"},
        headers=_auth_headers(),
    )
    assert resp.status_code == 404
    assert resp.json()["code"] == "source_not_found"


def test_start_and_finish_run_for_soleazur(client: TestClient) -> None:
    start_resp = client.post(
        "/internal/runs",
        json={"source_slug": "soleazur-grcka", "trigger_kind": "MANUAL"},
        headers=_auth_headers(),
    )
    assert start_resp.status_code == 200
    body = start_resp.json()
    assert body["source_slug"] == "soleazur-grcka"
    assert body["run_id"] > 0
    run_id = body["run_id"]

    # Bez ingest-ovanih ponuda (items_found=0 < expected_min_items=20) runda mora biti
    # SUSPECT — to je poenta §4.6 zaštite, ne bug.
    finish_resp = client.post(
        f"/internal/runs/{run_id}/finish",
        json={"status": "OK", "items_found": 0},
        headers=_auth_headers(),
    )
    assert finish_resp.status_code == 200
    finish_body = finish_resp.json()
    assert finish_body["run_id"] == run_id
    assert finish_body["status"] == "SUSPECT"
    assert finish_body["items_expired"] == 0


def test_finish_run_with_force_skips_suspect_check(client: TestClient) -> None:
    start_resp = client.post(
        "/internal/runs",
        json={"source_slug": "oktopod-grcka"},
        headers=_auth_headers(),
    )
    run_id = start_resp.json()["run_id"]

    finish_resp = client.post(
        f"/internal/runs/{run_id}/finish",
        json={"status": "OK", "items_found": 0, "force": True},
        headers=_auth_headers(),
    )
    assert finish_resp.status_code == 200
    assert finish_resp.json()["status"] == "OK"


def test_finish_run_unknown_id_returns_404(client: TestClient) -> None:
    resp = client.post(
        "/internal/runs/999999999/finish",
        json={"status": "OK"},
        headers=_auth_headers(),
    )
    assert resp.status_code == 404
    assert resp.json()["code"] == "run_not_found"
