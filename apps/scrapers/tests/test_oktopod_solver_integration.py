"""Integracioni test: oktopod parser -> OccupancySolver, cela putanja HTML -> cena.

Instrukcija 12 (poruka 12), odeljak "Oktopod: ovo nije bug, nego nešto gore".
Parser i solver su dosad testirani odvojeno (`test_oktopod.py`, `test_occupancy.py`);
greška ovog tipa živi IZMEĐU njih i nijedan odvojeni test je ne bi video.

Oktopod objavljuje „Broj plativih osoba", ne stvarni raspored po ležajima. Za
„1/3+1 STD" to je 4 — cena se množi sa 4 bez obzira ko na kom ležaju spava.
Adapter to upisuje u `capacity_adults=4, capacity_extra=0` (vidi komentar iznad
`oktopod.py:402` i CLAUDE.md §7 Faza B) — to je tačno ZA OKTOPODOV način naplate,
ne stvarni kapacitet po ležajevima. Ovaj test dokazuje da ta upisana vrednost,
puštena kroz solver, daje isti rezultat koji bi dao ručni račun sa sajta:
4 osobe x cena po osobi iz tabele.
"""

from __future__ import annotations

import pathlib
from datetime import date
from decimal import Decimal

from travelapi.pricing.occupancy import OccupancySolver, Party, PriceOption

from travelscrape.adapters.oktopod import parse_hotel_page

FIXTURE = pathlib.Path(__file__).parent / "fixtures" / "oktopod" / "putovanje_vila_penny.html"
URL = "https://www.oktopod.rs/sr/putovanje/vila-penny-hanioti/8339"
REFERENCE = date(2026, 1, 1)


def test_1_3_plus_1_std_cena_za_cetvoro_je_cetiri_puta_cena_iz_tabele() -> None:
    """10-noćni termin 09.06-19.06.2026: '1/3+1 STD' u fixture-u piše 200,
    'Broj plativih osoba' piše 4. Solver mora dati 4 x 200 = 800, ne manje
    (npr. da pogrešno smesti nekog na jeftiniji pomoćni ležaj) ni više.

    Alternative koje solver razmatra i odbacuje kao skuplje: dve sobe '1/2 STD'
    (2 x 265 x 2 = 1060), '1/2 STD' + '1/2 STD RENOV*' (530 + 570 = 1100) — sve
    skuplje od jedne '1/3+1 STD' sobe. Nijedna kombinacija sa jednim gostom u
    sobi nije moguća jer oktopod ne objavljuje SINGLE_SUPPLEMENT.
    """
    offers = parse_hotel_page(FIXTURE.read_text(encoding="utf-8"), URL, reference=REFERENCE)
    offer = offers[0]
    departure = next(
        d for d in offer.departures if d.nights == 10 and d.start_date == date(2026, 6, 9)
    )
    price = next(p for p in departure.prices if p.room_code == "1/3+1-std")
    assert price.amount == Decimal("200")
    assert price.capacity_adults == 4
    assert price.capacity_extra == 0

    options = [
        PriceOption(
            room_code=p.room_code,
            capacity_adults=p.capacity_adults,
            capacity_extra=p.capacity_extra,
            slot=p.slot,
            pricing_basis=p.pricing_basis,
            amount=p.amount,
            currency=offer.currency,
            room_name=p.room_name,
            child_age_from=p.child_age_from,
            child_age_to=p.child_age_to,
        )
        for p in departure.prices
    ]

    result = OccupancySolver().solve(options, Party(adults=4), nights=departure.nights)

    assert result is not None
    assert str(result.total) == "800.00"
    assert result.room_count == 1
    assert result.rooms[0].room_code == "1/3+1-std"
