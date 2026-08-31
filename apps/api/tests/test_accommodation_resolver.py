"""`AccommodationResolver` — ADR 0001 korak 4, poruka 16 (31.08.2026): svesno odstupanje
od vernog Kotlin porta, ne prenete zamke kao svuda drugde u ovom portu.

Kotlinov `aliasHit` traži alias SAMO po `normalized`, bez filtera po destinaciji — "Vila
Marija" u Sitoniji i "Vila Marija" u Budvi bi postali isti `accommodation_id`, i cene dva
različita hotela bi se tiho spojile. Prvi test ispod PADA na toj staroj upitnoj formi —
provereno pre pisanja `resolver.py` (privremeni skript van repoa, kopija starog upita,
`id_budva == id_sitonija == 1`) — i prolazi na ispravci sa `destination_id` filterom.
Vidi `apps/api/migrations/sql/V4__accommodation_alias_destination.sql` i CLAUDE.md §13.
"""

from __future__ import annotations

import os
import uuid

import pytest
from travelcore.models import AccommodationIn

DATABASE_URL = os.environ.get("DATABASE_URL")
pytestmark = pytest.mark.skipif(not DATABASE_URL, reason="nema DATABASE_URL")

_BUDVA_ID = 47
_SITONIJA_ID = 71


@pytest.fixture
def source_id() -> int:
    from travelapi.crawl.service import find_source

    return find_source("soleazur-grcka").id


def test_same_name_different_destinations_creates_two_accommodations(source_id: int) -> None:
    from travelapi import db
    from travelapi.accommodation.resolver import resolve_or_create

    name = f"Vila Marija Test {uuid.uuid4().hex[:8]}"
    with db.transaction() as conn:
        id_budva = resolve_or_create(conn, AccommodationIn(name=name), _BUDVA_ID, source_id)
        id_sitonija = resolve_or_create(conn, AccommodationIn(name=name), _SITONIJA_ID, source_id)

    assert id_budva is not None
    assert id_sitonija is not None
    assert id_budva != id_sitonija


def test_same_name_same_destination_reuses_accommodation(source_id: int) -> None:
    from travelapi import db
    from travelapi.accommodation.resolver import resolve_or_create

    name = f"Ridos House Test {uuid.uuid4().hex[:8]}"
    with db.transaction() as conn:
        first = resolve_or_create(conn, AccommodationIn(name=name), _SITONIJA_ID, source_id)
    with db.transaction() as conn:
        second = resolve_or_create(conn, AccommodationIn(name=name), _SITONIJA_ID, source_id)

    assert first is not None
    assert first == second
