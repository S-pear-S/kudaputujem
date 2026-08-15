package rs.kudaputujem.api.config

import jakarta.validation.constraints.NotBlank
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.validation.annotation.Validated

/**
 * Sva podesavanja na jednom mestu, validirana pri pokretanju.
 *
 * Namerno nema `@Value` razbacanog po klasama — kad server padne zbog fale konfiguracije,
 * treba da padne odmah pri pokretanju sa jasnom porukom, ne na prvom zahtevu.
 */
@Validated
@ConfigurationProperties(prefix = "kudaputujem")
data class ApiProperties(
    val security: Security = Security(),
    val search: Search = Search(),
    val ingest: Ingest = Ingest(),
    val lead: Lead = Lead(),
    val cors: Cors = Cors(),
) {
    data class Security(
        /** Kljuc kojim se skreperi autentikuju ka /internal/**. */
        @field:NotBlank val ingestApiKey: String = "dev-ingest-key",
        /** Kljuc za /admin/**. Namerno odvojen: skreper koji procuri ne sme da brise agencije. */
        @field:NotBlank val adminApiKey: String = "dev-admin-key",
        /** So za hesiranje IP adrese u lead tabeli. Menja se u produkciji. */
        @field:NotBlank val ipHashSalt: String = "dev-salt",
    )

    data class Search(
        val defaultPageSize: Int = 20,
        val maxPageSize: Int = 100,
        /** Koliko dugo kesiramo rezultat pretrage. Cene se menjaju retko, upiti se ponavljaju. */
        val cacheTtlSeconds: Long = 300,
        /** Ponuda starija od ovoga se ne prikazuje — bolje nista nego zastarela cena. */
        val maxStalenessHours: Long = 96,
    )

    data class Ingest(
        /** Runda ispod ovog udela proseka poslednjih rundi se odbija kao SUSPECT. */
        val suspectRatio: Double = 0.5,
        /** Koliko prethodnih rundi ulazi u prosek. */
        val historyWindow: Int = 5,
        val maxOffersPerBatch: Int = 500,
    )

    data class Lead(
        val maxPerHourPerIp: Int = 5,
        val maxPerHourPerEmail: Int = 3,
        /** Rok cuvanja licnih podataka, u danima. */
        val retentionDays: Long = 365,
        val consentTextVersion: String = "2026-08-01",
    )

    data class Cors(
        val allowedOrigins: List<String> = listOf("http://localhost:3000"),
    )
}
