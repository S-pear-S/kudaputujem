package rs.kudaputujem.api.pricing

import com.fasterxml.jackson.databind.ObjectMapper
import java.math.BigDecimal
import java.math.RoundingMode
import org.slf4j.LoggerFactory
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import rs.kudaputujem.api.domain.PriceSlot
import rs.kudaputujem.api.domain.PricingBasis

/**
 * Puni `departure_price_index` — denormalizovanu tabelu koju pretraga koristi za
 * filtriranje i sortiranje po ceni.
 *
 * ## Zasto ovo postoji
 *
 * Raspored putnika po sobama je optimizacioni problem i ne moze u `WHERE` klauzulu.
 * Bez ovog indeksa, upit "4 odrasla, Grcka, jul, do 1500 EUR" bi morao da resi hiljade
 * malih problema po zahtevu. Sa indeksom, to je obican `BETWEEN` nad indeksiranom kolonom.
 *
 * Indeks pokriva samo odrasle (1..8). Tacna cena sa decom se racuna `OccupancySolver`-om
 * za stranicu rezultata, nad najvise 50 ponuda. To je namerna razmena: indeks bi sa svim
 * kombinacijama uzrasta dece bio red velicine veci, a decija cena menja poredak retko.
 */
@Service
class PriceIndexBuilder(
    private val jdbc: JdbcClient,
    private val solver: OccupancySolver,
    private val exchangeRates: ExchangeRateService,
    private val objectMapper: ObjectMapper,
) {

    private val log = LoggerFactory.getLogger(PriceIndexBuilder::class.java)

    @Transactional
    fun rebuildForOffers(offerIds: List<Long>) {
        if (offerIds.isEmpty()) return
        val distinct = offerIds.distinct()
        distinct.chunked(200).forEach { chunk ->
            jdbc.sql(
                "DELETE FROM departure_price_index WHERE offer_id IN (:ids)"
            ).param("ids", chunk).update()
        }
        distinct.forEach { rebuildOffer(it) }
        log.debug("Price index osvezen za {} ponuda", distinct.size)
    }

    @Transactional
    fun rebuildForDeparture(departureId: Long) {
        jdbc.sql("DELETE FROM departure_price_index WHERE departure_id = :id")
            .param("id", departureId).update()
        loadDepartures(departureIds = listOf(departureId)).forEach { insertRows(it) }
    }

    private fun rebuildOffer(offerId: Long) {
        loadDepartures(offerId = offerId).forEach { insertRows(it) }
    }

    // ------------------------------------------------------------------ interno

    private data class DepartureBundle(
        val departureId: Long,
        val offerId: Long,
        val nights: Int,
        val options: List<OccupancySolver.PriceOption>,
    )

    private fun loadDepartures(
        offerId: Long? = null,
        departureIds: List<Long>? = null,
    ): List<DepartureBundle> {
        val where = if (offerId != null) "d.offer_id = :offerId" else "d.id IN (:departureIds)"
        val rows = jdbc.sql(
            """
            SELECT d.id AS departure_id, d.offer_id, d.nights,
                   p.room_code, p.room_name, p.capacity_adults, p.capacity_extra,
                   p.slot, p.pricing_basis, p.amount, p.currency,
                   p.child_age_from, p.child_age_to
            FROM departure d
            JOIN price_option p ON p.departure_id = d.id
            WHERE $where AND d.is_available
            """.trimIndent()
        )
            .let { spec ->
                if (offerId != null) spec.param("offerId", offerId)
                else spec.param("departureIds", departureIds)
            }
            .query { rs, _ ->
                Triple(
                    rs.getLong("departure_id"),
                    rs.getLong("offer_id") to rs.getInt("nights"),
                    OccupancySolver.PriceOption(
                        roomCode = rs.getString("room_code"),
                        roomName = rs.getString("room_name"),
                        capacityAdults = rs.getInt("capacity_adults"),
                        capacityExtra = rs.getInt("capacity_extra"),
                        slot = PriceSlot.fromDb(rs.getString("slot")),
                        pricingBasis = PricingBasis.fromDb(rs.getString("pricing_basis")),
                        amount = rs.getBigDecimal("amount"),
                        currency = rs.getString("currency"),
                        childAgeFrom = rs.getObject("child_age_from") as Int?,
                        childAgeTo = rs.getObject("child_age_to") as Int?,
                    ),
                )
            }
            .list()

        return rows.groupBy { it.first }.map { (departureId, group) ->
            DepartureBundle(
                departureId = departureId,
                offerId = group.first().second.first,
                nights = group.first().second.second,
                options = group.map { it.third },
            )
        }
    }

    private fun insertRows(bundle: DepartureBundle) {
        if (bundle.options.isEmpty()) return
        val currency = bundle.options.first().currency
        val rate = exchangeRates.toRsd(currency)

        for (pax in 1..OccupancySolver.MAX_ADULTS) {
            val solution = solver.minimumForAdults(bundle.options, pax, bundle.nights) ?: continue
            val totalRsd = (solution.total * rate).setScale(2, RoundingMode.HALF_UP)
            val plan = solution.rooms.groupingBy { it.roomCode }.eachCount()
                .map { (code, count) -> mapOf("roomCode" to code, "count" to count) }

            jdbc.sql(
                """
                INSERT INTO departure_price_index
                    (departure_id, offer_id, pax, rooms_used, total_amount, total_rsd,
                     per_person_rsd, currency, plan, computed_at)
                VALUES
                    (:departureId, :offerId, :pax, :roomsUsed, :totalAmount, :totalRsd,
                     :perPersonRsd, :currency, CAST(:plan AS jsonb), now())
                ON CONFLICT (departure_id, pax) DO UPDATE SET
                    rooms_used = EXCLUDED.rooms_used,
                    total_amount = EXCLUDED.total_amount,
                    total_rsd = EXCLUDED.total_rsd,
                    per_person_rsd = EXCLUDED.per_person_rsd,
                    currency = EXCLUDED.currency,
                    plan = EXCLUDED.plan,
                    computed_at = now()
                """.trimIndent()
            )
                .param("departureId", bundle.departureId)
                .param("offerId", bundle.offerId)
                .param("pax", pax)
                .param("roomsUsed", solution.roomCount)
                .param("totalAmount", solution.total)
                .param("totalRsd", totalRsd)
                .param("perPersonRsd", totalRsd.divide(BigDecimal(pax), 2, RoundingMode.HALF_UP))
                .param("currency", currency)
                .param("plan", objectMapper.writeValueAsString(plan))
                .update()
        }

        // Denormalizacija naviše: najniža cena termina i ponude.
        jdbc.sql(
            """
            UPDATE departure d SET min_price_rsd = (
                SELECT MIN(total_rsd) FROM departure_price_index WHERE departure_id = d.id
            ) WHERE d.id = :departureId
            """.trimIndent()
        ).param("departureId", bundle.departureId).update()

        jdbc.sql(
            """
            UPDATE offer o SET min_price_rsd = (
                SELECT MIN(per_person_rsd) FROM departure_price_index WHERE offer_id = o.id
            ) WHERE o.id = :offerId
            """.trimIndent()
        ).param("offerId", bundle.offerId).update()
    }
}
