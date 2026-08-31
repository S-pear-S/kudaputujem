"""Mapira sirovo ime destinacije sa sajta agencije na kanonsku destinaciju.

Prevod `geo/DestinationResolver.kt`. Postupak, redom:
    1. tačno poklapanje u `destination_alias` (normalizovan oblik)
    2. tačno poklapanje imena destinacije
    3. trigram sličnost iznad praga, uz istu zemlju ako je poznata
    4. ništa — pravi se PENDING alias koji čeka ručnu potvrdu

Korak 4 je namerno. Automatsko spajanje ispod praga bi spojilo "Sveti Stefan" (Crna Gora)
i "Sveti Vlas" (Bugarska), i korisnik bi rezervisao pogrešnu državu. Duplikat je ružan,
pogrešno spajanje je štetno. Vidi §4.5.

Funkcije primaju `conn` umesto da same otvaraju transakciju — pozivalac (`OfferWriter`,
korak 4 sledeći deo) upisuje celu ponudu u JEDNOJ transakciji (§9, `pool.connection()` je
već tačno jedna transakcija), a `DestinationResolver`/`AccommodationResolver` su unutrašnji
koraci tog upisa, ne sopstvene transakcione granice — isto ponašanje kao Kotlinov
`@Transactional` na ugnježdenom pozivu (REQUIRED propagacija se pridružuje spoljnoj).
"""

from __future__ import annotations

import logging
from dataclasses import dataclass

import psycopg
from travelcore.enums import AliasStatus
from travelcore.normalize.text import normalize

from .. import db

log = logging.getLogger(__name__)

SIMILARITY_THRESHOLD = 0.82
"""Ispod ovoga ne spajamo automatski. Dobijeno testiranjem na stvarnim imenima (Kotlin)."""


@dataclass(frozen=True)
class Resolution:
    destination_id: int | None
    country_code: str | None
    confident: bool


def resolve(
    conn: psycopg.Connection[db.Row],
    raw_name: str | None,
    *,
    country_hint: str | None = None,
    source_id: int | None = None,
) -> Resolution:
    if not raw_name or not raw_name.strip():
        return Resolution(None, None, False)

    normalized = normalize(raw_name)
    if not normalized:
        return Resolution(None, None, False)

    hit = _exact_alias(conn, normalized, source_id)
    if hit is not None:
        return hit

    hit = _exact_name(conn, normalized)
    if hit is not None:
        return hit

    hit = _fuzzy(conn, normalized, country_hint)
    if hit is not None and hit.destination_id is not None:
        _remember_alias(
            conn, hit.destination_id, source_id, raw_name, normalized, AliasStatus.CONFIRMED
        )
        return hit

    log.info("Nepoznata destinacija '%s' (izvor %s), upisujem kao PENDING", raw_name, source_id)
    _remember_alias(conn, None, source_id, raw_name, normalized, AliasStatus.PENDING)
    return Resolution(None, country_hint, False)


def resolve_departure_hub(conn: psycopg.Connection[db.Row], raw_name: str | None) -> int | None:
    """Mesta polaska u Srbiji — koriste ih i ingest i autocomplete na frontendu."""
    if not raw_name or not raw_name.strip():
        return None
    normalized = normalize(raw_name)
    row = conn.execute(
        """
        SELECT id FROM destination
        WHERE is_departure_hub AND norm_text(name_sr) = %(normalized)s
        LIMIT 1
        """,
        {"normalized": normalized},
    ).fetchone()
    return row["id"] if row else None


def _exact_alias(
    conn: psycopg.Connection[db.Row], normalized: str, source_id: int | None
) -> Resolution | None:
    row = conn.execute(
        """
        SELECT d.id, d.country_code
        FROM destination_alias a
        JOIN destination d ON d.id = a.destination_id
        WHERE a.normalized = %(normalized)s
          AND a.status = 'CONFIRMED'
          AND (a.source_id IS NULL OR a.source_id = %(source_id)s)
        ORDER BY a.source_id NULLS LAST
        LIMIT 1
        """,
        {"normalized": normalized, "source_id": source_id},
    ).fetchone()
    if row is None:
        return None
    return Resolution(row["id"], row["country_code"], True)


def _exact_name(conn: psycopg.Connection[db.Row], normalized: str) -> Resolution | None:
    row = conn.execute(
        """
        SELECT id, country_code FROM destination
        WHERE norm_text(name_sr) = %(normalized)s AND is_active
        ORDER BY popularity DESC
        LIMIT 1
        """,
        {"normalized": normalized},
    ).fetchone()
    if row is None:
        return None
    return Resolution(row["id"], row["country_code"], True)


def _fuzzy(
    conn: psycopg.Connection[db.Row], normalized: str, country_hint: str | None
) -> Resolution | None:
    row = conn.execute(
        """
        SELECT id, country_code, similarity(norm_text(name_sr), %(normalized)s) AS score
        FROM destination
        WHERE is_active
          AND (%(country)s::char(2) IS NULL OR country_code = %(country)s)
          AND norm_text(name_sr) %% %(normalized)s
        ORDER BY score DESC, popularity DESC
        LIMIT 1
        """,
        {"normalized": normalized, "country": country_hint},
    ).fetchone()
    if row is None or row["score"] < SIMILARITY_THRESHOLD:
        return None
    return Resolution(row["id"], row["country_code"], True)


def _remember_alias(
    conn: psycopg.Connection[db.Row],
    destination_id: int | None,
    source_id: int | None,
    raw_name: str,
    normalized: str,
    status: AliasStatus,
) -> None:
    conn.execute(
        """
        INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
        VALUES (%(destination_id)s, %(source_id)s, %(raw_name)s, %(normalized)s, %(status)s)
        ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING
        """,
        {
            "destination_id": destination_id,
            "source_id": source_id,
            "raw_name": raw_name,
            "normalized": normalized,
            "status": status.value,
        },
    )
