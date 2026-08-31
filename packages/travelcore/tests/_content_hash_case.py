"""Pomocni skript za test_content_hash.py — POKRECE SE U ZASEBNOM PROCESU, ne kao test modul.

Namerno se ne zove test_*.py da ga pytest ne pokupi direktno.
"""

from __future__ import annotations

from datetime import date
from decimal import Decimal

from travelcore.enums import BoardType, PriceSlot, PricingBasis, ProductKind, TransportType
from travelcore.models import AccommodationIn, DepartureIn, OfferIn, PriceIn, SurchargeIn


def build_offer() -> OfferIn:
    # raw_attributes namerno izgradjen iteracijom preko seta — iteracija seta stringova
    # ZAVISI od PYTHONHASHSEED, pa ako bi content_hash() bio osetljiv na poredak kljuceva
    # u ugnjezdenom dict-u, ovaj test bi to uhvatio (dva procesa = dva razlicita seed-a).
    raw_keys = {"c_key", "a_key", "h_key", "b_key", "g_key", "d_key", "f_key", "e_key"}
    raw_attributes = {key: key.upper() for key in raw_keys}

    return OfferIn(
        source_slug="test-izvor",
        external_id="ext-1",
        product_kind=ProductKind.PACKAGE,
        title="Test ponuda",
        url="https://example.rs/ponuda/1",
        destination_raw="Neos Marmaras",
        accommodation=AccommodationIn(name="Ridos house", stars=3.0),
        transport_type=TransportType.BUS,
        board_type=BoardType.HB,
        images=["https://example.rs/a.jpg", "https://example.rs/b.jpg"],
        raw_attributes=raw_attributes,
        surcharges=[
            SurchargeIn(name="Boravišna taksa", amount=Decimal("1.50"), currency="EUR"),
        ],
        departures=[
            DepartureIn(
                start_date=date(2026, 7, 1),
                end_date=date(2026, 7, 8),
                prices=[
                    PriceIn(
                        room_code="1/2",
                        amount=Decimal("349.00"),
                        pricing_basis=PricingBasis.PER_PERSON_PER_STAY,
                        slot=PriceSlot.ADULT,
                    ),
                    PriceIn(
                        room_code="1/2+1",
                        amount=Decimal("199.00"),
                        slot=PriceSlot.CHILD,
                        child_age_from=2,
                        child_age_to=11,
                    ),
                ],
            ),
        ],
    )


if __name__ == "__main__":
    print(build_offer().content_hash())
