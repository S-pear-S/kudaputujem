"""`DestinationResolver` — prevod `geo/DestinationResolver.kt`, veran port (bez odstupanja)."""

from __future__ import annotations

import os
import uuid

import pytest

DATABASE_URL = os.environ.get("DATABASE_URL")
pytestmark = pytest.mark.skipif(not DATABASE_URL, reason="nema DATABASE_URL")


def test_exact_name_match() -> None:
    from travelapi import db
    from travelapi.geo.resolver import resolve

    with db.transaction() as conn:
        result = resolve(conn, "Budva")

    assert result.confident is True
    assert result.country_code == "ME"
    assert result.destination_id is not None


def test_unknown_name_creates_pending_alias() -> None:
    from travelapi import db
    from travelapi.geo.resolver import resolve

    raw_name = f"Nepostojece Mesto {uuid.uuid4().hex[:8]}"
    with db.transaction() as conn:
        result = resolve(conn, raw_name)

        pending = conn.execute(
            "SELECT status FROM destination_alias WHERE raw_name = %(raw_name)s",
            {"raw_name": raw_name},
        ).fetchone()

    assert result.confident is False
    assert result.destination_id is None
    assert pending is not None
    assert pending["status"] == "PENDING"


def test_blank_name_resolves_to_nothing_without_alias() -> None:
    from travelapi import db
    from travelapi.geo.resolver import Resolution, resolve

    with db.transaction() as conn:
        result = resolve(conn, "   ")

    assert result == Resolution(None, None, False)
