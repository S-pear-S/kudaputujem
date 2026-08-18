#!/usr/bin/env python3
"""Generiše SQL migraciju sa kanonskom geografijom iz db/seed/geo.yaml.

Pokretanje:
    python apps/api/scripts/gen_geo_seed.py

Izlaz:
    apps/api/migrations/sql/V2__seed_geo.sql

Migracija je idempotentna (ON CONFLICT DO UPDATE), pa se sme regenerisati i
ponovo primeniti preko alembic revizije 0002 (op.execute) kad se geo.yaml
proširi (ADR 0001 korak 2 — pre toga je ovo bio Flyway put, `flyway repair`).
"""

from __future__ import annotations

import io
import re
import sys
import unicodedata
from pathlib import Path
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parents[1]
SEED = ROOT / "src/main/resources/db/seed/geo.yaml"
OUT = ROOT / "migrations/sql/V2__seed_geo.sql"

# Srpska latinica -> ASCII. unicodedata sam ne rešava đ/Đ.
TRANSLIT = {
    "č": "c", "ć": "c", "ž": "z", "š": "s", "đ": "dj",
    "Č": "C", "Ć": "C", "Ž": "Z", "Š": "S", "Đ": "Dj",
}


def deaccent(text: str) -> str:
    for src, dst in TRANSLIT.items():
        text = text.replace(src, dst)
    decomposed = unicodedata.normalize("NFKD", text)
    return "".join(ch for ch in decomposed if not unicodedata.combining(ch))


def slugify(text: str) -> str:
    return re.sub(r"-+", "-", re.sub(r"[^a-z0-9]+", "-", deaccent(text).lower())).strip("-")


def normalize(text: str) -> str:
    """Mora da daje isti rezultat kao SQL funkcija norm_text()."""
    return re.sub(r"[^a-z0-9]+", " ", deaccent(text).lower()).strip()


def q(value: Any) -> str:
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    return "'" + str(value).replace("'", "''") + "'"


class Emitter:
    def __init__(self) -> None:
        self.lines: list[str] = []
        self.slugs: set[str] = set()
        self.aliases: dict[str, str] = {}  # normalized -> slug (prvi pobeđuje)
        self.count = 0

    def unique_slug(self, base: str, country: str) -> str:
        slug = base
        if slug in self.slugs:
            slug = f"{base}-{country.lower()}"
        n = 2
        while slug in self.slugs:
            slug = f"{base}-{country.lower()}-{n}"
            n += 1
        self.slugs.add(slug)
        return slug

    def destination(
        self,
        *,
        slug: str,
        parent_slug: str | None,
        kind: str,
        name_sr: str,
        name_en: str | None,
        country: str,
        departure_hub: bool,
        ski: bool,
        popularity: int,
    ) -> None:
        parent = (
            "NULL"
            if parent_slug is None
            else f"(SELECT id FROM destination WHERE slug = {q(parent_slug)})"
        )
        self.lines.append(
            "INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, "
            "is_departure_hub, is_ski, popularity)\n"
            f"VALUES ({q(slug)}, {parent}, {q(kind)}, {q(name_sr)}, {q(name_en)}, {q(country)}, "
            f"{q(departure_hub)}, {q(ski)}, {popularity})\n"
            "ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, "
            "name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, "
            "is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, "
            "popularity = EXCLUDED.popularity, updated_at = now();"
        )
        self.count += 1

    def alias(self, raw: str, dest_slug: str) -> None:
        norm = normalize(raw)
        if not norm or norm in self.aliases:
            return
        self.aliases[norm] = dest_slug
        self.lines.append(
            "INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)\n"
            f"VALUES ((SELECT id FROM destination WHERE slug = {q(dest_slug)}), NULL, "
            f"{q(raw)}, {q(norm)}, 'CONFIRMED')\n"
            "ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;"
        )


def walk(emitter: Emitter, node: dict, country: str, parent_slug: str | None, depth: int) -> None:
    name_sr = node["name_sr"]
    kind = node.get("kind", "COUNTRY")
    slug = emitter.unique_slug(slugify(name_sr), country)
    # Popularnost pada sa dubinom; ručno se dotera kasnije iz analitike pretrage.
    popularity = max(0, 100 - depth * 20)

    emitter.destination(
        slug=slug,
        parent_slug=parent_slug,
        kind=kind,
        name_sr=name_sr,
        name_en=node.get("name_en"),
        country=country,
        departure_hub=bool(node.get("departure_hub")),
        ski=bool(node.get("ski")),
        popularity=popularity,
    )

    emitter.alias(name_sr, slug)
    if node.get("name_en"):
        emitter.alias(node["name_en"], slug)
    for raw in node.get("aliases") or []:
        emitter.alias(raw, slug)

    for child in node.get("children") or []:
        walk(emitter, child, country, slug, depth + 1)


def main() -> int:
    data = yaml.safe_load(io.open(SEED, encoding="utf-8"))
    emitter = Emitter()

    for country_code, node in data.items():
        node = dict(node)
        node.setdefault("kind", "COUNTRY")
        walk(emitter, node, country_code, None, 0)

    header = (
        "-- =====================================================================\n"
        "-- GENERISANO IZ db/seed/geo.yaml — NE MENJATI RUČNO.\n"
        "-- Regeneracija: python apps/api/scripts/gen_geo_seed.py\n"
        f"-- Destinacija: {emitter.count}, aliasa: {len(emitter.aliases)}\n"
        "-- =====================================================================\n"
    )
    OUT.parent.mkdir(parents=True, exist_ok=True)
    io.open(OUT, "w", encoding="utf-8").write(header + "\n" + "\n".join(emitter.lines) + "\n")
    print(f"{OUT}: {emitter.count} destinacija, {len(emitter.aliases)} aliasa")
    return 0


if __name__ == "__main__":
    sys.exit(main())
