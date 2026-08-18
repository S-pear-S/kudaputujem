"""Alembic env.py — ADR 0001 korak 2.

Revizije rade `op.execute()` nad `.sql` fajlovima iz `migrations/sql/`, ne
ORM modelima — nema `target_metadata`, autogenerate se ne koristi.

`sqlalchemy.url` se NAMERNO ne piše u `alembic.ini` — čita se iz `DATABASE_URL`
promenljive okruženja, isti izvor kao skreperi (`travelscrape.core.ingest`) i
`test_sql_parity.py`. Jedna kopija konekcionog stringa, ne dve koje mogu da
se raziđu.
"""

from __future__ import annotations

import os
from logging.config import fileConfig

from alembic import context
from sqlalchemy import engine_from_config, pool

config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

database_url = os.environ.get("DATABASE_URL")
if not database_url:
    raise RuntimeError(
        "DATABASE_URL nije postavljen. Primer: "
        "set DATABASE_URL=postgresql://kudaputujem:promeni_me@localhost:5432/kudaputujem"
    )
# SQLAlchemy bez eksplicitnog drajvera u sablonu 'postgresql://' podrazumeva
# psycopg2 (koji projekat ne koristi - vidi ADR 0001, psycopg 3 svuda).
# DATABASE_URL svuda drugde u projektu (travelscrape, test_sql_parity.py) je
# obican 'postgresql://' jer ga psycopg 3 direktno prihvata; ovde ga
# prepravljamo samo za SQLAlchemy-ev dialect lookup, string ostaje isti izvor.
if database_url.startswith("postgresql://"):
    database_url = database_url.replace("postgresql://", "postgresql+psycopg://", 1)
config.set_main_option("sqlalchemy.url", database_url)

# Revizije su raw SQL (op.execute), ne ORM — autogenerate se ne koristi.
target_metadata = None


def run_migrations_offline() -> None:
    """`alembic upgrade head --sql` — emituje SQL bez konekcije na bazu."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)
        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
