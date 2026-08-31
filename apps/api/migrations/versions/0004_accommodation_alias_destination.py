"""accommodation_alias destination_id

Revision ID: 0004
Revises: 0003
Create Date: 2026-08-31 00:00:00.000000

Izvrsava V4__accommodation_alias_destination.sql doslovno preko sirovog DBAPI kursora
(vidi migrations/_raw_sql.py). Dodaje destination_id koloni accommodation_alias i menja
unique indeks da uracuna destinaciju - ispravka AccommodationResolver.aliasHit propusta
(CLAUDE.md SS13, ADR 0001 korak 4, poruka 16). Tabela je prazna, nijedan red se ne dira.
"""

from __future__ import annotations

import sys
from collections.abc import Sequence
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from _raw_sql import exec_sql_file

# revision identifiers, used by Alembic.
revision: str = "0004"
down_revision: str | Sequence[str] | None = "0003"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

_SQL_FILE = Path(__file__).resolve().parents[1] / "sql" / "V4__accommodation_alias_destination.sql"


def upgrade() -> None:
    exec_sql_file(_SQL_FILE)


def downgrade() -> None:
    raise NotImplementedError(
        "Migracije 'Kuda putujem' su jednosmerne. Vracanje unazad se radi rucno."
    )
