"""`OfferIn.content_hash()` mora biti stabilan IZMEDJU PROCESA, ne samo unutar jednog.

Zašto ovo mora biti provereno PRE nego što `OfferWriter` (ADR 0001 korak 4) počne da se
oslanja na `content_hash()` za detekciju "ponuda se nije promenila": svako pokretanje
`travelscrape run <izvor>` je NOV Python proces, i CPython po difoltu nasumično bira
`PYTHONHASHSEED` za svaki proces (osim ako je eksplicitno fiksiran). Ako bi poredak
ijednog polja u `OfferIn.content_hash()`-u zavisio od tog seed-a, ista ponuda bi
dobijala RAZLIČIT heš pri svakom skrepovanju — `OfferWriter` bi je tretirao kao
izmenjenu svaki put, i cela svrha content_hash-a (preskoči upis nepromenjene ponude)
bi tiho prestala da radi, bez ijednog pada testa u istom procesu.

`content_hash()` koristi `json.dumps(payload, sort_keys=True, ...)`, što sortira
ključeve REKURZIVNO na svakom nivou ugnježdenog dict-a — zato dict polja (npr.
`raw_attributes`) ne smeju biti osetljiva na poredak. `test_content_hash_stable_across_processes`
to dokazuje eksperimentom (tri zasebna procesa, tri različita hash seed-a), ne pretpostavkom
o tome kako `json.dumps` radi.

`sort_keys` NE sortira sadržaj LISTI (`departures`, `prices`, `surcharges`, ...) — to je
posao `_sort_hash_lists()` u `models.py`, pozvan iz `content_hash()` pre serijalizacije.
Ovo je namerno svojstvo FUNKCIJE, ne pretpostavka o adapterima: "nijedan adapter danas ne
gradi listu iz redosleda koji zavisi od nečeg nestabilnog" je zapažanje o dva adaptera koja
danas postoje, ne garancija za svaki budući. `test_content_hash_stable_under_list_reordering`
to dokazuje direktno — ista ponuda, termini/cene/doplate u izmešanom redosledu, isti heš.
"""

from __future__ import annotations

import os
import subprocess
import sys
from datetime import date
from decimal import Decimal
from pathlib import Path

from travelcore.enums import BoardType, PriceSlot, ProductKind, SurchargeCode, TransportType
from travelcore.models import AccommodationIn, DepartureIn, OfferIn, PriceIn, SurchargeIn

_SCRIPT = Path(__file__).parent / "_content_hash_case.py"


def _hash_with_seed(hash_seed: str) -> str:
    env = {**os.environ, "PYTHONHASHSEED": hash_seed}
    result = subprocess.run(
        [sys.executable, str(_SCRIPT)],
        capture_output=True,
        text=True,
        env=env,
        check=True,
    )
    return result.stdout.strip()


def test_content_hash_stable_across_processes() -> None:
    hash_seed_1 = _hash_with_seed("1")
    hash_seed_2 = _hash_with_seed("2")
    hash_seed_3 = _hash_with_seed("random")  # nasumičan seed, kao pravo pokretanje skrepera

    assert hash_seed_1 == hash_seed_2 == hash_seed_3
    assert len(hash_seed_1) == 64  # sha256 hex


def _build_offer(
    external_id: str, departures: list[DepartureIn], surcharges: list[SurchargeIn]
) -> OfferIn:
    return OfferIn(
        source_slug="test-izvor",
        external_id=external_id,
        product_kind=ProductKind.PACKAGE,
        title="Test ponuda",
        url="https://example.rs/ponuda/2",
        accommodation=AccommodationIn(name="Ridos house", stars=3.0),
        transport_type=TransportType.BUS,
        board_type=BoardType.HB,
        departures=departures,
        surcharges=surcharges,
    )


def test_content_hash_stable_under_list_reordering() -> None:
    departure_early = DepartureIn(
        start_date=date(2026, 7, 1),
        end_date=date(2026, 7, 8),
        prices=[
            PriceIn(room_code="1/2", amount=Decimal("349.00"), slot=PriceSlot.ADULT),
            PriceIn(
                room_code="1/2+1",
                amount=Decimal("199.00"),
                slot=PriceSlot.CHILD,
                child_age_from=2,
                child_age_to=11,
            ),
        ],
    )
    departure_late = DepartureIn(
        start_date=date(2026, 7, 15),
        end_date=date(2026, 7, 22),
        prices=[PriceIn(room_code="1/2", amount=Decimal("399.00"), slot=PriceSlot.ADULT)],
    )
    surcharge_tax = SurchargeIn(
        code=SurchargeCode.TOURIST_TAX, name="Boravišna taksa", amount=Decimal("1.50")
    )
    surcharge_insurance = SurchargeIn(
        code=SurchargeCode.INSURANCE, name="Osiguranje", amount=Decimal("2.00")
    )

    original = _build_offer(
        "ext-2", [departure_early, departure_late], [surcharge_tax, surcharge_insurance]
    )
    shuffled = _build_offer(
        "ext-2",
        [
            DepartureIn(
                start_date=departure_late.start_date,
                end_date=departure_late.end_date,
                prices=list(departure_late.prices),
            ),
            DepartureIn(
                start_date=departure_early.start_date,
                end_date=departure_early.end_date,
                prices=list(reversed(departure_early.prices)),
            ),
        ],
        [surcharge_insurance, surcharge_tax],
    )

    assert original.content_hash() == shuffled.content_hash()
