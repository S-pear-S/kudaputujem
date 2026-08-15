package rs.kudaputujem.api.ingest

import org.slf4j.LoggerFactory
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.stereotype.Service
import rs.kudaputujem.api.common.BadRequestException
import rs.kudaputujem.api.config.ApiProperties
import rs.kudaputujem.api.crawl.CrawlRunService
import rs.kudaputujem.api.domain.BoardType
import rs.kudaputujem.api.domain.TransportType
import rs.kudaputujem.api.pricing.PriceIndexBuilder

/**
 * Prima batch ponuda od skrepera.
 *
 * Jedna losa ponuda ne obara ceo batch — greska se broji i vraca u odgovoru sa
 * `externalId`-jem, da skreper moze tacno da kaze koja stranica je problem.
 * Batch koji bi pao ceo znaci da adapter ne moze da napreduje dok se ne popravi
 * jedan hotel sa cudnim HTML-om, a to je pogresna razmena.
 */
@Service
class IngestService(
    private val jdbc: JdbcClient,
    private val writer: OfferWriter,
    private val crawlRuns: CrawlRunService,
    private val priceIndex: PriceIndexBuilder,
    private val properties: ApiProperties,
) {

    private val log = LoggerFactory.getLogger(IngestService::class.java)

    fun ingest(batch: IngestBatch): IngestResult {
        if (batch.offers.size > properties.ingest.maxOffersPerBatch) {
            throw BadRequestException(
                "Batch ima ${batch.offers.size} ponuda, maksimum je ${properties.ingest.maxOffersPerBatch}",
                "batch_too_large",
            )
        }

        val source = crawlRuns.findSource(batch.sourceSlug)
        val errors = mutableListOf<String>()
        var created = 0
        var updated = 0
        var unchanged = 0
        var failed = 0
        var completenessSum = 0.0
        val touchedOfferIds = mutableListOf<Long>()

        for (offer in batch.offers) {
            completenessSum += completeness(offer)
            if (batch.dryRun) continue

            try {
                val result = writer.write(offer, source.id, source.agencyId)
                touchedOfferIds += result.offerId
                when (result.outcome) {
                    OfferWriter.Outcome.CREATED -> created++
                    OfferWriter.Outcome.UPDATED -> updated++
                    OfferWriter.Outcome.UNCHANGED -> unchanged++
                }
            } catch (ex: IllegalArgumentException) {
                failed++
                errors += "${offer.externalId}: ${ex.message}"
                log.warn("Odbijena ponuda {} sa izvora {}: {}", offer.externalId, source.slug, ex.message)
            } catch (ex: org.springframework.dao.DataAccessException) {
                failed++
                errors += "${offer.externalId}: greška u bazi"
                log.error("Greska u bazi za ponudu {} sa izvora {}", offer.externalId, source.slug, ex)
            }
        }

        if (!batch.dryRun) {
            jdbc.sql(
                """
                UPDATE crawl_run SET
                    items_created = items_created + :created,
                    items_updated = items_updated + :updated,
                    items_failed = items_failed + :failed
                WHERE id = :runId
                """.trimIndent()
            )
                .param("runId", batch.runId)
                .param("created", created)
                .param("updated", updated)
                .param("failed", failed)
                .update()

            priceIndex.rebuildForOffers(touchedOfferIds)
        }

        return IngestResult(
            received = batch.offers.size,
            created = created,
            updated = updated,
            unchanged = unchanged,
            failed = failed,
            dryRun = batch.dryRun,
            errors = errors.take(50),
            avgCompleteness = if (batch.offers.isEmpty()) 0.0
            else (completenessSum / batch.offers.size * 1000).toInt() / 1000.0,
        )
    }

    /**
     * Koliko je ponuda popunjena. Nizak prosek u rundi znaci da adapter promasuje
     * selektore, iako formalno nista nije puklo — to je najcesci tihi kvar.
     */
    private fun completeness(offer: OfferIn): Double {
        val checks = listOf(
            offer.departures.isNotEmpty(),
            offer.departures.any { it.prices.isNotEmpty() },
            !offer.destinationRaw.isNullOrBlank(),
            offer.accommodation != null,
            offer.accommodation?.stars != null,
            offer.images.isNotEmpty() || offer.accommodation?.images?.isNotEmpty() == true,
            !offer.description.isNullOrBlank(),
            offer.transportType != TransportType.NONE,
            offer.boardType != BoardType.NONE,
            offer.surcharges.isNotEmpty() || offer.departures.any { it.surcharges.isNotEmpty() },
        )
        return checks.count { it }.toDouble() / checks.size
    }
}
