"""Raspoređuje putnike po sobama tako da ukupna cena bude najmanja.

Prevod `OccupancySolver.kt` (ADR 0001 korak 3). Ponašanje je namerno preneto
DOSLOVNO, uključujući poznate zamke — vidi napomene uz `_room_cost` i
`_STATE_KEY` niže. Ne "popravljaj" ništa ovde bez razgovora (CLAUDE.md pravilo 9).

Ovo je centralni algoritam domena. Agencija ne objavljuje "cenu za 4 osobe" nego
cenu po rasporedu (`1/2`, `1/2+1`, `1/4`, `A2/4`), pa se ukupna cena za konkretnu
grupu putnika mora izračunati.

## Pravila koja primenjujemo (i zašto)

1. **Soba mora imati bar jednu odraslu osobu.** Deca ne mogu sama u sobi.
2. **Hotelska cena po osobi važi kad je soba popunjena do osnovnog kapaciteta.**
   `1/2` po 349 EUR znači "349 po osobi kad su dvoje u sobi". Jedan gost u dvokrevetnoj
   je moguć samo ako agencija objavi doplatu za jednokrevetnu (`SINGLE_SUPPLEMENT`).
3. **Dečja cena važi za POMOĆNI ležaj.** Srpski cenovnici pišu "1/2+1 dete 2-11: 199",
   što se odnosi na treći ležaj. Dete u osnovnom ležaju plaća kao odrasla osoba.
   Ovo je namerno konzervativno: radije precenimo nego da prikažemo nižu cenu od stvarne.
4. **Deca sa najvećim popustom idu prva na pomoćne ležaje.**
5. **Apartmani (`UNIT`) se plaćaju celi**, bez obzira na broj gostiju, do kapaciteta.

## Šta NE znamo

Ne znamo koliko jedinica svakog tipa je slobodno. Pretpostavljamo da ih ima dovoljno.
Zato je rezultat **procena za poređenje**, a ne rezervacija — agencija potvrđuje cenu.
Frontend to mora jasno da kaže.

## Složenost

Stanje je (preostali odrasli, preostala deca po uzrasnim klasama, iskorišćene sobe).
Uz gornje granice (8 odraslih, 4 deteta, 6 soba) prostor stanja je mali i memoizacija
ga rešava u mikrosekundama. Zato se ovo sme zvati za stranicu rezultata, ali NE za
filtriranje miliona redova — za to postoji `departure_price_index`.
"""

from __future__ import annotations

from collections.abc import Iterator
from dataclasses import dataclass, field
from decimal import ROUND_HALF_UP, Decimal

from travelcore.enums import PriceSlot, PricingBasis

MAX_ADULTS = 8
MAX_CHILDREN = 4
MAX_ROOMS = 6

# Sentinela, NE None/math.inf. Poredi se sa >= i sabira sa drugim troškovima
# (vidi _best) — inf bi se ponašao isto u poređenju, ali None bi pukao, a
# proizvoljno velik Decimal drži istu aritmetiku kao Kotlin BigDecimal("999999999").
_UNSOLVABLE = Decimal("999999999")

_CENTS = Decimal("0.01")

_PER_NIGHT_BASES = frozenset({PricingBasis.PER_PERSON_PER_NIGHT, PricingBasis.PER_UNIT_PER_NIGHT})


# --------------------------------------------------------------------------- ulaz


@dataclass(frozen=True)
class PriceOption:
    """Jedan red iz `price_option`."""

    room_code: str
    capacity_adults: int
    capacity_extra: int
    slot: PriceSlot
    pricing_basis: PricingBasis
    amount: Decimal
    currency: str
    room_name: str | None = None
    child_age_from: int | None = None
    child_age_to: int | None = None


@dataclass(frozen=True)
class Party:
    adults: int
    child_ages: list[int] = field(default_factory=list)
    #: Ako je zadat, rešenje mora imati tačno toliko soba. `None` = optimizuj.
    rooms: int | None = None

    def __post_init__(self) -> None:
        if not 1 <= self.adults <= MAX_ADULTS:
            raise ValueError(f"broj odraslih mora biti 1..{MAX_ADULTS}")
        if len(self.child_ages) > MAX_CHILDREN:
            raise ValueError(f"najviše {MAX_CHILDREN} dece")
        if not all(0 <= age <= 17 for age in self.child_ages):
            raise ValueError("uzrast deteta mora biti 0..17")
        if self.rooms is not None and not 1 <= self.rooms <= MAX_ROOMS:
            raise ValueError(f"broj soba mora biti 1..{MAX_ROOMS}")

    @property
    def size(self) -> int:
        return self.adults + len(self.child_ages)


# --------------------------------------------------------------------------- izlaz


@dataclass(frozen=True)
class RoomAssignment:
    room_code: str
    room_name: str | None
    adults: int
    child_ages: list[int]
    amount: Decimal


@dataclass(frozen=True)
class Solution:
    total: Decimal
    currency: str
    rooms: list[RoomAssignment]

    @property
    def room_count(self) -> int:
        return len(self.rooms)

    def per_person(self, party_size: int) -> Decimal:
        if party_size <= 0:
            return Decimal("0")
        return (self.total / Decimal(party_size)).quantize(_CENTS, rounding=ROUND_HALF_UP)


# --------------------------------------------------------------------------- javni API


class OccupancySolver:
    def solve(self, options: list[PriceOption], party: Party, nights: int) -> Solution | None:
        """
        Args:
            options: sve cene jednog termina
            party: ko putuje
            nights: broj noćenja (potrebno za cene po noći)

        Returns:
            Najjeftiniji raspored, ili `None` ako grupa ne može da se smesti.
        """
        if not options:
            return None
        currency = options[0].currency
        if any(o.currency != currency for o in options):
            # Mešane valute u jednom terminu su greška u podacima; ne pogađamo kurs ovde.
            return None

        room_types = _build_room_types(options)
        if not room_types:
            return None

        age_classes = sorted(set(party.child_ages))
        initial_counts = tuple(party.child_ages.count(cls) for cls in age_classes)

        memo: dict[tuple[int, tuple[int, ...], int], _Result] = {}
        result = _best(
            room_types=room_types,
            age_classes=age_classes,
            nights=nights,
            required_rooms=party.rooms,
            adults=party.adults,
            counts=initial_counts,
            rooms_used=0,
            memo=memo,
        )

        if result.cost >= _UNSOLVABLE:
            return None
        return Solution(
            # quantize, ne normalize — normalize bi za 600 dao 6E+2 u JSON-u.
            total=result.cost.quantize(_CENTS, rounding=ROUND_HALF_UP),
            currency=currency,
            rooms=result.rooms,
        )

    def minimum_for_adults(
        self, options: list[PriceOption], adults: int, nights: int
    ) -> Solution | None:
        """Minimalna cena za N odraslih bez dece.

        Koristi je job koji puni `departure_price_index`, pa mora biti jeftino
        za poziv u petlji.
        """
        try:
            return self.solve(options, Party(adults=adults), nights)
        except ValueError:
            return None


# --------------------------------------------------------------------------- interno


@dataclass(frozen=True)
class _ChildBracket:
    age_from: int
    age_to: int
    amount: Decimal


@dataclass(frozen=True)
class _RoomType:
    code: str
    name: str | None
    capacity_adults: int
    capacity_extra: int
    adult_price: Decimal | None
    extra_bed_price: Decimal | None
    single_supplement: Decimal | None
    unit_price: Decimal | None
    unit_per_night: bool
    person_per_night: bool
    child_brackets: list[_ChildBracket]

    @property
    def capacity_total(self) -> int:
        return self.capacity_adults + self.capacity_extra

    def child_price(self, age: int) -> Decimal | None:
        matching = [b.amount for b in self.child_brackets if b.age_from <= age <= b.age_to]
        return min(matching, default=None)


@dataclass(frozen=True)
class _Result:
    cost: Decimal
    rooms: list[RoomAssignment]


def _build_room_types(options: list[PriceOption]) -> list[_RoomType]:
    groups: dict[str, list[PriceOption]] = {}
    for option in options:
        groups.setdefault(option.room_code, []).append(option)

    room_types: list[_RoomType] = []
    for code, group in groups.items():
        name = next((o.room_name for o in group if o.room_name is not None), None)
        child_brackets = [
            _ChildBracket(
                age_from=o.child_age_from if o.child_age_from is not None else 0,
                age_to=o.child_age_to if o.child_age_to is not None else 11,
                amount=o.amount,
            )
            for o in group
            if o.slot == PriceSlot.CHILD
        ]
        room_types.append(
            _RoomType(
                code=code,
                name=name,
                capacity_adults=max(max(o.capacity_adults for o in group), 1),
                capacity_extra=max(max(o.capacity_extra for o in group), 0),
                adult_price=min(
                    (o.amount for o in group if o.slot == PriceSlot.ADULT), default=None
                ),
                extra_bed_price=min(
                    (o.amount for o in group if o.slot == PriceSlot.EXTRA_BED), default=None
                ),
                single_supplement=min(
                    (o.amount for o in group if o.slot == PriceSlot.SINGLE_SUPPLEMENT),
                    default=None,
                ),
                unit_price=min(
                    (o.amount for o in group if o.slot == PriceSlot.UNIT), default=None
                ),
                unit_per_night=any(
                    o.slot == PriceSlot.UNIT and o.pricing_basis in _PER_NIGHT_BASES
                    for o in group
                ),
                person_per_night=any(
                    o.slot != PriceSlot.UNIT and o.pricing_basis in _PER_NIGHT_BASES
                    for o in group
                ),
                child_brackets=child_brackets,
            )
        )
    return room_types


def _room_cost(
    room_type: _RoomType, adults: int, child_ages: list[int], nights: int
) -> Decimal | None:
    """Cena smeštanja tačno ovih ljudi u jednu sobu datog tipa, ili `None` ako ne može."""
    occupants = adults + len(child_ages)
    if adults < 1:  # pravilo 1
        return None
    if occupants > room_type.capacity_total:
        return None

    if room_type.unit_price is not None:  # pravilo 5
        if room_type.unit_per_night:
            return room_type.unit_price * Decimal(nights)
        return room_type.unit_price

    adult_price = room_type.adult_price
    if adult_price is None:
        return None

    # pravilo 2
    single_occupancy_allowed = occupants == 1 and room_type.single_supplement is not None
    if occupants < room_type.capacity_adults and not single_occupancy_allowed:
        return None

    extra_slots = max(occupants - room_type.capacity_adults, 0)
    if extra_slots > room_type.capacity_extra:
        return None

    extra_bed_price = (
        room_type.extra_bed_price if room_type.extra_bed_price is not None else adult_price
    )

    def _child_key(age: int) -> Decimal:
        price = room_type.child_price(age)
        return price if price is not None else adult_price

    # pravilo 4: deca sa najvećim popustom prva na pomoćne ležaje.
    #
    # POZNATA GREŠKA, preneta doslovno iz Kotlina (ne popravljati ovde — CLAUDE.md
    # ADR 0001 korak 3, zamka 4): redosled se bira po child_price (ili adult_price
    # kao rezervi), ali se NAPLAĆUJE po extra_bed_price. Kad je extra_bed_price <
    # adult_price, pohlepan izbor po child_price nije nužno optimalan po stvarnoj
    # naplati. Popravka ide u zaseban commit posle koraka 3c.
    ranked = sorted(child_ages, key=_child_key)
    children_on_extra = ranked[: min(len(ranked), extra_slots)]
    children_in_base = ranked[len(children_on_extra) :]

    adults_on_extra = extra_slots - len(children_on_extra)
    adults_in_base = adults - adults_on_extra
    if adults_in_base < 0:
        return None

    cost = adult_price * adults_in_base + extra_bed_price * adults_on_extra

    for age in children_on_extra:
        price = room_type.child_price(age)
        cost += price if price is not None else extra_bed_price
    # pravilo 3: dete u osnovnom ležaju plaća kao odrasla osoba
    cost += adult_price * len(children_in_base)

    if occupants == 1 and room_type.capacity_adults >= 2:
        if room_type.single_supplement is None:
            return None
        cost += room_type.single_supplement

    if room_type.person_per_night:
        cost *= Decimal(nights)

    return cost


def _for_each_child_combination(
    counts: tuple[int, ...], free_slots: int
) -> Iterator[tuple[int, ...]]:
    """Nabraja sve kombinacije broja dece po uzrasnoj klasi koje staju u `free_slots`."""
    if free_slots < 0:
        return
    combo = [0] * len(counts)

    def _recurse(index: int, used: int) -> Iterator[tuple[int, ...]]:
        if index == len(counts):
            yield tuple(combo)
            return
        for take in range(0, min(counts[index], free_slots - used) + 1):
            combo[index] = take
            yield from _recurse(index + 1, used + take)
        combo[index] = 0

    yield from _recurse(0, 0)


def _best(
    room_types: list[_RoomType],
    age_classes: list[int],
    nights: int,
    required_rooms: int | None,
    adults: int,
    counts: tuple[int, ...],
    rooms_used: int,
    memo: dict[tuple[int, tuple[int, ...], int], _Result],
) -> _Result:
    if adults == 0 and sum(counts) == 0:
        if required_rooms is None or rooms_used == required_rooms:
            return _Result(Decimal(0), [])
        return _Result(_UNSOLVABLE, [])

    limit = required_rooms if required_rooms is not None else MAX_ROOMS
    if rooms_used >= limit:
        return _Result(_UNSOLVABLE, [])

    # NAMERNO ne uključuje required_rooms u ključ (isto kao Kotlin StateKey) —
    # ispravno je SAMO zato što je required_rooms konstantan kroz ceo poziv
    # solve() (jedan memo po pozivu). Ne deliti memo između poziva sa različitim
    # party.rooms, i ne menjati ovu strukturu bez ponovnog razmatranja te pretpostavke.
    key = (adults, counts, rooms_used)
    cached = memo.get(key)
    if cached is not None:
        return cached

    best_cost = _UNSOLVABLE
    best_rooms: list[RoomAssignment] = []

    for room_type in room_types:
        max_adults_here = min(adults, room_type.capacity_total)
        for take_adults in range(1, max_adults_here + 1):
            free_slots = room_type.capacity_total - take_adults
            for combo in _for_each_child_combination(counts, free_slots):
                ages: list[int] = []
                for i, take in enumerate(combo):
                    ages.extend([age_classes[i]] * take)

                cost = _room_cost(room_type, take_adults, ages, nights)
                if cost is not None:
                    remaining = tuple(counts[i] - combo[i] for i in range(len(counts)))
                    sub = _best(
                        room_types=room_types,
                        age_classes=age_classes,
                        nights=nights,
                        required_rooms=required_rooms,
                        adults=adults - take_adults,
                        counts=remaining,
                        rooms_used=rooms_used + 1,
                        memo=memo,
                    )
                    if sub.cost < _UNSOLVABLE:
                        total = cost + sub.cost
                        if total < best_cost:
                            best_cost = total
                            best_rooms = [
                                RoomAssignment(
                                    room_code=room_type.code,
                                    room_name=room_type.name,
                                    adults=take_adults,
                                    child_ages=list(ages),
                                    # Zaokruženo OVDE, po sobi — total iznad ostaje
                                    # nezaokružen kroz rekurziju. Zbir cena po sobama
                                    # zato ne mora biti jednak ukupnoj ceni. Nije bug,
                                    # zatečeno ponašanje iz Kotlina, preneto doslovno.
                                    amount=cost.quantize(_CENTS, rounding=ROUND_HALF_UP),
                                ),
                                *sub.rooms,
                            ]

    result = _Result(best_cost, best_rooms)
    memo[key] = result
    return result
