package rs.kudaputujem.api.search

import java.math.BigDecimal
import java.time.Instant
import java.time.LocalDate
import rs.kudaputujem.api.domain.BoardType
import rs.kudaputujem.api.domain.ProductKind
import rs.kudaputujem.api.domain.TransportType

data class OfferCard(
    val offerId: Long,
    val title: String,
    val slug: String,

    /** Direktan link ka ponudi na sajtu agencije. */
    val url: String,

    val productKind: ProductKind,
    val agency: AgencySnippet,

    /** Null za ponude tipa TRANSPORT. */
    val accommodation: AccommodationSnippet?,

    /** Null ako agencija nije navela destinaciju u prepoznatljivom obliku. */
    val destination: DestinationSnippet?,

    /** Najjeftiniji termin koji odgovara filteru. */
    val departure: DepartureSnippet,

    val price: PriceSnippet,

    /** Do 5 URL-ova slika (najpre smestaj, pa ponuda). */
    val images: List<String>,

    val lastSeenAt: Instant,
    val isLastMinute: Boolean,
)

data class AgencySnippet(
    val id: Long,
    val name: String,
    val slug: String,
    val logoUrl: String?,
)

data class AccommodationSnippet(
    val id: Long,
    val name: String,
    val slug: String,
    val stars: Double?,
    val ratingAvg: Double?,
)

data class DestinationSnippet(
    val id: Long,
    val nameSr: String,
    val slug: String,
    val countryCode: String,
)

data class DepartureSnippet(
    val departureId: Long,
    val startDate: LocalDate,
    val endDate: LocalDate,
    val nights: Int,
    val transportType: TransportType,
    val boardType: BoardType,
    val departurePlaceRaw: String?,
    val seatsLeft: Int?,
)

data class PriceSnippet(
    val totalAmount: BigDecimal,
    val perPersonAmount: BigDecimal,
    val currency: String,

    /** Ukupno u RSD (za internu upotrebu / sorting prikaz). */
    val totalRsd: BigDecimal,

    /**
     * false = cena iz departure_price_index (samo odrasli, bez dece).
     * true  = tacna cena od OccupancySolvera (ukljucuje decu).
     */
    val isExact: Boolean,
)
