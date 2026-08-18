"""Deljeni pomocnik za revizije koje izvrsavaju ceo .sql fajl doslovno.

`op.execute()` / `Connection.exec_driver_sql()` i dalje idu kroz SQLAlchemy-ev
DBAPI poziv `cursor.execute(statement, parameters)` sa praznim `parameters`.
psycopg 3 tada parsira upit kao da MOZE imati `%`-placeholdere i puca na
svakom bukvalnom `%` u SQL-u (npr. komentar `"-20%"` u V1__init.sql - vidi
CLAUDE.md §9). Resenje: sirovi DBAPI kursor, `cursor.execute(sql)` sa TACNO
jednim argumentom - isti poziv koji koristi `psql` i koji psycopg 3 tretira
kao doslovan tekst bez parsiranja placeholder-a.
"""

from __future__ import annotations

from pathlib import Path

from alembic import op


def exec_sql_file(path: Path) -> None:
    sql = path.read_text(encoding="utf-8")
    raw_connection = op.get_bind().connection
    cursor = raw_connection.cursor()
    cursor.execute(sql)
    cursor.close()
