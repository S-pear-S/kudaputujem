package rs.kudaputujem.api.pricing

import java.math.BigDecimal
import java.math.RoundingMode
import org.springframework.stereotype.Component
import rs.kudaputujem.api.domain.PriceSlot
import rs.kudaputujem.api.domain.PricingBasis

/**
 * Raspoređuje putnike po sobama tako da ukupna cena bude najmanja.
 *
 * Ovo je centralni algoritam domena. Agencija ne objavljuje "cenu za 4 osobe" nego
 * cenu po rasporedu (`1/2`, `1/2+1`, `1/4`, `A2/4`), pa se ukupna cena za konkretnu
 * grupu putnika mora izračunati.
 *
 * ## Pravila koja primenjujemo (i zašto)
 *
 * 1. **Soba mora imati bar jednu odraslu osobu.** Deca ne mogu sama u sobi.
 * 2. **Hotelska cena po osobi važi kad je soba popunjena do osnovnog kapaciteta.**
 *    `1/2` po 349 EUR znači "349 po osobi kad su dvoje u sobi". Jedan gost u dvokrevetnoj
 *    je moguć samo ako agencija objavi doplatu za jednokrevetnu (`SINGLE_SUPPLEMENT`).
 * 3. **Dečja cena važi za POMOĆNI ležaj.** Srpski cenovnici pišu "1/2+1 dete 2-11: 199",
 *    što se odnosi na treći ležaj. Dete u osnovnom ležaju plaća kao odrasla osoba.
 *    Ovo je namerno konzervativno: radije precenimo nego da prikažemo nižu cenu od stvarne.
 * 4. **Deca sa najvećim popustom idu prva na pomoćne ležaje.**
 * 5. **Apartmani (`UNIT`) se plaćaju celi**, bez obzira na broj gostiju, do kapaciteta.
 *
 * ## Šta NE znamo
 *
 * Ne znamo koliko jedinica svakog tipa je slobodno. Pretpostavljamo da ih ima dovoljno.
 * Zato je rezultat **procena za poređenje**, a ne rezervacija — agencija potvrđuje cenu.
 * Frontend to mora jasno da kaže.
 *
 * ## Složenost
 *
 * Stanje je (preostali odrasli, preostala deca po uzrasnim klasama, iskorišćene sobe).
 * Uz gornje granice (8 odraslih, 4 deteta, 6 soba) prostor stanja je mali i memoizacija
 * ga rešava u mikrosekundama. Zato se ovo sme zvati za stranicu rezultata, ali NE za
 * filtriranje miliona redova — za to postoji `departure_price_index`.
 */
@Component
class OccupancySolver {

    companion object {
        const val MAX_ADULTS = 8
        const val MAX_CHILDREN = 4
        const val MAX_ROOMS = 6
        private val UNSOLVABLE = BigDecimal("999999999")
    }

    // ---------------------------------------------------------------- ulaz

    /** Jedan red iz `price_option`. */
    data class PriceOption(
        val roomCode: String,
        val roomName: String? = null,
        val capacityAdults: Int,
        val capacityExtra: Int,
        val slot: PriceSlot,
        val pricingBasis: PricingBasis,
        val amount: BigDecimal,
        val currency: String,
        val childAgeFrom: Int? = null,
        val childAgeTo: Int? = null,
    )

    data class Party(
        val adults: Int,
        val childAges: List<Int> = emptyList(),
        /** Ako je zadat, rešenje mora imati tačno toliko soba. `null` = optimizuj. */
        val rooms: Int? = null,
    ) {
        init {
            require(adults in 1..MAX_ADULTS) { "broj odraslih mora biti 1..$MAX_ADULTS" }
            require(childAges.size <= MAX_CHILDREN) { "najviše $MAX_CHILDREN dece" }
            require(childAges.all { it in 0..17 }) { "uzrast deteta mora biti 0..17" }
            require(rooms == null || rooms in 1..MAX_ROOMS) { "broj soba mora biti 1..$MAX_ROOMS" }
        }

        val size: Int get() = adults + childAges.size
    }

    // ---------------------------------------------------------------- izlaz

    data class RoomAssignment(
        val roomCode: String,
        val roomName: String?,
        val adults: Int,
        val childAges: List<Int>,
        val amount: BigDecimal,
    )

    data class Solution(
        val total: BigDecimal,
        val currency: String,
        val rooms: List<RoomAssignment>,
    ) {
        val roomCount: Int get() = rooms.size

        fun perPerson(partySize: Int): BigDecimal =
            if (partySize <= 0) BigDecimal.ZERO
            else total.divide(BigDecimal(partySize), 2, RoundingMode.HALF_UP)
    }

    // ---------------------------------------------------------------- javni API

    /**
     * @param options sve cene jednog termina
     * @param party ko putuje
     * @param nights broj noćenja (potrebno za cene po noći)
     * @return najjeftiniji raspored, ili `null` ako grupa ne može da se smesti
     */
    fun solve(
        options: List<PriceOption>,
        party: Party,
        nights: Int,
    ): Solution? {
        if (options.isEmpty()) return null
        val currency = options.first().currency
        if (options.any { it.currency != currency }) {
            // Mešane valute u jednom terminu su greška u podacima; ne pogađamo kurs ovde.
            return null
        }

        val roomTypes = buildRoomTypes(options)
        if (roomTypes.isEmpty()) return null

        val ageClasses = party.childAges.distinct().sorted()
        val initialCounts = ageClasses.map { cls -> party.childAges.count { it == cls } }

        val memo = HashMap<StateKey, Result>()
        val result = best(
            roomTypes = roomTypes,
            ageClasses = ageClasses,
            nights = nights,
            requiredRooms = party.rooms,
            adults = party.adults,
            counts = initialCounts,
            roomsUsed = 0,
            memo = memo,
        )

        if (result.cost >= UNSOLVABLE) return null
        return Solution(
            // setScale, ne stripTrailingZeros — ovaj drugi za 600 daje 6E+2 u JSON-u.
            total = result.cost.setScale(2, RoundingMode.HALF_UP),
            currency = currency,
            rooms = result.rooms,
        )
    }

    /**
     * Minimalna cena za N odraslih bez dece. Koristi je job koji puni
     * `departure_price_index`, pa mora biti jeftino za poziv u petlji.
     */
    fun minimumForAdults(options: List<PriceOption>, adults: Int, nights: Int): Solution? =
        runCatching { solve(options, Party(adults = adults), nights) }.getOrNull()

    // ---------------------------------------------------------------- interno

    private data class RoomType(
        val code: String,
        val name: String?,
        val capacityAdults: Int,
        val capacityExtra: Int,
        val adultPrice: BigDecimal?,
        val extraBedPrice: BigDecimal?,
        val singleSupplement: BigDecimal?,
        val unitPrice: BigDecimal?,
        val unitPerNight: Boolean,
        val personPerNight: Boolean,
        val childBrackets: List<ChildBracket>,
    ) {
        val capacityTotal: Int get() = capacityAdults + capacityExtra

        fun childPrice(age: Int): BigDecimal? =
            childBrackets.filter { age >= it.from && age <= it.to }.minOfOrNull { it.amount }
    }

    private data class ChildBracket(val from: Int, val to: Int, val amount: BigDecimal)

    private data class StateKey(val adults: Int, val counts: List<Int>, val roomsUsed: Int)

    private data class Result(val cost: BigDecimal, val rooms: List<RoomAssignment>)

    private fun buildRoomTypes(options: List<PriceOption>): List<RoomType> =
        options.groupBy { it.roomCode }.map { (code, group) ->
            RoomType(
                code = code,
                name = group.firstNotNullOfOrNull { it.roomName },
                capacityAdults = group.maxOf { it.capacityAdults }.coerceAtLeast(1),
                capacityExtra = group.maxOf { it.capacityExtra }.coerceAtLeast(0),
                adultPrice = group.filter { it.slot == PriceSlot.ADULT }.minOfOrNull { it.amount },
                extraBedPrice = group.filter { it.slot == PriceSlot.EXTRA_BED }
                    .minOfOrNull { it.amount },
                singleSupplement = group.filter { it.slot == PriceSlot.SINGLE_SUPPLEMENT }
                    .minOfOrNull { it.amount },
                unitPrice = group.filter { it.slot == PriceSlot.UNIT }.minOfOrNull { it.amount },
                unitPerNight = group.any { it.slot == PriceSlot.UNIT && it.pricingBasis.perNight },
                personPerNight = group.any {
                    it.slot != PriceSlot.UNIT && it.pricingBasis.perNight
                },
                childBrackets = group.filter { it.slot == PriceSlot.CHILD }.map {
                    ChildBracket(
                        from = it.childAgeFrom ?: 0,
                        to = it.childAgeTo ?: 11,
                        amount = it.amount,
                    )
                },
            )
        }

    /** Cena smeštanja tačno ovih ljudi u jednu sobu datog tipa, ili `null` ako ne može. */
    private fun roomCost(
        type: RoomType,
        adults: Int,
        childAges: List<Int>,
        nights: Int,
    ): BigDecimal? {
        val occupants = adults + childAges.size
        if (adults < 1) return null                       // pravilo 1
        if (occupants > type.capacityTotal) return null

        type.unitPrice?.let { unit ->                     // pravilo 5
            return if (type.unitPerNight) unit * nights.toBigDecimal() else unit
        }

        val adultPrice = type.adultPrice ?: return null

        // pravilo 2
        val singleOccupancyAllowed = occupants == 1 && type.singleSupplement != null
        if (occupants < type.capacityAdults && !singleOccupancyAllowed) return null

        val extraSlots = (occupants - type.capacityAdults).coerceAtLeast(0)
        if (extraSlots > type.capacityExtra) return null

        val extraBedPrice = type.extraBedPrice ?: adultPrice

        // pravilo 4: deca sa najvećim popustom prva na pomoćne ležaje
        val ranked = childAges.sortedBy { type.childPrice(it) ?: adultPrice }
        val childrenOnExtra = ranked.take(minOf(ranked.size, extraSlots))
        val childrenInBase = ranked.drop(childrenOnExtra.size)

        val adultsOnExtra = extraSlots - childrenOnExtra.size
        val adultsInBase = adults - adultsOnExtra
        if (adultsInBase < 0) return null

        var cost = adultPrice * adultsInBase.toBigDecimal() +
            extraBedPrice * adultsOnExtra.toBigDecimal()

        for (age in childrenOnExtra) {
            cost += type.childPrice(age) ?: extraBedPrice
        }
        // pravilo 3: dete u osnovnom ležaju plaća kao odrasla osoba
        cost += adultPrice * childrenInBase.size.toBigDecimal()

        if (occupants == 1 && type.capacityAdults >= 2) {
            cost += type.singleSupplement ?: return null
        }

        if (type.personPerNight) cost *= nights.toBigDecimal()
        return cost
    }

    private fun best(
        roomTypes: List<RoomType>,
        ageClasses: List<Int>,
        nights: Int,
        requiredRooms: Int?,
        adults: Int,
        counts: List<Int>,
        roomsUsed: Int,
        memo: HashMap<StateKey, Result>,
    ): Result {
        if (adults == 0 && counts.sum() == 0) {
            return if (requiredRooms == null || roomsUsed == requiredRooms) {
                Result(BigDecimal.ZERO, emptyList())
            } else {
                Result(UNSOLVABLE, emptyList())
            }
        }
        val limit = requiredRooms ?: MAX_ROOMS
        if (roomsUsed >= limit) return Result(UNSOLVABLE, emptyList())

        val key = StateKey(adults, counts, roomsUsed)
        memo[key]?.let { return it }

        var bestCost = UNSOLVABLE
        var bestRooms: List<RoomAssignment> = emptyList()

        for (type in roomTypes) {
            val maxAdultsHere = minOf(adults, type.capacityTotal)
            for (takeAdults in 1..maxAdultsHere) {
                forEachChildCombination(counts, type.capacityTotal - takeAdults) { combo ->
                    val ages = mutableListOf<Int>()
                    for (i in combo.indices) repeat(combo[i]) { ages += ageClasses[i] }

                    val cost = roomCost(type, takeAdults, ages, nights)
                    if (cost != null) {
                        val remaining = counts.indices.map { counts[it] - combo[it] }
                        val sub = best(
                            roomTypes, ageClasses, nights, requiredRooms,
                            adults - takeAdults, remaining, roomsUsed + 1, memo,
                        )
                        if (sub.cost < UNSOLVABLE) {
                            val total = cost + sub.cost
                            if (total < bestCost) {
                                bestCost = total
                                bestRooms = listOf(
                                    RoomAssignment(
                                        roomCode = type.code,
                                        roomName = type.name,
                                        adults = takeAdults,
                                        childAges = ages.toList(),
                                        amount = cost.setScale(2, RoundingMode.HALF_UP),
                                    )
                                ) + sub.rooms
                            }
                        }
                    }
                }
            }
        }

        val result = Result(bestCost, bestRooms)
        memo[key] = result
        return result
    }

    /** Nabraja sve kombinacije broja dece po uzrasnoj klasi koje staju u [freeSlots]. */
    private inline fun forEachChildCombination(
        counts: List<Int>,
        freeSlots: Int,
        action: (IntArray) -> Unit,
    ) {
        if (freeSlots < 0) return
        val combo = IntArray(counts.size)
        fun recurse(index: Int, used: Int) {
            if (index == counts.size) {
                action(combo)
                return
            }
            for (take in 0..minOf(counts[index], freeSlots - used)) {
                combo[index] = take
                recurse(index + 1, used + take)
            }
            combo[index] = 0
        }
        recurse(0, 0)
    }
}
