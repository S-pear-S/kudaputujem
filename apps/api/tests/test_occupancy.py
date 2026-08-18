"""Testovi za OccupancySolver, preveden iz OccupancySolverTest.kt (ADR 0001 korak 3).

Očekivane vrednosti su PREPISANE doslovno iz Kotlin testa, ne ponovo izračunate — to
je verifikovana specifikacija (nezavisan Python prototip pre pisanja Kotlina, vidi
CLAUDE.md §6). Ako neki test ne prolazi kad implementacija bude gotova, greška je u
NOVOJ implementaciji, ne u ovim brojevima. Ne diraj očekivanja bez pitanja.
"""

from __future__ import annotations

from decimal import Decimal

import pytest
from travelcore.enums import PriceSlot, PricingBasis

from travelapi.pricing.occupancy import OccupancySolver, Party, PriceOption, Solution


def _option(
    code: str,
    capacity_adults: int,
    capacity_extra: int,
    slot: PriceSlot,
    amount: str,
    basis: PricingBasis = PricingBasis.PER_PERSON_PER_STAY,
    child_from: int | None = None,
    child_to: int | None = None,
    currency: str = "EUR",
) -> PriceOption:
    return PriceOption(
        room_code=code,
        capacity_adults=capacity_adults,
        capacity_extra=capacity_extra,
        slot=slot,
        pricing_basis=basis,
        amount=Decimal(amount),
        currency=currency,
        child_age_from=child_from,
        child_age_to=child_to,
    )


def _hotel_pricing() -> list[PriceOption]:
    """Tipičan srpski hotelski cenovnik za jedan termin."""
    return [
        _option("1/2", 2, 0, PriceSlot.ADULT, "349"),
        _option("1/2", 2, 0, PriceSlot.SINGLE_SUPPLEMENT, "150"),
        _option("1/3", 3, 0, PriceSlot.ADULT, "329"),
        _option("1/2+1", 2, 1, PriceSlot.ADULT, "349"),
        _option("1/2+1", 2, 1, PriceSlot.CHILD, "199", child_from=2, child_to=11),
        _option("1/2+1", 2, 1, PriceSlot.EXTRA_BED, "299"),
        _option("1/4", 4, 0, PriceSlot.ADULT, "319"),
    ]


def _apartment_pricing() -> list[PriceOption]:
    """Apartmani se plaćaju po jedinici i po noći."""
    return [
        _option("A2/4", 2, 2, PriceSlot.UNIT, "60", basis=PricingBasis.PER_UNIT_PER_NIGHT),
        _option("SU2/3", 2, 1, PriceSlot.UNIT, "45", basis=PricingBasis.PER_UNIT_PER_NIGHT),
    ]


@pytest.fixture
def solver() -> OccupancySolver:
    return OccupancySolver()


def _total(
    solver: OccupancySolver,
    party: Party,
    nights: int = 7,
    options: list[PriceOption] | None = None,
) -> Solution | None:
    return solver.solve(options if options is not None else _hotel_pricing(), party, nights)


def _assert_money(actual: Decimal, expected: str) -> None:
    """Poredi i vrednost i skalu. Decimal `==` ignoriše skalu, Kotest shouldBe ne."""
    assert str(actual) == expected, f"ocekivano {expected}, dobijeno {actual}"


# ------------------------------------------------------------------------ hotel


def test_dvoje_odraslih_ide_u_dvokrevetnu(solver: OccupancySolver) -> None:
    result = _total(solver, Party(adults=2))
    assert result is not None
    _assert_money(result.total, "698.00")
    assert len(result.rooms) == 1
    assert result.rooms[0].room_code == "1/2"


def test_jedna_osoba_placa_doplatu_za_jednokrevetnu(solver: OccupancySolver) -> None:
    result = _total(solver, Party(adults=1))
    assert result is not None
    _assert_money(result.total, "499.00")  # 349 + 150


def test_troje_odraslih_ide_u_trokrevetnu_jer_je_jeftinija_od_pomocnog_lezaja(
    solver: OccupancySolver,
) -> None:
    result = _total(solver, Party(adults=3))
    assert result is not None
    _assert_money(result.total, "987.00")  # 3 x 329, a ne 349+349+299
    assert len(result.rooms) == 1
    assert result.rooms[0].room_code == "1/3"


def test_cetvoro_odraslih_ide_u_cetvorokrevetnu_umesto_u_dve_dvokrevetne(
    solver: OccupancySolver,
) -> None:
    result = _total(solver, Party(adults=4))
    assert result is not None
    _assert_money(result.total, "1276.00")  # 4 x 319 < 2 x 698
    assert result.room_count == 1


def test_dete_od_osam_godina_dobija_decju_cenu_na_pomocnom_lezaju(
    solver: OccupancySolver,
) -> None:
    result = _total(solver, Party(adults=2, child_ages=[8]))
    assert result is not None
    _assert_money(result.total, "897.00")  # 349 + 349 + 199
    assert len(result.rooms) == 1
    assert result.rooms[0].room_code == "1/2+1"


def test_dete_van_uzrasnog_opsega_placa_kao_odrasla_osoba(solver: OccupancySolver) -> None:
    result = _total(solver, Party(adults=2, child_ages=[15]))
    assert result is not None
    _assert_money(result.total, "987.00")  # 15 godina nije "dete 2-11" -> 1/3


def test_grupa_se_deli_na_dve_sobe_kad_ne_staje_u_jednu(solver: OccupancySolver) -> None:
    result = _total(solver, Party(adults=4, child_ages=[8]))
    assert result is not None
    _assert_money(result.total, "1595.00")  # 1/2 (698) + 1/2+1 (897)
    assert result.room_count == 2


def test_eksplicitan_broj_soba_se_postuje_i_kad_je_skuplji(solver: OccupancySolver) -> None:
    result = _total(solver, Party(adults=4, rooms=2))
    assert result is not None
    _assert_money(result.total, "1396.00")  # 2 x 1/2, iako je 1/4 jeftinije
    assert result.room_count == 2


def test_soba_bez_odrasle_osobe_nije_moguca() -> None:
    # Jedno dete i nula odraslih ne prolazi ni konstruktor Party-ja.
    with pytest.raises(ValueError):
        Party(adults=0, child_ages=[8])


def test_prazan_cenovnik_daje_none(solver: OccupancySolver) -> None:
    assert solver.solve([], Party(adults=2), 7) is None


def test_mesane_valute_u_istom_terminu_daju_none_jer_ne_pogadjamo_kurs(
    solver: OccupancySolver,
) -> None:
    mixed = [
        _option("1/2", 2, 0, PriceSlot.ADULT, "349"),
        _option("1/3", 3, 0, PriceSlot.ADULT, "39000", currency="RSD"),
    ]
    assert solver.solve(mixed, Party(adults=2), 7) is None


def test_prevelika_grupa_za_raspolozive_sobe_daje_none(solver: OccupancySolver) -> None:
    only_double = [_option("1/2", 2, 0, PriceSlot.ADULT, "349")]
    assert solver.solve(only_double, Party(adults=3), 7) is None


# ------------------------------------------------------------------------ apartmani


def test_apartman_se_placa_ceo_i_po_noci(solver: OccupancySolver) -> None:
    result = _total(solver, Party(adults=4), options=_apartment_pricing())
    assert result is not None
    _assert_money(result.total, "420.00")  # 60 x 7


def test_dve_osobe_uzimaju_jeftiniji_studio(solver: OccupancySolver) -> None:
    result = _total(solver, Party(adults=2), options=_apartment_pricing())
    assert result is not None
    _assert_money(result.total, "315.00")  # 45 x 7
    assert len(result.rooms) == 1
    assert result.rooms[0].room_code == "SU2/3"


def test_sest_osoba_u_dva_studija_je_jeftinije_od_apartmana_i_studija(
    solver: OccupancySolver,
) -> None:
    result = _total(solver, Party(adults=6), options=_apartment_pricing())
    assert result is not None
    _assert_money(result.total, "630.00")  # 2 x 315 < 420 + 315
    assert result.room_count == 2


# ------------------------------------------------------------------------ ostalo


def test_cena_po_osobi_se_racuna_na_ukupan_broj_putnika(solver: OccupancySolver) -> None:
    party = Party(adults=2, child_ages=[8])
    result = _total(solver, party)
    assert result is not None
    _assert_money(result.per_person(party.size), "299.00")  # 897 / 3


def test_minimum_for_adults_ne_baca_izuzetak_za_nemoguc_broj_osoba(
    solver: OccupancySolver,
) -> None:
    assert solver.minimum_for_adults(_hotel_pricing(), adults=99, nights=7) is None
