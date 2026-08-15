package rs.kudaputujem.api.pricing

import java.math.BigDecimal
import org.slf4j.LoggerFactory
import org.springframework.cache.annotation.Cacheable
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.stereotype.Service

/**
 * Kurs za konverziju u RSD.
 *
 * RSD se koristi ISKLJUCIVO za sortiranje i filtriranje po ceni, da bi se ponuda u
 * evrima i ponuda u dinarima mogle porediti. Korisniku se UVEK prikazuje originalna
 * valuta agencije — prikazana konvertovana cena bi bila obecanje koje ne mozemo da odrzimo.
 *
 * Rezervne vrednosti postoje da pretraga ne stane ako sinhronizacija kursa zakaze.
 * Bolje sortirati po priblizno tacnom kursu nego vratiti praznu stranicu.
 */
@Service
class ExchangeRateService(private val jdbc: JdbcClient) {

    private val log = LoggerFactory.getLogger(ExchangeRateService::class.java)

    companion object {
        private val FALLBACK = mapOf(
            "RSD" to BigDecimal("1"),
            "EUR" to BigDecimal("117.20"),
            "USD" to BigDecimal("108.00"),
            "CHF" to BigDecimal("124.00"),
            "GBP" to BigDecimal("138.00"),
            "BAM" to BigDecimal("59.90"),
        )
    }

    @Cacheable("exchangeRates")
    fun toRsd(currency: String): BigDecimal {
        val code = currency.uppercase()
        if (code == "RSD") return BigDecimal.ONE

        val fromDb = jdbc.sql(
            """
            SELECT rate_rsd FROM exchange_rate
            WHERE currency = :currency
            ORDER BY rate_date DESC
            LIMIT 1
            """.trimIndent()
        )
            .param("currency", code)
            .query(BigDecimal::class.java)
            .optional()
            .orElse(null)

        if (fromDb != null) return fromDb

        val fallback = FALLBACK[code]
        if (fallback == null) {
            log.warn("Nepoznata valuta {}, koristim kurs 1:1 — proveri podatke izvora", code)
            return BigDecimal.ONE
        }
        log.warn("Nema kursa za {} u bazi, koristim rezervnu vrednost {}", code, fallback)
        return fallback
    }
}
