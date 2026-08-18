"""init

Revision ID: 0001
Revises:
Create Date: 2026-08-18 17:40:38.236695

Izvrsava V1__init.sql doslovno preko sirovog DBAPI kursora (vidi
migrations/_raw_sql.py za razlog - psycopg 3 puca na bukvalnom '%' kad
SQLAlchemy prosledi prazne parametre). Sadrzaj fajla se ne dira - ADR 0001
korak 2 zahteva da migracija bude bit-za-bit isti SQL kao Flyway V1__init.sql.
"""

from __future__ import annotations

import sys
from collections.abc import Sequence
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from _raw_sql import exec_sql_file

# revision identifiers, used by Alembic.
revision: str = "0001"
down_revision: str | Sequence[str] | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_SQL_FILE = Path(__file__).resolve().parents[1] / "sql" / "V1__init.sql"


def upgrade() -> None:
    exec_sql_file(_SQL_FILE)


def downgrade() -> None:
    # Migracije su jednosmerne (CLAUDE.md ADR 0001, korak 2). Namerno nema
    # DROP SCHEMA public CASCADE - to je noz koji jednom omane i obrise pravu
    # bazu. Vracanje unazad se radi rucno, sa punom paznjom, ne automatski.
    raise NotImplementedError(
        "Migracije 'Kuda putujem' su jednosmerne. Vracanje unazad se radi rucno."
    )
