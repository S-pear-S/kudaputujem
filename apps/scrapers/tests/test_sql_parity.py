"""Provera da Python `normalize()` daje isti rezultat kao SQL `norm_text()`.

Ako se ova dva raziđu, alias tabele prestaju da pogađaju i sve se tiho raspada:
skreper upiše alias 'djerdap', a baza traži 'derdap' i ne nalazi ništa.

Test se preskače ako nema baze (npr. u brzom lokalnom pokretanju).
Pokretanje sa bazom:
    DATABASE_URL=postgresql://postgres@localhost:5432/kudaputujem pytest tests/test_sql_parity.py
"""

from __future__ import annotations

import os
import shutil
import subprocess

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

pytestmark = pytest.mark.skipif(
    not DATABASE_URL or not shutil.which("psql"),
    reason="nema DATABASE_URL ili psql nije instaliran",
)


def _sql_norm(value: str) -> str:
    result = subprocess.run(
        ["psql", DATABASE_URL, "-tAc", f"select norm_text($sql${value}$sql$);"],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


@pytest.mark.parametrize("value", CASES)
def test_python_matches_sql(value: str) -> None:
    assert normalize(value) == _sql_norm(value)
