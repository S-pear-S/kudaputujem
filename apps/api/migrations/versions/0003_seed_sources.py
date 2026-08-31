"""seed sources

Revision ID: 0003
Revises: 0002
Create Date: 2026-08-31 00:00:00.000000

Izvrsava V3__seed_sources.sql doslovno preko sirovog DBAPI kursora (vidi
migrations/_raw_sql.py). Ubacuje agency/source redove za dva gotova adaptera
(soleazur-grcka, oktopod-grcka) - bez ovoga find_source() ne moze da nadje
nijedan izvor (CLAUDE.md §7/§9, ADR 0001 korak 4).
"""

from __future__ import annotations

import sys
from collections.abc import Sequence
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from _raw_sql import exec_sql_file

# revision identifiers, used by Alembic.
revision: str = "0003"
down_revision: str | Sequence[str] | None = "0002"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_SQL_FILE = Path(__file__).resolve().parents[1] / "sql" / "V3__seed_sources.sql"


def upgrade() -> None:
    exec_sql_file(_SQL_FILE)


def downgrade() -> None:
    raise NotImplementedError(
        "Migracije 'Kuda putujem' su jednosmerne. Vracanje unazad se radi rucno."
    )
