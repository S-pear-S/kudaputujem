package rs.kudaputujem.api.pricing

import io.kotest.matchers.nulls.shouldNotBeNull
import io.kotest.matchers.shouldBe
import java.math.BigDecimal
import org.junit.jupiter.api.Test
import rs.kudaputujem.api.domain.PriceSlot
import rs.kudaputujem.api.domain.PricingBasis
import rs.kudaputujem.api.pricing.OccupancySolver.Party
import rs.kudaputujem.api.pricing.OccupancySolver.PriceOption

/**
 * Očekivane vrednosti su ručno izračunate iz cenovnika u [hotelPricing] i [apartmentPricing],
 * i dodatno provereni nezavisnim prototipom pre nego što je ovaj kod napisan.
 */
class OccupancySolverTest {

    private val solver = OccupancySolver()

    /** Tipičan srpski hotelski cenovnik za jedan termin. */
    private fun hotelPricing(): List<PriceOption> = listOf(
        option("1/2", 2, 0, PriceSlot.ADULT, "349"),
        option("1/2", 2, 0, PriceSlot.SINGLE_SUPPLEMENT, "150"),
        option("1/3", 3, 0, PriceSlot.ADULT, "329"),
        option("1/2+1", 2, 1, PriceSlot.ADULT, "349"),
        option("1/2+1", 2, 1, PriceSlot.CHILD, "199", childFrom = 2, childTo = 11),
        option("1/2+1", 2, 1, PriceSlot.EXTRA_BED, "299"),
        option("1/4", 4, 0, PriceSlot.ADULT, "319"),
    )

    /** Apartmani se plaćaju po jedinici i po noći. */
    private fun apartmentPricing(): List<PriceOption> = listOf(
        option("A2/4", 2, 2, PriceSlot.UNIT, "60", basis = PricingBasis.PER_UNIT_PER_NIGHT),
        option("SU2/3", 2, 1, PriceSlot.UNIT, "45", basis = PricingBasis.PER_UNIT_PER_NIGHT),
    )

    private fun option(
        code: String,
        capacityAdults: Int,
        capacityExtra: Int,
        slot: PriceSlot,
        amount: String,
        basis: PricingBasis = PricingBasis.PER_PERSON_PER_STAY,
        childFrom: Int? = null,
        childTo: Int? = null,
    ) = PriceOption(
        roomCode = code,
        capacityAdults = capacityAdults,
        capacityExtra = capacityExtra,
        slot = slot,
        pricingBasis = basis,
        amount = BigDecimal(amount),
        currency = "EUR",
        childAgeFrom = childFrom,
        childAgeTo = childTo,
    )

    private fun total(party: Party, nights: Int = 7, options: List<PriceOption> = hotelPricing()) =
        solver.solve(options, party, nights)

    // ------------------------------------------------------------------ hotel

    @Test
    fun `dvoje odraslih ide u dvokrevetnu`() {
        val result = total(Party(adults = 2)).shouldNotBeNull()
        result.total shouldBe BigDecimal("698.00")
        result.rooms.single().roomCode shouldBe "1/2"
    }

    @Test
    fun `jedna osoba placa doplatu za jednokrevetnu`() {
        val result = total(Party(adults = 1)).shouldNotBeNull()
        result.total shouldBe BigDecimal("499.00")   // 349 + 150
    }

    @Test
    fun `troje odraslih ide u trokrevetnu jer je jeftinija od pomocnog lezaja`() {
        val result = total(Party(adults = 3)).shouldNotBeNull()
        result.total shouldBe BigDecimal("987.00")   // 3 x 329, a ne 349+349+299
        result.rooms.single().roomCode shouldBe "1/3"
    }

    @Test
    fun `cetvoro odraslih ide u cetvorokrevetnu umesto u dve dvokrevetne`() {
        val result = total(Party(adults = 4)).shouldNotBeNull()
        result.total shouldBe BigDecimal("1276.00")  // 4 x 319 < 2 x 698
        result.roomCount shouldBe 1
    }

    @Test
    fun `dete od osam godina dobija decju cenu na pomocnom lezaju`() {
        val result = total(Party(adults = 2, childAges = listOf(8))).shouldNotBeNull()
        result.total shouldBe BigDecimal("897.00")   // 349 + 349 + 199
        result.rooms.single().roomCode shouldBe "1/2+1"
    }

    @Test
    fun `dete van uzrasnog opsega placa kao odrasla osoba`() {
        val result = total(Party(adults = 2, childAges = listOf(15))).shouldNotBeNull()
        result.total shouldBe BigDecimal("987.00")   // 15 godina nije "dete 2-11" -> 1/3
    }

    @Test
    fun `grupa se deli na dve sobe kad ne staje u jednu`() {
        val result = total(Party(adults = 4, childAges = listOf(8))).shouldNotBeNull()
        result.total shouldBe BigDecimal("1595.00")  // 1/2 (698) + 1/2+1 (897)
        result.roomCount shouldBe 2
    }

    @Test
    fun `eksplicitan broj soba se postuje i kad je skuplji`() {
        val result = total(Party(adults = 4, rooms = 2)).shouldNotBeNull()
        result.total shouldBe BigDecimal("1396.00")  // 2 x 1/2, iako je 1/4 jeftinije
        result.roomCount shouldBe 2
    }

    @Test
    fun `soba bez odrasle osobe nije moguca`() {
        // Jedno dete i nula odraslih ne prolazi ni konstruktor Party-ja.
        runCatching { Party(adults = 0, childAges = listOf(8)) }.isFailure shouldBe true
    }

    @Test
    fun `prazan cenovnik daje null`() {
        solver.solve(emptyList(), Party(adults = 2), 7) shouldBe null
    }

    @Test
    fun `mesane valute u istom terminu daju null jer ne pogadjamo kurs`() {
        val mixed = listOf(
            option("1/2", 2, 0, PriceSlot.ADULT, "349"),
            option("1/3", 3, 0, PriceSlot.ADULT, "39000").copy(currency = "RSD"),
        )
        solver.solve(mixed, Party(adults = 2), 7) shouldBe null
    }

    @Test
    fun `prevelika grupa za raspolozive sobe daje null`() {
        val onlyDouble = listOf(option("1/2", 2, 0, PriceSlot.ADULT, "349"))
        solver.solve(onlyDouble, Party(adults = 3), 7) shouldBe null
    }

    // ------------------------------------------------------------------ apartmani

    @Test
    fun `apartman se placa ceo i po noci`() {
        val result = total(Party(adults = 4), options = apartmentPricing()).shouldNotBeNull()
        result.total shouldBe BigDecimal("420.00")   // 60 x 7
    }

    @Test
    fun `dve osobe uzimaju jeftiniji studio`() {
        val result = total(Party(adults = 2), options = apartmentPricing()).shouldNotBeNull()
        result.total shouldBe BigDecimal("315.00")   // 45 x 7
        result.rooms.single().roomCode shouldBe "SU2/3"
    }

    @Test
    fun `sest osoba u dva studija je jeftinije od apartmana i studija`() {
        val result = total(Party(adults = 6), options = apartmentPricing()).shouldNotBeNull()
        result.total shouldBe BigDecimal("630.00")   // 2 x 315 < 420 + 315
        result.roomCount shouldBe 2
    }

    // ------------------------------------------------------------------ ostalo

    @Test
    fun `cena po osobi se racuna na ukupan broj putnika`() {
        val party = Party(adults = 2, childAges = listOf(8))
        val result = total(party).shouldNotBeNull()
        result.perPerson(party.size) shouldBe BigDecimal("299.00")   // 897 / 3
    }

    @Test
    fun `minimumForAdults ne baca izuzetak za nemoguc broj osoba`() {
        solver.minimumForAdults(hotelPricing(), adults = 99, nights = 7) shouldBe null
    }
}
