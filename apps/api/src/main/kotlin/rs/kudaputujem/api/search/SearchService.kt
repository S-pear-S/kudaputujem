package rs.kudaputujem.api.search

import com.fasterxml.jackson.core.type.TypeReference
import com.fasterxml.jackson.databind.ObjectMapper
import java.math.BigDecimal
import java.math.RoundingMode
import java.sql.ResultSet
import java.time.Instant
import java.time.temporal.ChronoUnit
import org.slf4j.LoggerFactory
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.stereotype.Service
import rs.kudaputujem.api.common.PageResponse
import rs.kudaputujem.api.config.ApiProperties
import rs.kudaputujem.api.domain.BoardType
import rs.kudaputujem.api.domain.PriceSlot
import rs.kudaputujem.api.domain.PricingBasis
import rs.kudaputujem.api.domain.ProductKind
import rs.kudaputujem.api.domain.TransportType
import rs.kudaputujem.api.pricing.ExchangeRateService
import rs.kudaputujem.api.pricing.OccupancySolver

private val STRING_LIST_TYPE = object : TypeReference<List<String>>() {}

@Service
class SearchService(
    private val jdbc: JdbcClient,
    private val solver: OccupancySolver,
    private val exchangeRates: ExchangeRateService,
    private val props: ApiProperties,
    private val mapper: ObjectMapper,
) {
    private val log = LoggerFactory.getLogger(SearchService::class.java)

    fun search(req: SearchRequest): PageResponse<OfferCard> {
        req.validate()

        val pageSize = minOf(req.pageSize, props.search.maxPageSize)
        val offset = (req.page - 1) * pageSize
        val minLastSeen = Instant.now().minus(props.search.maxStalenessHours, ChronoUnit.HOURS)

        val (sql, params) = buildQuery(req, offset, pageSize, minLastSeen)
        val t0 = System.currentTimeMillis()
        val rows = jdbc.sql(sql).params(params).query { rs, _ -> mapRow(rs) }.list()
        log.debug("search upit: {}ms, {} redova", System.currentTimeMillis() - t0, rows.size)

        val total = rows.firstOrNull()?.first ?: 0L
        var cards = rows.map { it.second }

        if (req.childAges.isNotEmpty() || req.rooms != null) {
            cards = applyExactPricing(cards, req)
        }

        return PageResponse.of(cards, total, req.page, pageSize)
    }

    // ---------------------------------------------------------------- exact pricing

    private fun applyExactPricing(cards: List<OfferCard>, req: SearchRequest): List<OfferCard> {
        if (cards.isEmpty()) return cards
        val party = req.toParty()
        val departureIds = cards.map { it.departure.departureId }
        val optionsByDeparture = loadPriceOptions(departureIds)

        return cards.map { card ->
            val options = optionsByDeparture[card.departure.departureId]
            if (options.isNullOrEmpty()) return@map card
            val solution = solver.solve(options, party, card.departure.nights) ?: return@map card
            val totalRsd = (solution.total * exchangeRates.toRsd(solution.currency))
                .setScale(2, RoundingMode.HALF_UP)
            card.copy(
                price = PriceSnippet(
                    totalAmount = solution.total,
                    perPersonAmount = solution.perPerson(party.size),
                    currency = solution.currency,
                    totalRsd = totalRsd,
                    isExact = true,
                ),
            )
        }
    }

    private fun loadPriceOptions(departureIds: List<Long>): Map<Long, List<OccupancySolver.PriceOption>> {
        if (departureIds.isEmpty()) return emptyMap()
        return jdbc.sql(
            """
            SELECT departure_id, room_code, room_name, capacity_adults, capacity_extra,
                   slot, pricing_basis, amount, currency, child_age_from, child_age_to
            FROM price_option
            WHERE departure_id IN (:ids)
            """.trimIndent()
        )
            .param("ids", departureIds)
            .query { rs, _ ->
                val depId = rs.getLong("departure_id")
                val option = OccupancySolver.PriceOption(
                    roomCode = rs.getString("room_code"),
                    roomName = rs.getString("room_name"),
                    capacityAdults = rs.getInt("capacity_adults"),
                    capacityExtra = rs.getInt("capacity_extra"),
                    slot = PriceSlot.fromDb(rs.getString("slot")),
                    pricingBasis = PricingBasis.fromDb(rs.getString("pricing_basis")),
                    amount = rs.getBigDecimal("amount"),
                    currency = rs.getString("currency"),
                    childAgeFrom = rs.getObject("child_age_from") as? Int,
                    childAgeTo = rs.getObject("child_age_to") as? Int,
                )
                depId to option
            }
            .list()
            .groupBy({ it.first }, { it.second })
    }

    // ---------------------------------------------------------------- SQL

    private fun buildQuery(
        req: SearchRequest,
        offset: Int,
        pageSize: Int,
        minLastSeen: Instant,
    ): Pair<String, Map<String, Any?>> {
        val conditions = mutableListOf<String>()
        val params = mutableMapOf<String, Any?>()

        params["adults"] = req.adults
        params["minLastSeen"] = java.sql.Timestamp.from(minLastSeen)

        if (req.productKind != null) {
            conditions += "o.product_kind = :productKind"
            params["productKind"] = req.productKind.name
        }
        if (req.destinationId != null) {
            conditions += "o.destination_id = :destinationId"
            params["destinationId"] = req.destinationId
        }
        if (req.countryCode != null) {
            conditions += "o.country_code = :countryCode"
            params["countryCode"] = req.countryCode.uppercase()
        }
        if (req.dateFrom != null) {
            conditions += "d.start_date >= :dateFrom"
            params["dateFrom"] = req.dateFrom
        }
        if (req.dateTo != null) {
            conditions += "d.start_date <= :dateTo"
            params["dateTo"] = req.dateTo
        }
        if (req.nightsMin != null) {
            conditions += "d.nights >= :nightsMin"
            params["nightsMin"] = req.nightsMin
        }
        if (req.nightsMax != null) {
            conditions += "d.nights <= :nightsMax"
            params["nightsMax"] = req.nightsMax
        }
        if (req.transportType != null) {
            conditions += "d.transport_type = :transportType"
            params["transportType"] = req.transportType.name
        }
        if (req.boardType != null) {
            // COALESCE je alias u SELECT, ne mozemo ga koristiti u WHERE — koristimo original
            conditions += "COALESCE(d.board_type, o.board_type) = :boardType"
            params["boardType"] = req.boardType.name
        }
        if (req.departurePlaceId != null) {
            conditions += "d.departure_place_id = :departurePlaceId"
            params["departurePlaceId"] = req.departurePlaceId
        }
        if (req.priceMax != null) {
            conditions += "dpi.per_person_rsd <= :priceMax"
            params["priceMax"] = req.priceMax
        }
        if (req.starsMin != null) {
            conditions += "a.stars >= :starsMin"
            params["starsMin"] = req.starsMin
        }

        val whereClause = if (conditions.isEmpty()) ""
        else "AND " + conditions.joinToString("\n              AND ")

        // starsMin filter zahteva smestaj — INNER JOIN iskljucuje ponude tipa TRANSPORT.
        val accJoin = if (req.starsMin != null)
            "JOIN accommodation a          ON a.id = o.accommodation_id"
        else
            "LEFT JOIN accommodation a     ON a.id = o.accommodation_id"

        val sortExpr = req.sortBy.sqlExpression
        val sortDir = req.sortDir.name

        val sql = """
            WITH cheapest AS (
                SELECT DISTINCT ON (o.id)
                    o.id                                            AS offer_id,
                    o.agency_id,
                    o.accommodation_id,
                    o.destination_id,
                    o.country_code,
                    o.product_kind,
                    o.title,
                    o.slug                                          AS offer_slug,
                    o.url,
                    o.images::text                                  AS offer_images_json,
                    o.last_seen_at,
                    d.id                                            AS departure_id,
                    d.start_date,
                    d.end_date,
                    d.nights,
                    d.transport_type                                AS dep_transport,
                    COALESCE(d.board_type, o.board_type)           AS dep_board,
                    d.departure_place_raw,
                    d.is_last_minute,
                    d.seats_left,
                    dpi.total_amount,
                    dpi.total_amount / dpi.pax                     AS per_person_amount,
                    dpi.total_rsd,
                    dpi.per_person_rsd,
                    dpi.currency                                    AS price_currency,
                    ag.id                                           AS agency_id_val,
                    ag.name                                         AS agency_name,
                    ag.slug                                         AS agency_slug,
                    ag.logo_url,
                    a.id                                            AS acc_id,
                    a.name                                          AS acc_name,
                    a.slug                                          AS acc_slug,
                    a.stars,
                    a.rating_avg,
                    a.images::text                                  AS acc_images_json,
                    dest.id                                         AS dest_id,
                    dest.name_sr,
                    dest.slug                                       AS dest_slug
                FROM departure_price_index dpi
                JOIN departure d              ON d.id = dpi.departure_id AND d.is_available
                JOIN offer o                  ON o.id = dpi.offer_id
                                             AND o.is_active
                                             AND o.last_seen_at >= :minLastSeen
                JOIN agency ag                ON ag.id = o.agency_id
                $accJoin
                LEFT JOIN destination dest    ON dest.id = o.destination_id
                WHERE dpi.pax = :adults
                  $whereClause
                ORDER BY o.id, dpi.per_person_rsd ASC
            )
            SELECT COUNT(*) OVER() AS total, *
            FROM cheapest
            ORDER BY $sortExpr $sortDir NULLS LAST
            LIMIT :pageSize OFFSET :offset
        """.trimIndent()

        params["pageSize"] = pageSize
        params["offset"] = offset

        return sql to params
    }

    // ---------------------------------------------------------------- mapping

    private fun mapRow(rs: ResultSet): Pair<Long, OfferCard> {
        val total = rs.getLong("total")

        val accId = rs.getObject("acc_id") as? Long
        val destId = rs.getObject("dest_id") as? Long

        val offerImages = parseImageList(rs.getString("offer_images_json"))
        val accImages = parseImageList(rs.getString("acc_images_json"))
        val images = (accImages + offerImages).distinct().take(5)

        val accommodation = if (accId != null) {
            AccommodationSnippet(
                id = accId,
                name = rs.getString("acc_name") ?: "",
                slug = rs.getString("acc_slug") ?: "",
                stars = (rs.getObject("stars") as? BigDecimal)?.toDouble(),
                ratingAvg = (rs.getObject("rating_avg") as? BigDecimal)?.toDouble(),
            )
        } else null

        val destination = if (destId != null) {
            DestinationSnippet(
                id = destId,
                nameSr = rs.getString("name_sr") ?: "",
                slug = rs.getString("dest_slug") ?: "",
                countryCode = rs.getString("country_code") ?: "",
            )
        } else null

        val card = OfferCard(
            offerId = rs.getLong("offer_id"),
            title = rs.getString("title"),
            slug = rs.getString("offer_slug"),
            url = rs.getString("url"),
            productKind = ProductKind.fromDb(rs.getString("product_kind")),
            agency = AgencySnippet(
                id = rs.getLong("agency_id_val"),
                name = rs.getString("agency_name"),
                slug = rs.getString("agency_slug"),
                logoUrl = rs.getString("logo_url"),
            ),
            accommodation = accommodation,
            destination = destination,
            departure = DepartureSnippet(
                departureId = rs.getLong("departure_id"),
                startDate = rs.getDate("start_date").toLocalDate(),
                endDate = rs.getDate("end_date").toLocalDate(),
                nights = rs.getInt("nights"),
                transportType = TransportType.fromDb(rs.getString("dep_transport")),
                boardType = BoardType.fromDb(rs.getString("dep_board")),
                departurePlaceRaw = rs.getString("departure_place_raw"),
                seatsLeft = rs.getObject("seats_left") as? Int,
            ),
            price = PriceSnippet(
                totalAmount = rs.getBigDecimal("total_amount"),
                perPersonAmount = rs.getBigDecimal("per_person_amount"),
                currency = rs.getString("price_currency"),
                totalRsd = rs.getBigDecimal("total_rsd"),
                isExact = false,
            ),
            images = images,
            lastSeenAt = rs.getTimestamp("last_seen_at").toInstant(),
            isLastMinute = rs.getBoolean("is_last_minute"),
        )

        return total to card
    }

    private fun parseImageList(json: String?): List<String> {
        if (json.isNullOrBlank() || json == "null") return emptyList()
        return try {
            mapper.readValue(json, STRING_LIST_TYPE)
        } catch (e: Exception) {
            log.warn("Nije moguće parsirati images JSON: {}", json)
            emptyList()
        }
    }
}
