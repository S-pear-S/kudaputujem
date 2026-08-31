"""Spaja isti hotel koji dolazi sa više sajtova pod različitim imenom.

Prevod `accommodation/AccommodationResolver.kt`, **sa jednim svesnim odstupanjem od
vernog porta** — vidi `_alias_hit()` niže i CLAUDE.md §13 (poruka 16, 31.08.2026) za puno
obrazloženje. Sve ostalo (kanonizacija imena, `fuzzy_hit`, prag sličnosti, `create`) je
prevedeno doslovno.

"Hotel Porto Matina 3*", "PORTO MATINA HOTEL" i "porto matina" su isti objekat.
Kanonizacija (`travelcore.normalize.text.canonical_accommodation_name`) skida zvezdice i
reči hotel/vila/apartmani, pa se poredi ostatak.

Prag je namerno visok i traži se ISTA destinacija i slična kategorija. Pogrešno spojen
hotel je najgori bug u ovom domenu: korisnik vidi cenu jednog, a rezerviše drugi objekat.
"""

from __future__ import annotations

import logging

import psycopg
from psycopg.types.json import Jsonb
from travelcore.enums import AliasStatus
from travelcore.models import AccommodationIn
from travelcore.normalize.text import canonical_accommodation_name, slugify

from .. import db

log = logging.getLogger(__name__)

SIMILARITY_THRESHOLD = 0.90


def resolve_or_create(
    conn: psycopg.Connection[db.Row],
    accommodation: AccommodationIn,
    destination_id: int | None,
    source_id: int,
) -> int | None:
    canonical = canonical_accommodation_name(accommodation.name)
    if not canonical.strip():
        return None

    alias_hit = _alias_hit(conn, canonical, source_id, destination_id, accommodation.external_id)
    if alias_hit is not None:
        return alias_hit

    fuzzy_hit = _fuzzy_hit(conn, canonical, destination_id, accommodation.stars)
    if fuzzy_hit is not None:
        _remember_alias(
            conn,
            fuzzy_hit,
            source_id,
            destination_id,
            accommodation,
            canonical,
            AliasStatus.CONFIRMED,
        )
        return fuzzy_hit

    created = _create(conn, accommodation, destination_id, canonical)
    _remember_alias(
        conn, created, source_id, destination_id, accommodation, canonical, AliasStatus.CONFIRMED
    )
    return created


def _alias_hit(
    conn: psycopg.Connection[db.Row],
    canonical: str,
    source_id: int,
    destination_id: int | None,
    external_id: str | None,
) -> int | None:
    """Kotlinov `aliasHit` traži alias SAMO po `normalized`, bez filtera po destinaciji —
    "Vila Marija" u Sitoniji i "Vila Marija" u Budvi bi postali isti `accommodation_id`.
    Ovde je poklapanje po imenu (`normalized = canonical`) namerno OGRANIČENO na istu
    destinaciju (`IS NOT DISTINCT FROM`, jer i alias i tekuća ponuda smeju imati nepoznatu
    destinaciju — NULL == NULL se tada tretira kao poklapanje, ne kao promašaj). Poklapanje
    po `external_id` OSTAJE bez destinacionog filtera — isti izvor + isti `external_id` je
    već nedvosmisleno ista stavka na sajtu agencije, destinacija tu ne dodaje informaciju.
    """
    row = conn.execute(
        """
        SELECT accommodation_id FROM accommodation_alias
        WHERE accommodation_id IS NOT NULL
          AND status = 'CONFIRMED'
          AND (
            (normalized = %(canonical)s
             AND destination_id IS NOT DISTINCT FROM %(destination_id)s)
            OR (%(external_id)s::text IS NOT NULL
                AND external_id = %(external_id)s AND source_id = %(source_id)s)
          )
        ORDER BY (source_id = %(source_id)s) DESC
        LIMIT 1
        """,
        {
            "canonical": canonical,
            "destination_id": destination_id,
            "external_id": external_id,
            "source_id": source_id,
        },
    ).fetchone()
    return row["accommodation_id"] if row else None


def _fuzzy_hit(
    conn: psycopg.Connection[db.Row],
    canonical: str,
    destination_id: int | None,
    stars: float | None,
) -> int | None:
    if destination_id is None:
        return None  # bez destinacije ne spajamo, previše rizično

    row = conn.execute(
        """
        SELECT id, similarity(norm_text(name), %(canonical)s) AS score, stars
        FROM accommodation
        WHERE destination_id = %(destination_id)s
          AND norm_text(name) %% %(canonical)s
        ORDER BY score DESC
        LIMIT 1
        """,
        {"canonical": canonical, "destination_id": destination_id},
    ).fetchone()
    if row is None or row["score"] < SIMILARITY_THRESHOLD:
        return None

    existing_stars = float(row["stars"]) if row["stars"] is not None else None
    stars_compatible = stars is None or existing_stars is None or abs(stars - existing_stars) <= 0.5
    return row["id"] if stars_compatible else None


def _create(
    conn: psycopg.Connection[db.Row],
    accommodation: AccommodationIn,
    destination_id: int | None,
    canonical: str,
) -> int:
    slug = _unique_slug(conn, slugify(accommodation.name))
    row = conn.execute(
        """
        INSERT INTO accommodation
            (destination_id, slug, name, kind, stars, address, latitude, longitude,
             distance_to_beach_m, description, amenities, images)
        VALUES
            (%(destination_id)s, %(slug)s, %(name)s, %(kind)s, %(stars)s, %(address)s,
             %(latitude)s, %(longitude)s, %(distance_to_beach_m)s, %(description)s,
             %(amenities)s, %(images)s)
        RETURNING id
        """,
        {
            "destination_id": destination_id,
            "slug": slug,
            "name": accommodation.name.strip(),
            "kind": accommodation.kind.value,
            "stars": accommodation.stars,
            "address": accommodation.address,
            "latitude": accommodation.latitude,
            "longitude": accommodation.longitude,
            "distance_to_beach_m": accommodation.distance_to_beach_m,
            "description": accommodation.description,
            "amenities": Jsonb(accommodation.amenities),
            "images": Jsonb(accommodation.images),
        },
    ).fetchone()
    if row is None:  # pragma: no cover — RETURNING id posle uspešnog INSERT-a ne izostaje
        raise RuntimeError("INSERT ... RETURNING id nije vratio red")

    accommodation_id: int = row["id"]
    log.debug(
        "Nov smeštaj '%s' -> id %d (kanonski '%s')", accommodation.name, accommodation_id, canonical
    )
    return accommodation_id


def _unique_slug(conn: psycopg.Connection[db.Row], base: str) -> str:
    candidate = base or "smestaj"
    suffix = 2
    while (
        conn.execute(
            "SELECT 1 FROM accommodation WHERE slug = %(slug)s", {"slug": candidate}
        ).fetchone()
        is not None
    ):
        candidate = f"{base}-{suffix}"
        suffix += 1
    return candidate


def _remember_alias(
    conn: psycopg.Connection[db.Row],
    accommodation_id: int,
    source_id: int,
    destination_id: int | None,
    accommodation: AccommodationIn,
    canonical: str,
    status: AliasStatus,
) -> None:
    conn.execute(
        """
        INSERT INTO accommodation_alias
            (accommodation_id, source_id, destination_id, external_id, raw_name, normalized, status)
        VALUES
            (%(accommodation_id)s, %(source_id)s, %(destination_id)s, %(external_id)s,
             %(raw_name)s, %(normalized)s, %(status)s)
        ON CONFLICT (normalized, COALESCE(source_id, 0), COALESCE(destination_id, 0)) DO NOTHING
        """,
        {
            "accommodation_id": accommodation_id,
            "source_id": source_id,
            "destination_id": destination_id,
            "external_id": accommodation.external_id,
            "raw_name": accommodation.name,
            "normalized": canonical,
            "status": status.value,
        },
    )
