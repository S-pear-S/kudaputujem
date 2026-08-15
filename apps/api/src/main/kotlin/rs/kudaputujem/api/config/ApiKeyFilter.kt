package rs.kudaputujem.api.config

import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import java.security.MessageDigest
import org.slf4j.LoggerFactory
import org.springframework.boot.web.servlet.FilterRegistrationBean
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.MediaType
import org.springframework.web.filter.OncePerRequestFilter

/**
 * Zastita /internal/ i /admin/ API kljucem iz zaglavlja X-Api-Key.
 *
 * Namerno nije Spring Security: jedini zahtev je "dva staticka kljuca, dve zone".
 * Spring Security bi ovde doneo pet klasa konfiguracije da bi radio isto.
 * Kad dodamo korisnicke naloge, prelazimo na Spring Security i ovaj filter nestaje.
 *
 * Poredjenje kljuceva ide preko MessageDigest.isEqual, sto je konstantno u vremenu.
 * Obicno poredjenje stringa curi informaciju o tome koliko se prvih karaktera poklapa.
 */
@Configuration
class ApiKeyFilterConfig {

    @Bean
    fun ingestApiKeyFilter(properties: ApiProperties): FilterRegistrationBean<ApiKeyFilter> =
        FilterRegistrationBean(ApiKeyFilter(properties.security.ingestApiKey, "ingest")).apply {
            addUrlPatterns("/internal/*")
            order = 1
        }

    @Bean
    fun adminApiKeyFilter(properties: ApiProperties): FilterRegistrationBean<ApiKeyFilter> =
        FilterRegistrationBean(ApiKeyFilter(properties.security.adminApiKey, "admin")).apply {
            addUrlPatterns("/admin/*")
            order = 2
        }
}

class ApiKeyFilter(
    private val expectedKey: String,
    private val zone: String,
) : OncePerRequestFilter() {

    private val log = LoggerFactory.getLogger(ApiKeyFilter::class.java)
    private val expectedBytes = expectedKey.toByteArray()

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain,
    ) {
        val provided = request.getHeader("X-Api-Key")

        if (provided == null || !MessageDigest.isEqual(provided.toByteArray(), expectedBytes)) {
            // Ne logujemo kljuc, ni deo kljuca. Samo cinjenicu i izvor.
            log.warn("Odbijen pristup zoni {} sa {} za {}", zone, request.remoteAddr, request.requestURI)
            response.status = HttpServletResponse.SC_UNAUTHORIZED
            response.contentType = MediaType.APPLICATION_JSON_VALUE
            response.characterEncoding = "UTF-8"
            response.writer.write(
                """{"error":"Neispravan ili nedostajuci X-Api-Key","zone":"$zone"}"""
            )
            return
        }

        filterChain.doFilter(request, response)
    }
}
