package rs.kudaputujem.api.search

import jakarta.validation.constraints.Max
import jakarta.validation.constraints.Min
import java.math.BigDecimal
import java.time.LocalDate
import rs.kudaputujem.api.domain.BoardType
import rs.kudaputujem.api.domain.ProductKind
import rs.kudaputujem.api.domain.SortBy
import rs.kudaputujem.api.domain.SortDirection
import rs.kudaputujem.api.domain.TransportType
import rs.kudaputujem.api.pricing.OccupancySolver

data class SearchRequest(
    val productKind: ProductKind? = null,

    /** ID destinacije iz tabele destination. */
    val destinationId: Long? = null,

    /** Dvoslovni ISO kod države, alternativa destinationId. */
    val countryCode: String? = null,

    /** Datum polaska od (uključivo). */
    val dateFrom: LocalDate? = null,

    /** Datum polaska do (uključivo). */
    val dateTo: LocalDate? = null,

    @field:Min(1) @field:Max(30) val nightsMin: Int? = null,
    @field:Min(1) @field:Max(30) val nightsMax: Int? = null,

    @field:Min(1) @field:Max(8) val adults: Int = 2,

    /** Uzrasti dece u godinama (0..17). Šalje se kao ?childAges=5&childAges=8. */
    val childAges: List<Int> = emptyList(),

    /** Ako je zadat, OccupancySolver mora da smesti grupu u tačno taj broj soba. */
    @field:Min(1) @field:Max(6) val rooms: Int? = null,

    val transportType: TransportType? = null,
    val boardType: BoardType? = null,

    /** ID destinacije koja je polazište (is_departure_hub = true). */
    val departurePlaceId: Long? = null,

    /** Maksimalna cena po osobi u RSD (poredi se sa departure_price_index.per_person_rsd). */
    val priceMax: BigDecimal? = null,

    /** Minimalan broj zvezdica hotela (npr. 4.0 = 4 zvezde). */
    @field:Min(1) @field:Max(5) val starsMin: Double? = null,

    val sortBy: SortBy = SortBy.PRICE_PER_PERSON,
    val sortDir: SortDirection = SortDirection.ASC,

    @field:Min(1) val page: Int = 1,
    @field:Min(1) @field:Max(100) val pageSize: Int = 20,
) {
    fun toParty(): OccupancySolver.Party = OccupancySolver.Party(
        adults = adults,
        childAges = childAges,
        rooms = rooms,
    )

    fun validate() {
        if (dateFrom != null && dateTo != null)
            require(!dateTo.isBefore(dateFrom)) { "dateTo ne sme biti pre dateFrom" }
        if (nightsMin != null && nightsMax != null)
            require(nightsMin <= nightsMax) { "nightsMin mora biti <= nightsMax" }
        require(childAges.all { it in 0..17 }) { "uzrast deteta mora biti 0..17" }
        require(childAges.size <= OccupancySolver.MAX_CHILDREN) { "najviše ${OccupancySolver.MAX_CHILDREN} dece" }
    }
}
