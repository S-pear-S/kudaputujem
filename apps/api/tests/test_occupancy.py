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

from travelapi.pricing.occupancy import (
    OccupancySolver,
    Party,
    PriceOption,
    RoomAssignment,
    Solution,
)


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


def test_per_person_deljenje_koje_se_ne_zavrsava_na_3_osobe() -> None:
    """Nalaz 3 (poruka 9): Kotlin `divide(scale=2, HALF_UP)` zaokružuje jednom,
    Python `(total / n).quantize(...)` zaokružuje posle deljenja na 28 cifara —
    dva koraka umesto jednog. Testira Solution direktno, bez solvera, da se
    izoluje tačno ovo ponašanje od kombinatorike raspoređivanja.

    100.00 / 3 = 33.333(3)... -> ručno po HALF_UP na 2 decimale: treća decimala
    je 3 (< 5), zaokružuje se NADOLE -> 33.33.
    """
    solution = Solution(total=Decimal("100.00"), currency="EUR", rooms=[])
    _assert_money(solution.per_person(3), "33.33")


def test_per_person_deljenje_koje_se_ne_zavrsava_na_7_osoba() -> None:
    """100.00 / 7 = 14.285714(285714)... -> treća decimala je 5 (>= 5),
    zaokružuje se NAGORE -> 14.29.
    """
    solution = Solution(total=Decimal("100.00"), currency="EUR", rooms=[])
    _assert_money(solution.per_person(7), "14.29")


def test_minimum_for_adults_ne_baca_izuzetak_za_nemoguc_broj_osoba(
    solver: OccupancySolver,
) -> None:
    assert solver.minimum_for_adults(_hotel_pricing(), adults=99, nights=7) is None


def test_party_i_room_assignment_se_mogu_staviti_u_set() -> None:
    """child_ages je tuple, ne list — frozen=True dataclass je zato stvarno heširljiv."""
    party_a = Party(adults=2, child_ages=[8])
    party_b = Party(adults=2, child_ages=[8])
    assert {party_a, party_b} == {party_a}

    room_a = RoomAssignment(
        room_code="1/2", room_name=None, adults=2, child_ages=(8,), amount=Decimal("349.00")
    )
    room_b = RoomAssignment(
        room_code="1/2", room_name=None, adults=2, child_ages=(8,), amount=Decimal("349.00")
    )
    assert {room_a, room_b} == {room_a}


# ------------------------------------------------------------------------ 3c: prošireno
#
# Kotlin testovi (i port 3a/3b) NE pokrivaju: PER_PERSON_PER_NIGHT, PriceSlot.INFANT,
# više dece različitog uzrasta u istoj sobi, nesklad capacity_total sa
# capacity_adults+capacity_extra, memoizaciju kad je rooms zadat. Svih pet dole je
# provereno protiv stvarnog solvera pre pisanja tvrdnje (ne pretpostavljeno) — nijedno
# nije otkrilo pogrešno ponašanje, sve je u skladu sa dokumentovanim pravilima.


def test_per_person_per_night_mnozi_sa_brojem_nocenja(solver: OccupancySolver) -> None:
    """50 EUR/osobi/noć, 2 odrasla, 5 noćenja -> 50*2*5 = 500."""
    options = [
        _option(
            "1/2", 2, 0, PriceSlot.ADULT, "50", basis=PricingBasis.PER_PERSON_PER_NIGHT
        )
    ]
    result = solver.solve(options, Party(adults=2), nights=5)
    assert result is not None
    _assert_money(result.total, "500.00")


def test_infant_slot_se_ne_koristi_dete_pada_na_extra_bed_cenu(
    solver: OccupancySolver,
) -> None:
    """PriceSlot.INFANT nema svoje polje u _RoomType (isto kao Kotlin RoomType) —
    cena objavljena za INFANT slot se tiho ne koristi nigde. Dete bez CHILD
    bracket-a pada na extra_bed_price kao rezervu (isto pravilo kao za dete van
    opsega), NE na (mnogo nižu) INFANT cenu od "1" koja postoji u options.
    2 odrasla (349+349) + dete na extra ležaju po extra_bed_price (299) = 997,
    ne 349+349+1=699 kao što bi bilo da je INFANT cena greškom uzeta u obzir.
    """
    options = [
        _option("1/2+1", 2, 1, PriceSlot.ADULT, "349"),
        _option("1/2+1", 2, 1, PriceSlot.EXTRA_BED, "299"),
        _option("1/2+1", 2, 1, PriceSlot.INFANT, "1", child_from=0, child_to=1),
    ]
    result = solver.solve(options, Party(adults=2, child_ages=[1]), nights=7)
    assert result is not None
    _assert_money(result.total, "997.00")


def test_vise_dece_razlicitog_uzrasta_jeftinije_dete_ide_na_extra_lezaj(
    solver: OccupancySolver,
) -> None:
    """1 odrasla osoba + dvoje dece (3 i 10 god.) u sobi sa 1 extra ležajem
    (capacity_adults=2, capacity_extra=1 -> tačno 3 mesta). Samo JEDNO dete
    stane na extra ležaj (pravilo 4: ono sa najvećim popustom) — dete od 3
    (bracket 2-6, 100) je jeftinije od deteta od 10 (bracket 7-11, 150), pa ono
    ide na extra ležaj, a starije dete pada u osnovni ležaj i plaća punu cenu
    odrasle osobe (pravilo 3). 300 (odrasla baza) + 100 (dete 3, extra) +
    300 (dete 10, osnovni ležaj po ceni odraslog) = 700.
    """
    options = [
        _option("1/3+1", 2, 1, PriceSlot.ADULT, "300"),
        _option("1/3+1", 2, 1, PriceSlot.EXTRA_BED, "250"),
        _option("1/3+1", 2, 1, PriceSlot.CHILD, "100", child_from=2, child_to=6),
        _option("1/3+1", 2, 1, PriceSlot.CHILD, "150", child_from=7, child_to=11),
    ]
    result = solver.solve(options, Party(adults=1, child_ages=[3, 10]), nights=7)
    assert result is not None
    _assert_money(result.total, "700.00")
    assert len(result.rooms) == 1
    assert set(result.rooms[0].child_ages) == {3, 10}


def test_capacity_total_se_racuna_nezavisno_max_adults_plus_max_extra(
    solver: OccupancySolver,
) -> None:
    """Isti room_code sa DVA reda različitog kapaciteta (podatak sa sajta nije
    dosledan — moguće u praksi): jedan red (ADULT, capacity_adults=2,
    capacity_extra=0) implicira kapacitet 2, drugi (EXTRA_BED,
    capacity_adults=1, capacity_extra=2) implicira kapacitet 3. `_RoomType`
    (isto kao Kotlin `RoomType`) NIKAD ne čita `capacity_total` kao zaseban
    podatak (`PriceOption` ga uopšte i nema kao polje) — uvek ga računa kao
    `max(capacity_adults preko svih redova) + max(capacity_extra preko svih
    redova)`, nezavisno po koloni. Ovde: max(2,1)+max(0,2) = 2+2 = 4 — veći
    kapacitet nego što ijedan pojedinačan red stvarno tvrdi. 4 odrasla STANU
    u ovu jednu sobu iako nijedan red to eksplicitno ne kaže: 2 u osnovi
    (300*2) + 2 na extra ležaju (250*2) = 1100.
    """
    options = [
        _option("1/3", 2, 0, PriceSlot.ADULT, "300"),
        _option("1/3", 1, 2, PriceSlot.EXTRA_BED, "250"),
    ]
    result = solver.solve(options, Party(adults=4), nights=7)
    assert result is not None
    _assert_money(result.total, "1100.00")
    assert result.room_count == 1


def test_memoizacija_sa_zadatim_rooms_daje_ispravan_minimum(
    solver: OccupancySolver,
) -> None:
    """4 odrasla, tačno 3 sobe zadato. Jedina moguća podela 4 u tačno 3 pozitivna
    dela je 2+1+1 (u bilo kom redosledu) — sobe od 1 osobe postoje samo kao
    "1/2" sa doplatom za jednokrevetnu (349+150=499, "1/2+1" nema tu doplatu
    definisanu pa je 1 odrasla osoba tamo odbijena). Najjeftinija soba za 2
    osobe je 698 ("1/2" ili "1/2+1", ista cena). Očekivano: 698 + 499 + 499 =
    1696. Ovo prisiljava solver da istu stanje (preostalo 2 odrasla,
    rooms_used=1) dostigne iz više grana (bilo koji od dva različita room_type
    izbora za prvu, dvo-osobnu sobu) — memoizacija mora dati isti, ispravan
    rezultat bez obzira na to koja grana prva popuni keš.
    """
    result = solver.solve(_hotel_pricing(), Party(adults=4, rooms=3), nights=7)
    assert result is not None
    _assert_money(result.total, "1696.00")
    assert result.room_count == 3
