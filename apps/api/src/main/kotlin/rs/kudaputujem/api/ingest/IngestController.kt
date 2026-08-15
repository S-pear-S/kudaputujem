package rs.kudaputujem.api.ingest

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import rs.kudaputujem.api.crawl.CrawlRunService

/**
 * Endpointi koje koriste skreperi. Zasticeni `X-Api-Key` zaglavljem (vidi ApiKeyFilter).
 *
 * Tok jedne runde:
 *   POST /internal/runs                    -> dobija runId i podesavanja izvora
 *   POST /internal/ingest/offers  (vise puta, u batch-evima)
 *   POST /internal/runs/{id}/finish        -> deaktivira sto nije vidjeno, proverava SUSPECT
 */
@RestController
@RequestMapping("/internal")
@Tag(name = "Ingest", description = "Interni API za skrepere")
class IngestController(
    private val ingestService: IngestService,
    private val crawlRuns: CrawlRunService,
) {

    @PostMapping("/runs")
    @Operation(summary = "Pokreće rundu i vraća podešavanja izvora")
    fun startRun(@Valid @RequestBody request: StartRunRequest): StartRunResponse =
        crawlRuns.start(request)

    @PostMapping("/ingest/offers")
    @Operation(summary = "Prima batch normalizovanih ponuda")
    fun ingestOffers(@Valid @RequestBody batch: IngestBatch): IngestResult =
        ingestService.ingest(batch)

    @PostMapping("/runs/{runId}/finish")
    @Operation(summary = "Zatvara rundu i deaktivira ponude koje nisu viđene")
    fun finishRun(
        @PathVariable runId: Long,
        @RequestBody request: FinishRunRequest,
    ): FinishRunResponse = crawlRuns.finish(runId, request)
}
