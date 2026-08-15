package rs.kudaputujem.api.geo

import org.slf4j.LoggerFactory
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import rs.kudaputujem.api.common.Text

/**
 * Mapira sirovo ime destinacije sa sajta agencije na kanonsku destinaciju.
 *
 * Postupak, redom:
 *   1. tacno poklapanje u `destination_alias` (normalizovan oblik)
 *   2. tacno poklapanje imena destinacije
 *   3. trigram slicnost iznad praga, uz istu zemlju ako je poznata
 *   4. nista — pravi se PENDING alias koji ceka rucnu potvrdu
 *
 * Korak 4 je namerno. Automatsko spajanje ispod praga bi spojilo "Sveti Stefan" (Crna Gora)
 * i "Sveti Vlas" (Bugarska), i korisnik bi rezervisao pogresnu drzavu. Duplikat je ruzan,
 * pogresno spajanje je stetno.
 */
@Service
class DestinationResolver(private val jdbc: JdbcClient) {

    private val log = LoggerFactory.getLogger(DestinationResolver::class.java)

    companion object {
        /** Ispod ovoga ne spajamo automatski. Dobijeno testiranjem na stvarnim imenima. */
        const val SIMILARITY_THRESHOLD = 0.82
    }

    data class Resolution(val destinationId: Long?, val countryCode: String?, val confident: Boolean)

    @Transactional
    fun resolve(rawName: String?, countryHint: String? = null, sourceId: Long? = null): Resolution {
        if (rawName.isNullOrBlank()) return Resolution(null, null, false)
        val normalized = Text.normalize(rawName)
        if (normalized.isEmpty()) return Resolution(null, null, false)

        exactAlias(normalized, sourceId)?.let { return it }
        exactName(normalized)?.let { return it }
        fuzzy(normalized, countryHint)?.let { hit ->
            rememberAlias(hit.destinationId!!, sourceId, rawName, normalized, "CONFIRMED")
            return hit
        }

        log.info("Nepoznata destinacija '{}' (izvor {}), upisujem kao PENDING", rawName, sourceId)
        rememberAlias(null, sourceId, rawName, normalized, "PENDING")
        return Resolution(null, countryHint, false)
    }

    private fun exactAlias(normalized: String, sourceId: Long?): Resolution? = jdbc.sql(
        """
        SELECT d.id, d.country_code
        FROM destination_alias a
        JOIN destination d ON d.id = a.destination_id
        WHERE a.normalized = :normalized
          AND a.status = 'CONFIRMED'
          AND (a.source_id IS NULL OR a.source_id = :sourceId)
        ORDER BY a.source_id NULLS LAST
        LIMIT 1
        """.trimIndent()
    )
        .param("normalized", normalized)
        .param("sourceId", sourceId)
        .query { rs, _ -> Resolution(rs.getLong("id"), rs.getString("country_code"), true) }
        .optional()
        .orElse(null)

    private fun exactName(normalized: String): Resolution? = jdbc.sql(
        """
        SELECT id, country_code FROM destination
        WHERE norm_text(name_sr) = :normalized AND is_active
        ORDER BY popularity DESC
        LIMIT 1
        """.trimIndent()
    )
        .param("normalized", normalized)
        .query { rs, _ -> Resolution(rs.getLong("id"), rs.getString("country_code"), true) }
        .optional()
        .orElse(null)

    private fun fuzzy(normalized: String, countryHint: String?): Resolution? = jdbc.sql(
        """
        SELECT id, country_code, similarity(norm_text(name_sr), :normalized) AS score
        FROM destination
        WHERE is_active
          AND (:country IS NULL OR country_code = :country)
          AND norm_text(name_sr) % :normalized
        ORDER BY score DESC, popularity DESC
        LIMIT 1
        """.trimIndent()
    )
        .param("normalized", normalized)
        .param("country", countryHint)
        .query { rs, _ ->
            val score = rs.getDouble("score")
            if (score >= SIMILARITY_THRESHOLD) {
                Resolution(rs.getLong("id"), rs.getString("country_code"), true)
            } else {
                null
            }
        }
        .optional()
        .orElse(null)

    private fun rememberAlias(
        destinationId: Long?,
        sourceId: Long?,
        rawName: String,
        normalized: String,
        status: String,
    ) {
        jdbc.sql(
            """
            INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
            VALUES (:destinationId, :sourceId, :rawName, :normalized, :status)
            ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING
            """.trimIndent()
        )
            .param("destinationId", destinationId)
            .param("sourceId", sourceId)
            .param("rawName", rawName)
            .param("normalized", normalized)
            .param("status", status)
            .update()
    }

    /** Mesta polaska u Srbiji — koristi ih i ingest i autocomplete na frontendu. */
    fun resolveDepartureHub(rawName: String?): Long? {
        if (rawName.isNullOrBlank()) return null
        val normalized = Text.normalize(rawName)
        return jdbc.sql(
            """
            SELECT id FROM destination
            WHERE is_departure_hub AND norm_text(name_sr) = :normalized
            LIMIT 1
            """.trimIndent()
        )
            .param("normalized", normalized)
            .query(Long::class.java)
            .optional()
            .orElse(null)
    }
}
