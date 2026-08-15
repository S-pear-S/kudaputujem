package rs.kudaputujem.api.ingest

import jakarta.validation.Valid
import jakarta.validation.constraints.Max
import jakarta.validation.constraints.Min
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotEmpty
import jakarta.validation.constraints.Pattern
import jakarta.validation.constraints.PositiveOrZero
import jakarta.validation.constraints.Size
import java.math.BigDecimal
import java.time.LocalDate
import rs.kudaputujem.api.domain.AccommodationKind
import rs.kudaputujem.api.domain.BoardType
import rs.kudaputujem.api.domain.Payable
import rs.kudaputujem.api.domain.PriceSlot
import rs.kudaputujem.api.domain.PricingBasis
import rs.kudaputujem.api.domain.ProductKind
import rs.kudaputujem.api.domain.SurchargeCode
import rs.kudaputujem.api.domain.SurchargeKind
import rs.kudaputujem.api.domain.SurchargeUnit
import rs.kudaputujem.api.domain.TransportType

/**
 * Ugovor sa skreperima.
 *
 * OGLEDALO je `apps/scrapers/src/travelscrape/core/models.py`. Svaka promena ovde
 * mora da ide zajedno sa promenom tamo, inace skreper salje polje koje API ignorise
 * i niko to ne primeti dok korisnik ne pita zasto nema cene.
 *
 * Validacija je namerno stroga: bolje da batch padne sa jasnom porukom nego da u bazu
 * udje termin sa `end_date` pre `start_date`.
 */

data class PriceOptionIn(
    @field:NotBlank val roomCode: String,
    val roomName: String? = null,
    @field:Min(1) @field:Max(12) val capacityAdults: Int = 2,
    @field:Min(0) @field:Max(6) val capacityExtra: Int = 0,
    val capacityTotal: Int? = null,
    val slot: PriceSlot = PriceSlot.ADULT,
    val pricingBasis: PricingBasis = PricingBasis.PER_PERSON_PER_STAY,
    val boardType: BoardType? = null,
    @field:Min(0) @field:Max(17) val childAgeFrom: Int? = null,
    @field:Min(0) @field:Max(17) val childAgeTo: Int? = null,
    @field:PositiveOrZero val amount: BigDecimal,
    @field:Pattern(regexp = "[A-Z]{3}") val currency: String = "EUR",
    val originalAmount: BigDecimal? = null,
    val discountLabel: String? = null,
    val isPromo: Boolean = false,
    val minStayNights: Int? = null,
    val notes: String? = null,
)

data class SurchargeIn(
    val code: SurchargeCode = SurchargeCode.OTHER,
    @field:NotBlank val name: String,
    val kind: SurchargeKind = SurchargeKind.MANDATORY,
    val unit: SurchargeUnit = SurchargeUnit.PER_PERSON,
    val amount: BigDecimal? = null,
    val currency: String? = null,
    val payable: Payable = Payable.IN_ADVANCE,
    val rawText: String? = null,
)

data class TransportLegIn(
    val legIndex: Int = 0,
    val direction: String = "OUTBOUND",
    val mode: TransportType,
    val carrierName: String? = null,
    val carrierCode: String? = null,
    val vehicleNumber: String? = null,
    @field:NotBlank val fromPlaceRaw: String,
    val fromTerminal: String? = null,
    @field:NotBlank val toPlaceRaw: String,
    val toTerminal: String? = null,
    val departAt: String? = null,
    val arriveAt: String? = null,
    val departLocal: String? = null,
    val arriveLocal: String? = null,
    val durationMinutes: Int? = null,
    val stops: Int = 0,
)

data class DepartureIn(
    val externalId: String? = null,
    val startDate: LocalDate,
    val endDate: LocalDate,
    val nights: Int? = null,
    val days: Int? = null,
    val transportType: TransportType = TransportType.NONE,
    val departurePlaceRaw: String? = null,
    val boardType: BoardType? = null,
    val isAvailable: Boolean = true,
    val seatsLeft: Int? = null,
    val isLastMinute: Boolean = false,
    @field:Valid val prices: List<PriceOptionIn> = emptyList(),
    @field:Valid val surcharges: List<SurchargeIn> = emptyList(),
    @field:Valid val legs: List<TransportLegIn> = emptyList(),
) {
    /** Broj nocenja; ako ga skreper nije poslao, izvodi se iz datuma. */
    val effectiveNights: Int get() = nights ?: (endDate.toEpochDay() - startDate.toEpochDay()).toInt()

    fun validate() {
        require(!endDate.isBefore(startDate)) {
            "termin $startDate..$endDate ima datum povratka pre datuma polaska"
        }
        require(effectiveNights <= 60) { "sumnjivo dug termin: $effectiveNights noći" }
    }
}

data class AccommodationIn(
    @field:NotBlank val name: String,
    val kind: AccommodationKind = AccommodationKind.HOTEL,
    val stars: Double? = null,
    val destinationRaw: String? = null,
    val address: String? = null,
    val latitude: Double? = null,
    val longitude: Double? = null,
    val distanceToBeachM: Int? = null,
    val description: String? = null,
    val amenities: List<String> = emptyList(),
    val images: List<String> = emptyList(),
    val externalId: String? = null,
)

data class OfferIn(
    @field:NotBlank val sourceSlug: String,
    @field:NotBlank val externalId: String,
    val productKind: ProductKind,
    @field:NotBlank @field:Size(max = 500) val title: String,
    @field:NotBlank @field:Pattern(regexp = "https?://.+") val url: String,
    val countryRaw: String? = null,
    val destinationRaw: String? = null,
    @field:Valid val accommodation: AccommodationIn? = null,
    val transportType: TransportType = TransportType.NONE,
    val boardType: BoardType = BoardType.NONE,
    val description: String? = null,
    val images: List<String> = emptyList(),
    val highlights: List<String> = emptyList(),
    val included: List<String> = emptyList(),
    val notIncluded: List<String> = emptyList(),
    val rawAttributes: Map<String, Any?> = emptyMap(),
    @field:Pattern(regexp = "[A-Z]{3}") val currency: String = "EUR",
    @field:Valid val departures: List<DepartureIn> = emptyList(),
    @field:Valid val surcharges: List<SurchargeIn> = emptyList(),
) {
    fun validate() {
        if (productKind == ProductKind.PACKAGE) {
            require(departures.isNotEmpty()) { "aranžman bez ijednog termina" }
            require(accommodation != null) { "aranžman bez smeštaja" }
        }
        departures.forEach { it.validate() }
    }
}

data class IngestBatch(
    val runId: Long,
    @field:NotBlank val sourceSlug: String,
    @field:NotEmpty @field:Valid val offers: List<OfferIn>,
    /** Kad je `true`, nista se ne upisuje; vraca se samo dijagnostika. */
    val dryRun: Boolean = false,
)

data class IngestResult(
    val received: Int = 0,
    val created: Int = 0,
    val updated: Int = 0,
    val unchanged: Int = 0,
    val failed: Int = 0,
    val dryRun: Boolean = false,
    val errors: List<String> = emptyList(),
    /** Prosek popunjenosti polja; nizak broj znaci da adapter promasuje selektore. */
    val avgCompleteness: Double = 0.0,
)

data class StartRunRequest(
    @field:NotBlank val sourceSlug: String,
    val triggerKind: String = "MANUAL",
    val scraperVersion: String? = null,
)

data class StartRunResponse(
    val runId: Long,
    val sourceId: Long,
    val sourceSlug: String,
    val crawlDelayMs: Int,
    val maxConcurrency: Int,
    val requiresBrowser: Boolean,
    val config: Map<String, Any?>,
)

data class FinishRunRequest(
    val status: String = "OK",
    val pagesFetched: Int = 0,
    val itemsFound: Int = 0,
    val itemsFailed: Int = 0,
    val errorMessage: String? = null,
    val stats: Map<String, Any?> = emptyMap(),
    /** Preskace SUSPECT proveru. Koristi se kad je pad ponude stvaran (kraj sezone). */
    val force: Boolean = false,
)

data class FinishRunResponse(
    val runId: Long,
    val status: String,
    val itemsExpired: Int,
    val message: String,
)
