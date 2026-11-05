"""Ugovorni test — ADR 0002, obavezan deo ADR 0001 koraka 4, ne opciono.

Pravi `OfferIn` sa PUNIM sadržajem (sva polja popunjena, ne minimalan primer) mora proći
kroz pravi `POST /internal/ingest/offers` (pravi HTTP zahtev preko `TestClient`, prava
Postgres baza) i stići u bazu NEPROMENJEN. Ne mock, ne poređenje JSON šema — pravi upit nad
tabelama posle ingest-a proverava svako polje. Ovaj lanac (skreper → API → baza) nikad nije
proveren od kraja do kraja pre ADR 0002 (§9, §13) — ovo je taj test.
"""

from __future__ import annotations

import os
import uuid
from datetime import date
from decimal import Decimal

import psycopg
import pytest
from fastapi.testclient import TestClient
from travelcore.enums import (
    AccommodationKind,
    BoardType,
    Payable,
    PriceSlot,
    PricingBasis,
    ProductKind,
    SurchargeCode,
    SurchargeKind,
    SurchargeUnit,
    TransportType,
)
from travelcore.models import (
    AccommodationIn,
    DepartureIn,
    IngestBatch,
    OfferIn,
    PriceIn,
    SurchargeIn,
    TransportLegIn,
)

DATABASE_URL = os.environ.get("DATABASE_URL")
pytestmark = pytest.mark.skipif(not DATABASE_URL, reason="nema DATABASE_URL")


@pytest.fixture
def client() -> TestClient:
    from travelapi.app import app

    return TestClient(app)


def _auth_headers() -> dict[str, str]:
    from travelapi.config import settings

    return {"X-Api-Key": settings.ingest_api_key}


def _full_offer(external_id: str) -> OfferIn:
    return OfferIn(
        source_slug="soleazur-grcka",
        external_id=external_id,
        product_kind=ProductKind.PACKAGE,
        title="Ridos House — Neos Marmaras",
        url="https://soleazur.rs/hoteli/ridos-house",
        country_raw="Grčka",
        destination_raw="Sitonija",
        accommodation=AccommodationIn(
            name="Ridos House",
            kind=AccommodationKind.APARTMENT,
            stars=3.0,
            destination_raw="Sitonija",
            address="Neos Marmaras bb",
            latitude=40.09,
            longitude=23.94,
            distance_to_beach_m=150,
            description="Apartmani na prvoj liniji.",
            amenities=["klima", "wifi", "parking"],
            images=["https://example.rs/hotel-1.jpg"],
            external_id="ridos-house-1",
        ),
        transport_type=TransportType.BUS,
        board_type=BoardType.RO,
        description="Poslednja izmena za avgust.",
        images=["https://example.rs/ponuda-1.jpg", "https://example.rs/ponuda-2.jpg"],
        highlights=["blizu plaže", "klimatizovano"],
        included=["prevoz", "smeštaj"],
        not_included=["boravišna taksa", "osiguranje"],
        raw_attributes={"izvorni_kod": "RH-2026", "sezona": "leto"},
        currency="EUR",
        departures=[
            DepartureIn(
                external_id="dep-1",
                start_date=date(2026, 8, 28),
                end_date=date(2026, 9, 7),
                transport_type=TransportType.BUS,
                departure_place_raw="Beograd",
                board_type=BoardType.RO,
                is_available=True,
                seats_left=12,
                is_last_minute=True,
                prices=[
                    PriceIn(
                        room_code="1/2",
                        room_name="Studio",
                        capacity_adults=2,
                        capacity_extra=0,
                        slot=PriceSlot.ADULT,
                        pricing_basis=PricingBasis.PER_PERSON_PER_STAY,
                        amount=Decimal("349.00"),
                        currency="EUR",
                        original_amount=Decimal("399.00"),
                        discount_label="last minute",
                        is_promo=True,
                        notes="cena po osobi",
                    ),
                    PriceIn(
                        room_code="1/2+1",
                        capacity_adults=2,
                        capacity_extra=1,
                        slot=PriceSlot.CHILD,
                        pricing_basis=PricingBasis.PER_PERSON_PER_STAY,
                        child_age_from=2,
                        child_age_to=11,
                        amount=Decimal("199.00"),
                        currency="EUR",
                    ),
                ],
                surcharges=[
                    SurchargeIn(
                        code=SurchargeCode.TOURIST_TAX,
                        name="Boravišna taksa",
                        kind=SurchargeKind.MANDATORY,
                        unit=SurchargeUnit.PER_PERSON_PER_NIGHT,
                        amount=Decimal("1.50"),
                        currency="EUR",
                        payable=Payable.ON_SITE,
                        raw_text="Boravišna taksa se plaća na licu mesta.",
                    ),
                ],
                legs=[
                    TransportLegIn(
                        leg_index=0,
                        direction="OUTBOUND",
                        mode=TransportType.BUS,
                        carrier_name="Sole Azur prevoz",
                        vehicle_number="SA-101",
                        from_place_raw="Beograd",
                        from_terminal="Autobuska stanica",
                        to_place_raw="Neos Marmaras",
                        depart_local="21:00",
                        arrive_local="09:00",
                        duration_minutes=720,
                        stops=1,
                    ),
                ],
            ),
        ],
        surcharges=[
            SurchargeIn(
                code=SurchargeCode.INSURANCE,
                name="Putno osiguranje",
                kind=SurchargeKind.OPTIONAL,
                unit=SurchargeUnit.PER_PERSON,
                amount=Decimal("5.00"),
                currency="EUR",
                payable=Payable.IN_ADVANCE,
            ),
        ],
    )


def _start_run(client: TestClient) -> int:
    resp = client.post(
        "/internal/runs",
        json={"source_slug": "soleazur-grcka"},
        headers=_auth_headers(),
    )
    assert resp.status_code == 200
    run_id: int = resp.json()["run_id"]
    return run_id


def test_full_offer_ingested_unchanged(client: TestClient) -> None:
    from travelapi import db

    external_id = f"contract-test-{uuid.uuid4().hex[:8]}"
    offer = _full_offer(external_id)
    run_id = _start_run(client)

    batch = IngestBatch(run_id=run_id, source_slug=offer.source_slug, offers=[offer])
    resp = client.post(
        "/internal/ingest/offers",
        json=batch.model_dump(mode="json"),
        headers=_auth_headers(),
    )
    assert resp.status_code == 200
    result = resp.json()
    assert result == {
        "received": 1,
        "created": 1,
        "updated": 0,
        "unchanged": 0,
        "failed": 0,
        "errors": [],
    }

    with db.transaction() as conn:
        offer_row = conn.execute(
            "SELECT * FROM offer WHERE source_id = "
            "(SELECT id FROM source WHERE slug = 'soleazur-grcka') AND external_id = %(eid)s",
            {"eid": external_id},
        ).fetchone()
        assert offer_row is not None
        assert offer_row["title"] == offer.title
        assert offer_row["url"] == offer.url
        assert offer_row["product_kind"] == "PACKAGE"
        assert offer_row["transport_type"] == "BUS"
        assert offer_row["board_type"] == "RO"
        assert offer_row["description"] == offer.description
        assert offer_row["images"] == offer.images
        assert offer_row["highlights"] == offer.highlights
        assert offer_row["included"] == offer.included
        assert offer_row["not_included"] == offer.not_included
        assert offer_row["raw_attributes"] == offer.raw_attributes
        assert offer_row["currency"] == "EUR"
        assert offer_row["is_active"] is True
        assert offer_row["accommodation_id"] is not None
        assert offer_row["destination_id"] is not None
        assert str(offer_row["content_hash"]) == offer.content_hash()

        departure_row = conn.execute(
            "SELECT * FROM departure WHERE offer_id = %(oid)s", {"oid": offer_row["id"]}
        ).fetchone()
        assert departure_row is not None
        assert departure_row["start_date"] == offer.departures[0].start_date
        assert departure_row["end_date"] == offer.departures[0].end_date
        assert departure_row["nights"] == offer.departures[0].nights
        assert departure_row["seats_left"] == 12
        assert departure_row["is_last_minute"] is True
        assert str(departure_row["min_price"]) == "349.00"

        price_rows = conn.execute(
            "SELECT * FROM price_option WHERE departure_id = %(did)s ORDER BY slot",
            {"did": departure_row["id"]},
        ).fetchall()
        assert len(price_rows) == 2
        adult_price = next(r for r in price_rows if r["slot"] == "ADULT")
        assert str(adult_price["amount"]) == "349.00"
        assert str(adult_price["original_amount"]) == "399.00"
        assert adult_price["is_promo"] is True
        child_price = next(r for r in price_rows if r["slot"] == "CHILD")
        assert child_price["child_age_from"] == 2
        assert child_price["child_age_to"] == 11

        departure_surcharge = conn.execute(
            "SELECT * FROM surcharge WHERE departure_id = %(did)s", {"did": departure_row["id"]}
        ).fetchone()
        assert departure_surcharge is not None
        assert departure_surcharge["code"] == "TOURIST_TAX"
        assert str(departure_surcharge["amount"]) == "1.50"

        offer_surcharge = conn.execute(
            "SELECT * FROM surcharge WHERE offer_id = %(oid)s AND departure_id IS NULL",
            {"oid": offer_row["id"]},
        ).fetchone()
        assert offer_surcharge is not None
        assert offer_surcharge["code"] == "INSURANCE"

        leg_row = conn.execute(
            "SELECT * FROM transport_leg WHERE departure_id = %(did)s", {"did": departure_row["id"]}
        ).fetchone()
        assert leg_row is not None
        assert leg_row["carrier_name"] == "Sole Azur prevoz"
        assert leg_row["vehicle_number"] == "SA-101"
        assert leg_row["stops"] == 1

    # Isti sadržaj drugi put -> UNCHANGED, ne CREATED (content_hash detekcija).
    resp_again = client.post(
        "/internal/ingest/offers",
        json=batch.model_dump(mode="json"),
        headers=_auth_headers(),
    )
    assert resp_again.status_code == 200
    assert resp_again.json()["unchanged"] == 1
    assert resp_again.json()["created"] == 0

    # Izmenjena cena -> UPDATED.
    changed_offer = offer.model_copy(deep=True)
    changed_offer.departures[0].prices[0].amount = Decimal("359.00")
    changed_batch = IngestBatch(
        run_id=run_id, source_slug=offer.source_slug, offers=[changed_offer]
    )
    resp_changed = client.post(
        "/internal/ingest/offers",
        json=changed_batch.model_dump(mode="json"),
        headers=_auth_headers(),
    )
    assert resp_changed.status_code == 200
    assert resp_changed.json()["updated"] == 1

    finish_resp = client.post(
        f"/internal/runs/{run_id}/finish",
        json={"status": "OK", "items_found": 1, "force": True},
        headers=_auth_headers(),
    )
    assert finish_resp.status_code == 200


def test_bad_offer_does_not_roll_back_earlier_offers_in_batch(
    client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Transakcija po ponudi (§9, `db.transaction()` po pozivu `writer.write()`): jedna loša
    ponuda u batch-u rollback-uje SAMO svoju transakciju, prethodno komitovana ponuda ostaje
    upisana. Simuliramo grešku u bazi (ne grešku koju bi pydantic već odbio pri parsiranju
    HTTP tela — ta bi srušila ceo zahtev sa 422 pre nego što handler i vidi batch)."""
    from travelapi import db
    from travelapi.ingest import service as ingest_service
    from travelapi.ingest import writer

    good_id = f"contract-good-{uuid.uuid4().hex[:8]}"
    bad_id = f"contract-bad-{uuid.uuid4().hex[:8]}"
    good_offer = _full_offer(good_id)
    bad_offer = _full_offer(bad_id)

    run_id = _start_run(client)
    batch = IngestBatch(
        run_id=run_id, source_slug="soleazur-grcka", offers=[good_offer, bad_offer]
    )

    real_write = writer.write

    def flaky_write(offer: OfferIn, source_id: int, agency_id: int) -> writer.WriteResult:
        if offer.external_id == bad_id:
            raise psycopg.OperationalError("simulirana greška u bazi")
        return real_write(offer, source_id, agency_id)

    monkeypatch.setattr(writer, "write", flaky_write)

    result = ingest_service.ingest(batch)

    assert result.created == 1
    assert result.failed == 1
    assert any(bad_id in error for error in result.errors)

    with db.transaction() as conn:
        good_row = conn.execute(
            "SELECT id FROM offer WHERE source_id = "
            "(SELECT id FROM source WHERE slug = 'soleazur-grcka') AND external_id = %(eid)s",
            {"eid": good_id},
        ).fetchone()
        assert good_row is not None, "dobra ponuda mora ostati upisana i posle greške na drugoj"

        bad_row = conn.execute(
            "SELECT id FROM offer WHERE source_id = "
            "(SELECT id FROM source WHERE slug = 'soleazur-grcka') AND external_id = %(eid)s",
            {"eid": bad_id},
        ).fetchone()
        assert bad_row is None, "loša ponuda ne sme da bude upisana"


def test_dry_run_does_not_write(client: TestClient) -> None:
    from travelapi import db

    external_id = f"contract-dryrun-{uuid.uuid4().hex[:8]}"
    offer = _full_offer(external_id)
    run_id = _start_run(client)
    batch = IngestBatch(
        run_id=run_id, source_slug=offer.source_slug, offers=[offer], dry_run=True
    )

    resp = client.post(
        "/internal/ingest/offers",
        json=batch.model_dump(mode="json"),
        headers=_auth_headers(),
    )
    assert resp.status_code == 200
    assert resp.json() == {
        "received": 1,
        "created": 0,
        "updated": 0,
        "unchanged": 0,
        "failed": 0,
        "errors": [],
    }

    with db.transaction() as conn:
        row = conn.execute(
            "SELECT id FROM offer WHERE source_id = "
            "(SELECT id FROM source WHERE slug = 'soleazur-grcka') AND external_id = %(eid)s",
            {"eid": external_id},
        ).fetchone()
        assert row is None


def test_batch_too_large_is_rejected(client: TestClient) -> None:
    from travelapi.config import settings

    offers = [
        OfferIn(
            source_slug="soleazur-grcka",
            external_id=f"batch-test-{uuid.uuid4().hex[:8]}-{i}",
            product_kind=ProductKind.ACCOMMODATION,
            title=f"Test ponuda {i}",
            url=f"https://example.rs/ponuda/{i}",
        )
        for i in range(settings.max_offers_per_batch + 1)
    ]
    run_id = _start_run(client)
    batch = IngestBatch(run_id=run_id, source_slug="soleazur-grcka", offers=offers)

    resp = client.post(
        "/internal/ingest/offers",
        json=batch.model_dump(mode="json"),
        headers=_auth_headers(),
    )
    assert resp.status_code == 400
    assert resp.json()["code"] == "batch_too_large"
