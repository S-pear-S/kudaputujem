"""Provera da Python `normalize()` daje isti rezultat kao SQL `norm_text()`.

Ako se ova dva raziđu, alias tabele prestaju da pogađaju i sve se tiho raspada:
skreper upiše alias 'djerdap', a baza traži 'derdap' i ne nalazi ništa.

Test se preskače ako nema baze (npr. u brzom lokalnom pokretanju).
Pokretanje sa bazom (`docker compose up -d postgres`, šema već primenjena):
    set DATABASE_URL=postgresql://kudaputujem:promeni_me@localhost:5432/kudaputujem
    pytest tests/test_sql_parity.py
"""

from __future__ import annotations

import os
from collections.abc import Iterator

import psycopg
import pytest
from travelcore.normalize.text import normalize

CASES = [
    "Čačak",
    "Đerdap",
    "Đenovići",
    "Vrnjačka Banja",
    "HOTEL  Porto   Matina",
    "Sitonija-Halkidiki",
    "Šarm el Šeik",
    "1/2 + 1",
    "Nei Pori",
    "Žabljak",
    "Ćuprija",
    "Beograd",
    "Hotel  Blue   Sea 4*",
]

DATABASE_URL = os.environ.get("DATABASE_URL")

pytestmark = pytest.mark.skipif(not DATABASE_URL, reason="nema DATABASE_URL")


@pytest.fixture(scope="module")
def db_connection() -> Iterator[psycopg.Connection]:
    assert DATABASE_URL is not None
    with psycopg.connect(DATABASE_URL) as conn:
        yield conn


def _sql_norm(conn: psycopg.Connection, value: str) -> str:
    with conn.cursor() as cur:
        cur.execute("select norm_text(%s)", (value,))
        row = cur.fetchone()
        assert row is not None
        result: str = row[0]
        return result


@pytest.mark.parametrize("value", CASES)
def test_python_matches_sql(db_connection: psycopg.Connection, value: str) -> None:
    assert normalize(value) == _sql_norm(db_connection, value)
