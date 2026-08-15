package rs.kudaputujem.api.ingest

import com.fasterxml.jackson.databind.ObjectMapper
import java.security.MessageDigest
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import rs.kudaputujem.api.accommodation.AccommodationResolver
import rs.kudaputujem.api.common.Text
import rs.kudaputujem.api.geo.DestinationResolver

/**
 * Upisuje jednu ponudu sa svim terminima i cenama.
 *
 * ## Zasto se termini i cene BRISU pa ponovo upisuju
 *
 * Cena i termin nemaju stabilan identitet na sajtu agencije — danas je red "1/2 349",
 * sutra "1/2 359", i to je ista stvar sa novom vrednoscu, a ne nova stvar. Diff-ovanje bi
 * trazilo vestacki kljuc koji agencija ne daje. Brisanje i ponovni upis je jednostavnije,
 * brze u batch-u, i nema rizik od "duh" redova koji ostanu iz prethodne runde.
 *
 * Ponuda se NE brise, jer ona ima stabilan `external_id`, SEO stranicu i istoriju.
 */
@Component
class OfferWriter(
    private val jdbc: JdbcClient,
    private val destinations: DestinationResolver,
    private val accommodations: AccommodationResolver,
    private val objectMapper: ObjectMapper,
) {

    enum class Outcome { CREATED, UPDATED, UNCHANGED }

    data class WriteResult(val offerId: Long, val outcome: Outcome)

    @Transactional
    fun write(offer: OfferIn, sourceId: Long, agencyId: Long): WriteResult {
        offer.validate()

        val destination = destinations.resolve(
            rawName = offer.destinationRaw,
            countryHint = null,
            sourceId = sourceId,
        )
        val accommodationId = offer.accommodation?.let {
            accommodations.resolveOrCreate(it, destination.destinationId, sourceId)
        }

        val hash = contentHash(offer)
        val existing = jdbc.sql(
            "SELECT id, content_hash FROM offer WHERE source_id = :sourceId AND external_id = :externalId"
        )
            .param("sourceId", sourceId)
            .param("externalId", offer.externalId)
            .query { rs, _ -> rs.getLong("id") to rs.getString("content_hash") }
            .optional()
            .orElse(null)

        if (existing != null && existing.second == hash) {
            touch(existing.first)
            return WriteResult(existing.first, Outcome.UNCHANGED)
        }

        val offerId = upsertOffer(offer, sourceId, agencyId, destination, accommodationId, hash)
        replaceChildren(offerId, offer)
        refreshDenormalizedColumns(offerId)

        return WriteResult(offerId, if (existing == null) Outcome.CREATED else Outcome.UPDATED)
    }

    // ------------------------------------------------------------------ ponuda

    private fun upsertOffer(
        offer: OfferIn,
        sourceId: Long,
        agencyId: Long,
        destination: DestinationResolver.Resolution,
        accommodationId: Long?,
        hash: String,
    ): Long = jdbc.sql(
        """
        INSERT INTO offer (
            source_id, agency_id, external_id, product_kind, title, slug, url,
            accommodation_id, destination_id, country_code, transport_type, board_type,
            description, images, highlights, included, not_included, raw_attributes,
            currency, content_hash, is_active, last_seen_at, last_changed_at
        ) VALUES (
            :sourceId, :agencyId, :externalId, :productKind, :title, :slug, :url,
            :accommodationId, :destinationId, :countryCode, :transportType, :boardType,
            :description, CAST(:images AS jsonb), CAST(:highlights AS jsonb),
            CAST(:included AS jsonb), CAST(:notIncluded AS jsonb), CAST(:rawAttributes AS jsonb),
            :currency, :contentHash, TRUE, now(), now()
        )
        ON CONFLICT (source_id, external_id) DO UPDATE SET
            product_kind = EXCLUDED.product_kind,
            title = EXCLUDED.title,
            slug = EXCLUDED.slug,
            url = EXCLUDED.url,
            accommodation_id = COALESCE(EXCLUDED.accommodation_id, offer.accommodation_id),
            destination_id = COALESCE(EXCLUDED.destination_id, offer.destination_id),
            country_code = COALESCE(EXCLUDED.country_code, offer.country_code),
            transport_type = EXCLUDED.transport_type,
            board_type = EXCLUDED.board_type,
            description = EXCLUDED.description,
            images = EXCLUDED.images,
            highlights = EXCLUDED.highlights,
            included = EXCLUDED.included,
            not_included = EXCLUDED.not_included,
            raw_attributes = EXCLUDED.raw_attributes,
            currency = EXCLUDED.currency,
            content_hash = EXCLUDED.content_hash,
            is_active = TRUE,
            last_seen_at = now(),
            last_changed_at = now(),
            updated_at = now()
        RETURNING id
        """.trimIndent()
    )
        .param("sourceId", sourceId)
        .param("agencyId", agencyId)
        .param("externalId", offer.externalId)
        .param("productKind", offer.productKind.name)
        .param("title", offer.title)
        .param("slug", Text.slugify(offer.title))
        .param("url", offer.url)
        .param("accommodationId", accommodationId)
        .param("destinationId", destination.destinationId)
        .param("countryCode", destination.countryCode)
        .param("transportType", offer.transportType.name)
        .param("boardType", offer.boardType.name)
        .param("description", offer.description)
        .param("images", json(offer.images))
        .param("highlights", json(offer.highlights))
        .param("included", json(offer.included))
        .param("notIncluded", json(offer.notIncluded))
        .param("rawAttributes", json(offer.rawAttributes))
        .param("currency", offer.currency)
        .param("contentHash", hash)
        .query(Long::class.java)
        .single()

    private fun touch(offerId: Long) {
        jdbc.sql("UPDATE offer SET last_seen_at = now(), is_active = TRUE WHERE id = :id")
            .param("id", offerId)
            .update()
        jdbc.sql("UPDATE departure SET last_seen_at = now() WHERE offer_id = :id")
            .param("id", offerId)
            .update()
    }

    // ------------------------------------------------------------------ termini i cene

    private fun replaceChildren(offerId: Long, offer: OfferIn) {
        // CASCADE brise price_option, surcharge i transport_leg vezane za termine.
        jdbc.sql("DELETE FROM departure WHERE offer_id = :offerId").param("offerId", offerId).update()
        jdbc.sql("DELETE FROM surcharge WHERE offer_id = :offerId AND departure_id IS NULL")
            .param("offerId", offerId).update()

        offer.surcharges.forEach { insertSurcharge(offerId, null, it, offer.currency) }

        for (departure in offer.departures) {
            val departureId = insertDeparture(offerId, departure, offer)
            departure.prices.forEach { insertPrice(offerId, departureId, it, offer.currency) }
            departure.surcharges.forEach { insertSurcharge(offerId, departureId, it, offer.currency) }
            departure.legs.forEach { insertLeg(offerId, departureId, it) }
        }
    }

    private fun insertDeparture(offerId: Long, departure: DepartureIn, offer: OfferIn): Long {
        val minPrice = departure.prices
            .filter { it.slot.name == "ADULT" || it.slot.name == "UNIT" }
            .minOfOrNull { it.amount }

        return jdbc.sql(
            """
            INSERT INTO departure (
                offer_id, external_id, start_date, end_date, nights, days,
                transport_type, departure_place_id, departure_place_raw, board_type,
                is_available, seats_left, is_last_minute, min_price, currency, last_seen_at
            ) VALUES (
                :offerId, :externalId, :startDate, :endDate, :nights, :days,
                :transportType, :departurePlaceId, :departurePlaceRaw, :boardType,
                :isAvailable, :seatsLeft, :isLastMinute, :minPrice, :currency, now()
            )
            RETURNING id
            """.trimIndent()
        )
            .param("offerId", offerId)
            .param("externalId", departure.externalId)
            .param("startDate", departure.startDate)
            .param("endDate", departure.endDate)
            .param("nights", departure.effectiveNights)
            .param("days", departure.days ?: (departure.effectiveNights + 1))
            .param("transportType", departure.transportType.name)
            .param("departurePlaceId", destinations.resolveDepartureHub(departure.departurePlaceRaw))
            .param("departurePlaceRaw", departure.departurePlaceRaw)
            .param("boardType", (departure.boardType ?: offer.boardType).name)
            .param("isAvailable", departure.isAvailable)
            .param("seatsLeft", departure.seatsLeft)
            .param("isLastMinute", departure.isLastMinute)
            .param("minPrice", minPrice)
            .param("currency", offer.currency)
            .query(Long::class.java)
            .single()
    }

    private fun insertPrice(offerId: Long, departureId: Long, price: PriceOptionIn, fallbackCurrency: String) {
        jdbc.sql(
            """
            INSERT INTO price_option (
                departure_id, offer_id, room_code, room_name, capacity_adults, capacity_extra,
                capacity_total, slot, pricing_basis, board_type, child_age_from, child_age_to,
                amount, currency, original_amount, discount_label, is_promo, min_stay_nights, notes
            ) VALUES (
                :departureId, :offerId, :roomCode, :roomName, :capacityAdults, :capacityExtra,
                :capacityTotal, :slot, :pricingBasis, :boardType, :childAgeFrom, :childAgeTo,
                :amount, :currency, :originalAmount, :discountLabel, :isPromo, :minStayNights, :notes
            )
            """.trimIndent()
        )
            .param("departureId", departureId)
            .param("offerId", offerId)
            .param("roomCode", price.roomCode)
            .param("roomName", price.roomName)
            .param("capacityAdults", price.capacityAdults)
            .param("capacityExtra", price.capacityExtra)
            .param("capacityTotal", price.capacityTotal ?: (price.capacityAdults + price.capacityExtra))
            .param("slot", price.slot.name)
            .param("pricingBasis", price.pricingBasis.name)
            .param("boardType", price.boardType?.name)
            .param("childAgeFrom", price.childAgeFrom)
            .param("childAgeTo", price.childAgeTo)
            .param("amount", price.amount)
            .param("currency", price.currency.ifBlank { fallbackCurrency })
            .param("originalAmount", price.originalAmount)
            .param("discountLabel", price.discountLabel)
            .param("isPromo", price.isPromo)
            .param("minStayNights", price.minStayNights)
            .param("notes", price.notes)
            .update()
    }

    private fun insertSurcharge(
        offerId: Long,
        departureId: Long?,
        surcharge: SurchargeIn,
        fallbackCurrency: String,
    ) {
        jdbc.sql(
            """
            INSERT INTO surcharge
                (offer_id, departure_id, code, name, kind, unit, amount, currency, payable, raw_text)
            VALUES
                (:offerId, :departureId, :code, :name, :kind, :unit, :amount, :currency, :payable, :rawText)
            """.trimIndent()
        )
            .param("offerId", offerId)
            .param("departureId", departureId)
            .param("code", surcharge.code.name)
            .param("name", surcharge.name)
            .param("kind", surcharge.kind.name)
            .param("unit", surcharge.unit.name)
            .param("amount", surcharge.amount)
            .param("currency", surcharge.currency ?: fallbackCurrency)
            .param("payable", surcharge.payable.name)
            .param("rawText", surcharge.rawText)
            .update()
    }

    private fun insertLeg(offerId: Long, departureId: Long, leg: TransportLegIn) {
        jdbc.sql(
            """
            INSERT INTO transport_leg (
                offer_id, departure_id, leg_index, direction, mode, carrier_name, carrier_code,
                vehicle_number, from_place_raw, from_terminal, to_place_raw, to_terminal,
                depart_at, arrive_at, depart_local, arrive_local, duration_minutes, stops
            ) VALUES (
                :offerId, :departureId, :legIndex, :direction, :mode, :carrierName, :carrierCode,
                :vehicleNumber, :fromPlaceRaw, :fromTerminal, :toPlaceRaw, :toTerminal,
                CAST(:departAt AS timestamptz), CAST(:arriveAt AS timestamptz),
                :departLocal, :arriveLocal, :durationMinutes, :stops
            )
            """.trimIndent()
        )
            .param("offerId", offerId)
            .param("departureId", departureId)
            .param("legIndex", leg.legIndex)
            .param("direction", leg.direction)
            .param("mode", leg.mode.name)
            .param("carrierName", leg.carrierName)
            .param("carrierCode", leg.carrierCode)
            .param("vehicleNumber", leg.vehicleNumber)
            .param("fromPlaceRaw", leg.fromPlaceRaw)
            .param("fromTerminal", leg.fromTerminal)
            .param("toPlaceRaw", leg.toPlaceRaw)
            .param("toTerminal", leg.toTerminal)
            .param("departAt", leg.departAt)
            .param("arriveAt", leg.arriveAt)
            .param("departLocal", leg.departLocal)
            .param("arriveLocal", leg.arriveLocal)
            .param("durationMinutes", leg.durationMinutes)
            .param("stops", leg.stops)
            .update()
    }

    /** Denormalizovane kolone na `offer` koje pretraga koristi za brzo filtriranje. */
    private fun refreshDenormalizedColumns(offerId: Long) {
        jdbc.sql(
            """
            UPDATE offer o SET
                min_nights = agg.min_nights,
                max_nights = agg.max_nights,
                first_departure = agg.first_departure,
                last_departure = agg.last_departure,
                departure_count = agg.departure_count
            FROM (
                SELECT
                    MIN(nights) AS min_nights,
                    MAX(nights) AS max_nights,
                    MIN(start_date) AS first_departure,
                    MAX(start_date) AS last_departure,
                    COUNT(*) AS departure_count
                FROM departure WHERE offer_id = :offerId
            ) agg
            WHERE o.id = :offerId
            """.trimIndent()
        )
            .param("offerId", offerId)
            .update()
    }

    // ------------------------------------------------------------------ pomocno

    /**
     * Hash sadrzaja. Ako se ne promeni, ponuda se samo "dodirne" i preskace se ceo
     * upis termina i cena — sto je razlika izmedju runde od 20 sekundi i runde od 4 minuta.
     */
    private fun contentHash(offer: OfferIn): String {
        val canonical = objectMapper.writeValueAsString(offer)
        val digest = MessageDigest.getInstance("SHA-256").digest(canonical.toByteArray())
        return digest.joinToString("") { "%02x".format(it) }
    }

    private fun json(value: Any?): String = objectMapper.writeValueAsString(value)
}
