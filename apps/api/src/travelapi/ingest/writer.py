"""Upisuje jednu ponudu sa svim terminima i cenama — prevod `ingest/OfferWriter.kt`.

## Zašto se termini i cene BRIŠU pa ponovo upisuju

Cena i termin nemaju stabilan identitet na sajtu agencije — danas je red "1/2 349", sutra
"1/2 359", i to je ista stvar sa novom vrednošću, a ne nova stvar. Diff-ovanje bi tražilo
veštački ključ koji agencija ne daje. Brisanje i ponovni upis je jednostavnije, brže u
batch-u, i nema rizik od "duh" redova koji ostanu iz prethodne runde.

Ponuda se NE briše, jer ona ima stabilan `external_id`, SEO stranicu i istoriju.

## Zašto nema `offer.validate()` poziva kao u Kotlinu

Kotlinov `OfferIn` je Jackson DTO — jakarta bean-validacija (`@field:NotBlank` i sl.) se
pokreće automatski pri deserijalizaciji, ali pravila koja zavise od VIŠE polja (datum
povratka pre datuma polaska, aranžman bez termina/smeštaja) nisu pokrivena anotacijama,
pa `OfferWriter.write()` mora eksplicitno da pozove `offer.validate()`. Python `OfferIn`/
`DepartureIn` (pydantic, `travelcore.models`) imaju ta ista pravila kao `@model_validator`,
koji se pokreće automatski PRI KONSTRUKCIJI — dakle i pri parsiranju HTTP tela u FastAPI-ju.
Do trenutka kad `write()` dobije `offer: OfferIn`, ta pravila su već zagarantovano
zadovoljena; drugi poziv bi bio mrtav kod, ne dodatna sigurnost.

## Transakcija po ponudi

`write()` otvara SVOJU `db.transaction()` — jedan poziv ove funkcije je jedna transakcija
(§9, `pool.connection()` je već tačno jedna transakcija). Poziva iz `ingest/service.py`
hvata izuzetak po ponudi, pa jedna loša ponuda rollback-uje samo svoju transakciju;
prethodno komitovane ponude u istom batch-u ostaju upisane.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum, auto

import psycopg
from psycopg.types.json import Jsonb
from travelcore.enums import PriceSlot
from travelcore.models import DepartureIn, OfferIn, PriceIn, SurchargeIn, TransportLegIn
from travelcore.normalize.text import slugify

from .. import db
from ..accommodation.resolver import resolve_or_create as resolve_accommodation
from ..geo.resolver import Resolution, resolve_departure_hub
from ..geo.resolver import resolve as resolve_destination


class Outcome(Enum):
    CREATED = auto()
    UPDATED = auto()
    UNCHANGED = auto()


@dataclass(frozen=True)
class WriteResult:
    offer_id: int
    outcome: Outcome


def write(offer: OfferIn, source_id: int, agency_id: int) -> WriteResult:
    with db.transaction() as conn:
        destination = resolve_destination(conn, offer.destination_raw, source_id=source_id)
        accommodation_id: int | None = None
        if offer.accommodation is not None:
            accommodation_id = resolve_accommodation(
                conn, offer.accommodation, destination.destination_id, source_id
            )

        content_hash = offer.content_hash()
        existing = conn.execute(
            "SELECT id, content_hash FROM offer WHERE source_id = %(source_id)s "
            "AND external_id = %(external_id)s",
            {"source_id": source_id, "external_id": offer.external_id},
        ).fetchone()

        if existing is not None and existing["content_hash"] == content_hash:
            offer_id: int = existing["id"]
            _touch(conn, offer_id)
            return WriteResult(offer_id, Outcome.UNCHANGED)

        offer_id = _upsert_offer(
            conn, offer, source_id, agency_id, destination, accommodation_id, content_hash
        )
        _replace_children(conn, offer_id, offer)
        _refresh_denormalized_columns(conn, offer_id)

    return WriteResult(offer_id, Outcome.CREATED if existing is None else Outcome.UPDATED)


# ------------------------------------------------------------------ ponuda


def _upsert_offer(
    conn: psycopg.Connection[db.Row],
    offer: OfferIn,
    source_id: int,
    agency_id: int,
    destination: Resolution,
    accommodation_id: int | None,
    content_hash: str,
) -> int:
    row = conn.execute(
        """
        INSERT INTO offer (
            source_id, agency_id, external_id, product_kind, title, slug, url,
            accommodation_id, destination_id, country_code, transport_type, board_type,
            description, images, highlights, included, not_included, raw_attributes,
            currency, content_hash, is_active, last_seen_at, last_changed_at
        ) VALUES (
            %(source_id)s, %(agency_id)s, %(external_id)s, %(product_kind)s, %(title)s,
            %(slug)s, %(url)s, %(accommodation_id)s, %(destination_id)s, %(country_code)s,
            %(transport_type)s, %(board_type)s, %(description)s, %(images)s, %(highlights)s,
            %(included)s, %(not_included)s, %(raw_attributes)s, %(currency)s,
            %(content_hash)s, TRUE, now(), now()
        )
        ON CONFLICT (source_id, external_id) DO UPDATE SET
            product_kind = EXCLUDED.product_kind,
            title = EXCLUDED.title,
            slug = EXCLUDED.slug,
            url = EXCLUDED.url,
            accommodation_id = COALESCE(EXCLUDED.accommodation_id, offer.accommodation_id),
            destination_id = COALESCE(EXCLUDED.destination_id, offer.destination_id),
            country_code = COALESCE(EXCLUDED.country_code, offer.country_code),
            transport_type = EXCLUDED.transport_type,
            board_type = EXCLUDED.board_type,
            description = EXCLUDED.description,
            images = EXCLUDED.images,
            highlights = EXCLUDED.highlights,
            included = EXCLUDED.included,
            not_included = EXCLUDED.not_included,
            raw_attributes = EXCLUDED.raw_attributes,
            currency = EXCLUDED.currency,
            content_hash = EXCLUDED.content_hash,
            is_active = TRUE,
            last_seen_at = now(),
            last_changed_at = now(),
            updated_at = now()
        RETURNING id
        """,
        {
            "source_id": source_id,
            "agency_id": agency_id,
            "external_id": offer.external_id,
            "product_kind": offer.product_kind.value,
            "title": offer.title,
            "slug": slugify(offer.title),
            "url": offer.url,
            "accommodation_id": accommodation_id,
            "destination_id": destination.destination_id,
            "country_code": destination.country_code,
            "transport_type": offer.transport_type.value,
            "board_type": offer.board_type.value,
            "description": offer.description,
            "images": Jsonb(offer.images),
            "highlights": Jsonb(offer.highlights),
            "included": Jsonb(offer.included),
            "not_included": Jsonb(offer.not_included),
            "raw_attributes": Jsonb(offer.raw_attributes),
            "currency": offer.currency,
            "content_hash": content_hash,
        },
    ).fetchone()
    if row is None:  # pragma: no cover — INSERT ... ON CONFLICT ... RETURNING uvek vraća red
        raise RuntimeError("upsert offer nije vratio red")
    upserted_id: int = row["id"]
    return upserted_id


def _touch(conn: psycopg.Connection[db.Row], offer_id: int) -> None:
    conn.execute(
        "UPDATE offer SET last_seen_at = now(), is_active = TRUE WHERE id = %(id)s",
        {"id": offer_id},
    )
    conn.execute(
        "UPDATE departure SET last_seen_at = now() WHERE offer_id = %(id)s", {"id": offer_id}
    )


# ------------------------------------------------------------------ termini i cene


def _replace_children(conn: psycopg.Connection[db.Row], offer_id: int, offer: OfferIn) -> None:
    # CASCADE briše price_option, surcharge i transport_leg vezane za termine.
    conn.execute("DELETE FROM departure WHERE offer_id = %(offer_id)s", {"offer_id": offer_id})
    conn.execute(
        "DELETE FROM surcharge WHERE offer_id = %(offer_id)s AND departure_id IS NULL",
        {"offer_id": offer_id},
    )

    for surcharge in offer.surcharges:
        _insert_surcharge(conn, offer_id, None, surcharge, offer.currency)

    for departure in offer.departures:
        departure_id = _insert_departure(conn, offer_id, departure, offer)
        for price in departure.prices:
            _insert_price(conn, offer_id, departure_id, price, offer.currency)
        for surcharge in departure.surcharges:
            _insert_surcharge(conn, offer_id, departure_id, surcharge, offer.currency)
        for leg in departure.legs:
            _insert_leg(conn, offer_id, departure_id, leg)


def _insert_departure(
    conn: psycopg.Connection[db.Row], offer_id: int, departure: DepartureIn, offer: OfferIn
) -> int:
    min_price = min(
        (p.amount for p in departure.prices if p.slot in (PriceSlot.ADULT, PriceSlot.UNIT)),
        default=None,
    )
    board_type = departure.board_type or offer.board_type

    row = conn.execute(
        """
        INSERT INTO departure (
            offer_id, external_id, start_date, end_date, nights, days,
            transport_type, departure_place_id, departure_place_raw, board_type,
            is_available, seats_left, is_last_minute, min_price, currency, last_seen_at
        ) VALUES (
            %(offer_id)s, %(external_id)s, %(start_date)s, %(end_date)s, %(nights)s, %(days)s,
            %(transport_type)s, %(departure_place_id)s, %(departure_place_raw)s, %(board_type)s,
            %(is_available)s, %(seats_left)s, %(is_last_minute)s, %(min_price)s, %(currency)s,
            now()
        )
        RETURNING id
        """,
        {
            "offer_id": offer_id,
            "external_id": departure.external_id,
            "start_date": departure.start_date,
            "end_date": departure.end_date,
            "nights": departure.nights,
            "days": departure.days,
            "transport_type": departure.transport_type.value,
            "departure_place_id": resolve_departure_hub(conn, departure.departure_place_raw),
            "departure_place_raw": departure.departure_place_raw,
            "board_type": board_type.value,
            "is_available": departure.is_available,
            "seats_left": departure.seats_left,
            "is_last_minute": departure.is_last_minute,
            "min_price": min_price,
            "currency": offer.currency,
        },
    ).fetchone()
    if row is None:  # pragma: no cover — INSERT ... RETURNING uvek vraća red
        raise RuntimeError("insert departure nije vratio red")
    departure_id: int = row["id"]
    return departure_id


def _insert_price(
    conn: psycopg.Connection[db.Row],
    offer_id: int,
    departure_id: int,
    price: PriceIn,
    fallback_currency: str,
) -> None:
    conn.execute(
        """
        INSERT INTO price_option (
            departure_id, offer_id, room_code, room_name, capacity_adults, capacity_extra,
            capacity_total, slot, pricing_basis, board_type, child_age_from, child_age_to,
            amount, currency, original_amount, discount_label, is_promo, min_stay_nights, notes
        ) VALUES (
            %(departure_id)s, %(offer_id)s, %(room_code)s, %(room_name)s, %(capacity_adults)s,
            %(capacity_extra)s, %(capacity_total)s, %(slot)s, %(pricing_basis)s, %(board_type)s,
            %(child_age_from)s, %(child_age_to)s, %(amount)s, %(currency)s, %(original_amount)s,
            %(discount_label)s, %(is_promo)s, %(min_stay_nights)s, %(notes)s
        )
        """,
        {
            "departure_id": departure_id,
            "offer_id": offer_id,
            "room_code": price.room_code,
            "room_name": price.room_name,
            "capacity_adults": price.capacity_adults,
            "capacity_extra": price.capacity_extra,
            "capacity_total": price.capacity_total,
            "slot": price.slot.value,
            "pricing_basis": price.pricing_basis.value,
            "board_type": price.board_type.value if price.board_type else None,
            "child_age_from": price.child_age_from,
            "child_age_to": price.child_age_to,
            "amount": price.amount,
            "currency": price.currency or fallback_currency,
            "original_amount": price.original_amount,
            "discount_label": price.discount_label,
            "is_promo": price.is_promo,
            "min_stay_nights": price.min_stay_nights,
            "notes": price.notes,
        },
    )


def _insert_surcharge(
    conn: psycopg.Connection[db.Row],
    offer_id: int,
    departure_id: int | None,
    surcharge: SurchargeIn,
    fallback_currency: str,
) -> None:
    conn.execute(
        """
        INSERT INTO surcharge
            (offer_id, departure_id, code, name, kind, unit, amount, currency, payable, raw_text)
        VALUES
            (%(offer_id)s, %(departure_id)s, %(code)s, %(name)s, %(kind)s, %(unit)s, %(amount)s,
             %(currency)s, %(payable)s, %(raw_text)s)
        """,
        {
            "offer_id": offer_id,
            "departure_id": departure_id,
            "code": surcharge.code.value,
            "name": surcharge.name,
            "kind": surcharge.kind.value,
            "unit": surcharge.unit.value,
            "amount": surcharge.amount,
            "currency": surcharge.currency or fallback_currency,
            "payable": surcharge.payable.value,
            "raw_text": surcharge.raw_text,
        },
    )


def _insert_leg(
    conn: psycopg.Connection[db.Row], offer_id: int, departure_id: int, leg: TransportLegIn
) -> None:
    conn.execute(
        """
        INSERT INTO transport_leg (
            offer_id, departure_id, leg_index, direction, mode, carrier_name, carrier_code,
            vehicle_number, from_place_raw, from_terminal, to_place_raw, to_terminal,
            depart_at, arrive_at, depart_local, arrive_local, duration_minutes, stops
        ) VALUES (
            %(offer_id)s, %(departure_id)s, %(leg_index)s, %(direction)s, %(mode)s,
            %(carrier_name)s, %(carrier_code)s, %(vehicle_number)s, %(from_place_raw)s,
            %(from_terminal)s, %(to_place_raw)s, %(to_terminal)s,
            CAST(%(depart_at)s AS timestamptz), CAST(%(arrive_at)s AS timestamptz),
            %(depart_local)s, %(arrive_local)s, %(duration_minutes)s, %(stops)s
        )
        """,
        {
            "offer_id": offer_id,
            "departure_id": departure_id,
            "leg_index": leg.leg_index,
            "direction": leg.direction,
            "mode": leg.mode.value,
            "carrier_name": leg.carrier_name,
            "carrier_code": leg.carrier_code,
            "vehicle_number": leg.vehicle_number,
            "from_place_raw": leg.from_place_raw,
            "from_terminal": leg.from_terminal,
            "to_place_raw": leg.to_place_raw,
            "to_terminal": leg.to_terminal,
            "depart_at": leg.depart_at,
            "arrive_at": leg.arrive_at,
            "depart_local": leg.depart_local,
            "arrive_local": leg.arrive_local,
            "duration_minutes": leg.duration_minutes,
            "stops": leg.stops,
        },
    )


def _refresh_denormalized_columns(conn: psycopg.Connection[db.Row], offer_id: int) -> None:
    """Denormalizovane kolone na `offer` koje pretraga koristi za brzo filtriranje."""
    conn.execute(
        """
        UPDATE offer o SET
            min_nights = agg.min_nights,
            max_nights = agg.max_nights,
            first_departure = agg.first_departure,
            last_departure = agg.last_departure,
            departure_count = agg.departure_count
        FROM (
            SELECT
                MIN(nights) AS min_nights,
                MAX(nights) AS max_nights,
                MIN(start_date) AS first_departure,
                MAX(start_date) AS last_departure,
                COUNT(*) AS departure_count
            FROM departure WHERE offer_id = %(offer_id)s
        ) agg
        WHERE o.id = %(offer_id)s
        """,
        {"offer_id": offer_id},
    )
