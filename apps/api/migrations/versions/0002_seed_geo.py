"""seed geo

Revision ID: 0002
Revises: 0001
Create Date: 2026-08-18 17:40:39.235443

Izvrsava V2__seed_geo.sql doslovno preko sirovog DBAPI kursora - vidi
migrations/_raw_sql.py i 0001_init.py za objasnjenje.
"""

from __future__ import annotations

import sys
from collections.abc import Sequence
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from _raw_sql import exec_sql_file

# revision identifiers, used by Alembic.
revision: str = "0002"
down_revision: str | Sequence[str] | None = "0001"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_SQL_FILE = Path(__file__).resolve().parents[1] / "sql" / "V2__seed_geo.sql"


def upgrade() -> None:
    exec_sql_file(_SQL_FILE)


def downgrade() -> None:
    raise NotImplementedError(
        "Migracije 'Kuda putujem' su jednosmerne. Vracanje unazad se radi rucno."
    )
