package rs.kudaputujem.api.accommodation

import org.slf4j.LoggerFactory
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import rs.kudaputujem.api.common.Text
import rs.kudaputujem.api.ingest.AccommodationIn

/**
 * Spaja isti hotel koji dolazi sa vise sajtova pod razlicitim imenom.
 *
 * "Hotel Porto Matina 3*", "PORTO MATINA HOTEL" i "porto matina" su isti objekat.
 * Kanonizacija skida zvezdice i reci hotel/vila/apartmani, pa se poredi ostatak.
 *
 * Prag je namerno visok i trazi se ISTA destinacija i slicna kategorija. Pogresno spojen
 * hotel je najgori bug u ovom domenu: korisnik vidi cenu jednog, a rezervise drugi objekat.
 */
@Service
class AccommodationResolver(private val jdbc: JdbcClient) {

    private val log = LoggerFactory.getLogger(AccommodationResolver::class.java)

    companion object {
        const val SIMILARITY_THRESHOLD = 0.90
        private val PREFIXES = setOf(
            "hotel", "hotels", "aparthotel", "apart", "vila", "villa", "apartmani",
            "apartments", "apartman", "studio", "studios", "resort", "hostel",
            "pansion", "kuca", "smestaj",
        )
        private val STARS_SUFFIX = Regex("""(\d)\s*\*\s*\+?\s*$|\*{1,5}\s*\+?\s*$""")
    }

    /** Ime svedeno na oblik po kome poredimo dva sajta. */
    fun canonicalName(name: String): String {
        val withoutStars = STARS_SUFFIX.replace(name, "").trim()
        val tokens = Text.normalize(withoutStars).split(" ").filter { it.isNotBlank() && it !in PREFIXES }
        return if (tokens.isEmpty()) Text.normalize(withoutStars) else tokens.joinToString(" ")
    }

    @Transactional
    fun resolveOrCreate(
        input: AccommodationIn,
        destinationId: Long?,
        sourceId: Long,
    ): Long? {
        val canonical = canonicalName(input.name)
        if (canonical.isBlank()) return null

        aliasHit(canonical, sourceId, input.externalId)?.let { return it }
        fuzzyHit(canonical, destinationId, input.stars)?.let { id ->
            rememberAlias(id, sourceId, input, canonical, "CONFIRMED")
            return id
        }

        val created = create(input, destinationId, canonical)
        rememberAlias(created, sourceId, input, canonical, "CONFIRMED")
        return created
    }

    private fun aliasHit(canonical: String, sourceId: Long, externalId: String?): Long? = jdbc.sql(
        """
        SELECT accommodation_id FROM accommodation_alias
        WHERE accommodation_id IS NOT NULL
          AND status = 'CONFIRMED'
          AND (normalized = :canonical OR (:externalId IS NOT NULL AND external_id = :externalId AND source_id = :sourceId))
        ORDER BY (source_id = :sourceId) DESC
        LIMIT 1
        """.trimIndent()
    )
        .param("canonical", canonical)
        .param("externalId", externalId)
        .param("sourceId", sourceId)
        .query(Long::class.java)
        .optional()
        .orElse(null)

    private fun fuzzyHit(canonical: String, destinationId: Long?, stars: Double?): Long? {
        if (destinationId == null) return null   // bez destinacije ne spajamo, previse rizicno
        return jdbc.sql(
            """
            SELECT id, similarity(norm_text(name), :canonical) AS score, stars
            FROM accommodation
            WHERE destination_id = :destinationId
              AND norm_text(name) % :canonical
            ORDER BY score DESC
            LIMIT 1
            """.trimIndent()
        )
            .param("canonical", canonical)
            .param("destinationId", destinationId)
            .query { rs, _ ->
                val score = rs.getDouble("score")
                val existingStars = rs.getObject("stars")?.let { (it as java.math.BigDecimal).toDouble() }
                val starsCompatible = stars == null || existingStars == null ||
                    kotlin.math.abs(stars - existingStars) <= 0.5
                if (score >= SIMILARITY_THRESHOLD && starsCompatible) rs.getLong("id") else null
            }
            .optional()
            .orElse(null)
    }

    private fun create(input: AccommodationIn, destinationId: Long?, canonical: String): Long {
        val slug = uniqueSlug(Text.slugify(input.name))
        return jdbc.sql(
            """
            INSERT INTO accommodation
                (destination_id, slug, name, kind, stars, address, latitude, longitude,
                 distance_to_beach_m, description, amenities, images)
            VALUES
                (:destinationId, :slug, :name, :kind, :stars, :address, :latitude, :longitude,
                 :distanceToBeach, :description, CAST(:amenities AS jsonb), CAST(:images AS jsonb))
            RETURNING id
            """.trimIndent()
        )
            .param("destinationId", destinationId)
            .param("slug", slug)
            .param("name", input.name.trim())
            .param("kind", input.kind.name)
            .param("stars", input.stars)
            .param("address", input.address)
            .param("latitude", input.latitude)
            .param("longitude", input.longitude)
            .param("distanceToBeach", input.distanceToBeachM)
            .param("description", input.description)
            .param("amenities", toJsonArray(input.amenities))
            .param("images", toJsonArray(input.images))
            .query(Long::class.java)
            .single()
            .also { log.debug("Nov smestaj '{}' -> id {} (kanonski '{}')", input.name, it, canonical) }
    }

    private fun uniqueSlug(base: String): String {
        var candidate = base.ifBlank { "smestaj" }
        var suffix = 2
        while (jdbc.sql("SELECT 1 FROM accommodation WHERE slug = :slug")
                .param("slug", candidate).query(Int::class.java).optional().isPresent
        ) {
            candidate = "$base-$suffix"
            suffix++
        }
        return candidate
    }

    private fun rememberAlias(
        accommodationId: Long,
        sourceId: Long,
        input: AccommodationIn,
        canonical: String,
        status: String,
    ) {
        jdbc.sql(
            """
            INSERT INTO accommodation_alias
                (accommodation_id, source_id, external_id, raw_name, normalized, status)
            VALUES (:accommodationId, :sourceId, :externalId, :rawName, :normalized, :status)
            ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING
            """.trimIndent()
        )
            .param("accommodationId", accommodationId)
            .param("sourceId", sourceId)
            .param("externalId", input.externalId)
            .param("rawName", input.name)
            .param("normalized", canonical)
            .param("status", status)
            .update()
    }

    private fun toJsonArray(values: List<String>): String =
        values.joinToString(prefix = "[", postfix = "]") { value ->
            "\"" + value.replace("\\", "\\\\").replace("\"", "\\\"") + "\""
        }
}
