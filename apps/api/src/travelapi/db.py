"""psycopg 3 connection pool — zamena za Kotlinov `JdbcClient`/Hikari.

Raw SQL, bez ORM-a (§3 tabela, isti princip kao Kotlin). `numeric` iz Postgresa stiže
kao `Decimal` (psycopg 3 default mapiranje), nikad `float` — pravilo 3.

## `pool.connection()` je već tačno jedna transakcija

`psycopg_pool.ConnectionPool.connection()` uvija `with conn:` (`Connection.__exit__`),
što COMMIT-uje pri čistom izlasku i ROLLBACK-uje pri izuzetku — vidi `psycopg_pool/pool.py`,
provereno čitanjem izvora pre nego što se na to osloni bilo koji pozivalac. Zato je
`transaction()` ovde samo čitljivo ime za `pool.connection()`, ne nova transakciona
semantika: **jedan `with transaction() as conn:` blok = jedna transakcija.** Kad
`OfferWriter` (korak 4, sledeći deo) upisuje ponude jednu po jednu unutar sopstvenog
`with transaction():` bloka po ponudi, loša ponuda rollback-uje SAMO svoju transakciju —
prethodno komitovane ponude u istom batch-u ostaju upisane. Isto ponašanje kao Kotlin
`@Transactional fun write(offer: OfferIn, ...)` (jedna Spring transakcija po pozivu).

## Zašto lenji singleton, ne otvaranje pri importu

Pool se pravi tek na prvi `get_pool()` poziv, ne na `import travelapi.db`. Da se otvara
pri importu, svaki test/skripta koji uvozi bilo šta iz `travelapi` bi zahtevao živu bazu
i pravio konekciju i kad testira nešto što bazu uopšte ne dodiruje (npr. `test_occupancy.py`).
"""

from __future__ import annotations

from collections.abc import Iterator
from contextlib import contextmanager
from typing import Any, cast

import psycopg
from psycopg.rows import dict_row
from psycopg_pool import ConnectionPool

from .config import settings

# Runtime red je dict[str, Any] (row_factory=dict_row, ispod). ConnectionPool ne prati
# tip reda kroz sopstveni generic parametar bez connection_class=Connection[Row], što bi
# tražilo da se subskriptovan generic prosledi kao pozivljiva klasa psycopg_pool-u — rizičnije
# za runtime nego cast na granici u transaction(). Zato je pool ovde tipiziran sa Any, a
# transaction() vraća tačan tip preko cast-a (informiše mypy o poznatoj činjenici, ne
# zaobilazi proveru tipa strane biblioteke — pravilo 18 govori o Optional koji NE možemo
# opovrgnuti; ovde je red POUZDANO dict jer smo ga sami tako konfigurisali).
Row = dict[str, Any]

_pool: ConnectionPool[psycopg.Connection[Any]] | None = None


def get_pool() -> ConnectionPool[psycopg.Connection[Any]]:
    global _pool
    if _pool is None:
        _pool = ConnectionPool(
            conninfo=settings.database_url,
            min_size=1,
            max_size=10,
            kwargs={"row_factory": dict_row},
            open=True,
        )
    return _pool


def close_pool() -> None:
    """Zatvara pool. Poziva se pri gašenju aplikacije (FastAPI lifespan) i posle testova."""
    global _pool
    if _pool is not None:
        _pool.close()
        _pool = None


@contextmanager
def transaction() -> Iterator[psycopg.Connection[Row]]:
    """Jedna konekcija iz pool-a = jedna transakcija. Vidi docstring modula."""
    with get_pool().connection() as conn:
        yield cast("psycopg.Connection[Row]", conn)
