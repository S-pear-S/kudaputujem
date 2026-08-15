package rs.kudaputujem.api.crawl

import com.fasterxml.jackson.databind.ObjectMapper
import java.time.Instant
import org.slf4j.LoggerFactory
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import rs.kudaputujem.api.common.NotFoundException
import rs.kudaputujem.api.config.ApiProperties
import rs.kudaputujem.api.domain.CrawlStatus
import rs.kudaputujem.api.domain.SourceHealth
import rs.kudaputujem.api.ingest.FinishRunRequest
import rs.kudaputujem.api.ingest.FinishRunResponse
import rs.kudaputujem.api.ingest.StartRunRequest
import rs.kudaputujem.api.ingest.StartRunResponse

/**
 * Zivotni ciklus jedne runde skrepovanja.
 *
 * ## Zasto postoji SUSPECT status
 *
 * Skreper koji baci gresku je lako primetiti. Skreper koji tiho vrati 40 umesto 3000 ponuda
 * je katastrofa, jer bi deaktivirao 2960 ispravnih ponuda i korisnik bi video praznu pretragu.
 * Zato se svaka runda poredi sa prosekom prethodnih; ako je znatno ispod, runda se oznaci
 * kao SUSPECT i **nista se ne deaktivira**. Podaci ostaju stari, ali tacni.
 */
@Service
class CrawlRunService(
    private val jdbc: JdbcClient,
    private val properties: ApiProperties,
    private val objectMapper: ObjectMapper,
) {

    private val log = LoggerFactory.getLogger(CrawlRunService::class.java)

    data class SourceRow(
        val id: Long,
        val agencyId: Long,
        val slug: String,
        val crawlDelayMs: Int,
        val maxConcurrency: Int,
        val requiresBrowser: Boolean,
        val expectedMinItems: Int,
        val robotsAllowed: Boolean,
        val isEnabled: Boolean,
        val config: Map<String, Any?>,
    )

    fun findSource(slug: String): SourceRow = jdbc.sql(
        """
        SELECT id, agency_id, slug, crawl_delay_ms, max_concurrency, requires_browser,
               expected_min_items, robots_allowed, is_enabled, config::text AS config_json
        FROM source WHERE slug = :slug
        """.trimIndent()
    )
        .param("slug", slug)
        .query { rs, _ ->
            @Suppress("UNCHECKED_CAST")
            SourceRow(
                id = rs.getLong("id"),
                agencyId = rs.getLong("agency_id"),
                slug = rs.getString("slug"),
                crawlDelayMs = rs.getInt("crawl_delay_ms"),
                maxConcurrency = rs.getInt("max_concurrency"),
                requiresBrowser = rs.getBoolean("requires_browser"),
                expectedMinItems = rs.getInt("expected_min_items"),
                robotsAllowed = rs.getBoolean("robots_allowed"),
                isEnabled = rs.getBoolean("is_enabled"),
                config = objectMapper.readValue(rs.getString("config_json"), Map::class.java)
                    as Map<String, Any?>,
            )
        }
        .optional()
        .orElseThrow { NotFoundException("Izvor '$slug'", "source_not_found") }

    @Transactional
    fun start(request: StartRunRequest): StartRunResponse {
        val source = findSource(request.sourceSlug)

        require(source.isEnabled) { "Izvor '${source.slug}' je isključen" }
        require(source.robotsAllowed) {
            "robots.txt izvora '${source.slug}' ne dozvoljava skrepovanje"
        }

        val runId = jdbc.sql(
            """
            INSERT INTO crawl_run (source_id, status, trigger_kind, scraper_version)
            VALUES (:sourceId, 'RUNNING', :triggerKind, :version)
            RETURNING id
            """.trimIndent()
        )
            .param("sourceId", source.id)
            .param("triggerKind", request.triggerKind)
            .param("version", request.scraperVersion)
            .query(Long::class.java)
            .single()

        jdbc.sql("UPDATE source SET last_run_at = now(), updated_at = now() WHERE id = :id")
            .param("id", source.id)
            .update()

        log.info("Runda {} pokrenuta za izvor {}", runId, source.slug)

        return StartRunResponse(
            runId = runId,
            sourceId = source.id,
            sourceSlug = source.slug,
            crawlDelayMs = source.crawlDelayMs,
            maxConcurrency = source.maxConcurrency,
            requiresBrowser = source.requiresBrowser,
            config = source.config,
        )
    }

    @Transactional
    fun finish(runId: Long, request: FinishRunRequest): FinishRunResponse {
        val run = jdbc.sql(
            "SELECT source_id, started_at, items_created, items_updated FROM crawl_run WHERE id = :id"
        )
            .param("id", runId)
            .query { rs, _ ->
                Triple(
                    rs.getLong("source_id"),
                    rs.getTimestamp("started_at").toInstant(),
                    rs.getInt("items_created") + rs.getInt("items_updated"),
                )
            }
            .optional()
            .orElseThrow { NotFoundException("Runda $runId", "run_not_found") }

        val (sourceId, startedAt, itemsWritten) = run
        val requestedStatus = runCatching { CrawlStatus.valueOf(request.status) }
            .getOrDefault(CrawlStatus.OK)

        val suspect = !request.force &&
            requestedStatus == CrawlStatus.OK &&
            isSuspiciouslyLow(sourceId, runId, itemsWritten)

        val finalStatus = when {
            requestedStatus != CrawlStatus.OK -> requestedStatus
            suspect -> CrawlStatus.SUSPECT
            else -> CrawlStatus.OK
        }

        val expired = if (finalStatus == CrawlStatus.OK) expireUnseen(sourceId, startedAt) else 0

        jdbc.sql(
            """
            UPDATE crawl_run SET
                status = :status, finished_at = now(), pages_fetched = :pages,
                items_found = :found, items_failed = :failed, items_expired = :expired,
                error_message = :error, stats = CAST(:stats AS jsonb)
            WHERE id = :id
            """.trimIndent()
        )
            .param("id", runId)
            .param("status", finalStatus.name)
            .param("pages", request.pagesFetched)
            .param("found", request.itemsFound)
            .param("failed", request.itemsFailed)
            .param("expired", expired)
            .param("error", request.errorMessage)
            .param("stats", objectMapper.writeValueAsString(request.stats))
            .update()

        updateSourceHealth(sourceId, finalStatus)

        val message = when (finalStatus) {
            CrawlStatus.OK -> "Runda uspešna. Deaktivirano $expired ponuda koje više nisu na sajtu."
            CrawlStatus.SUSPECT ->
                "Runda je vratila sumnjivo malo rezultata ($itemsWritten). " +
                    "Ništa nije deaktivirano. Proveri adapter, pa pokreni sa force=true ako je pad stvaran."
            else -> "Runda završena sa statusom $finalStatus."
        }

        log.info("Runda {} zavrsena: {} ({})", runId, finalStatus, message)
        return FinishRunResponse(runId, finalStatus.name, expired, message)
    }

    /** Poredi sa prosekom poslednjih rundi, ne sa nulom. */
    private fun isSuspiciouslyLow(sourceId: Long, runId: Long, itemsWritten: Int): Boolean {
        val expectedMin = jdbc.sql("SELECT expected_min_items FROM source WHERE id = :id")
            .param("id", sourceId)
            .query(Int::class.java)
            .optional()
            .orElse(1)

        if (itemsWritten < expectedMin) return true

        val average = jdbc.sql(
            """
            SELECT AVG(items_created + items_updated)
            FROM (
                SELECT items_created, items_updated FROM crawl_run
                WHERE source_id = :sourceId AND id <> :runId AND status = 'OK'
                ORDER BY started_at DESC LIMIT :window
            ) recent
            """.trimIndent()
        )
            .param("sourceId", sourceId)
            .param("runId", runId)
            .param("window", properties.ingest.historyWindow)
            .query(Double::class.java)
            .optional()
            .orElse(null) ?: return false   // prva runda nema sa cim da se poredi

        return itemsWritten < average * properties.ingest.suspectRatio
    }

    private fun expireUnseen(sourceId: Long, startedAt: Instant): Int = jdbc.sql(
        """
        UPDATE offer SET is_active = FALSE, updated_at = now()
        WHERE source_id = :sourceId AND is_active AND last_seen_at < :startedAt
        """.trimIndent()
    )
        .param("sourceId", sourceId)
        .param("startedAt", java.sql.Timestamp.from(startedAt))
        .update()

    private fun updateSourceHealth(sourceId: Long, status: CrawlStatus) {
        val health = when (status) {
            CrawlStatus.OK -> SourceHealth.OK
            CrawlStatus.SUSPECT -> SourceHealth.DEGRADED
            CrawlStatus.FAILED -> SourceHealth.FAILING
            else -> SourceHealth.UNKNOWN
        }
        jdbc.sql(
            """
            UPDATE source SET
                health_status = :health,
                last_success_at = CASE WHEN :isOk THEN now() ELSE last_success_at END,
                updated_at = now()
            WHERE id = :id
            """.trimIndent()
        )
            .param("id", sourceId)
            .param("health", health.name)
            .param("isOk", status == CrawlStatus.OK)
            .update()
    }
}
