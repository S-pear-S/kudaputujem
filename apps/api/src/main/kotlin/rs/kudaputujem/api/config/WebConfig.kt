package rs.kudaputujem.api.config

import org.springframework.context.annotation.Configuration
import org.springframework.web.servlet.config.annotation.CorsRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer

@Configuration
class WebConfig(private val properties: ApiProperties) : WebMvcConfigurer {

    override fun addCorsMappings(registry: CorsRegistry) {
        registry.addMapping("/api/**")
            .allowedOrigins(*properties.cors.allowedOrigins.toTypedArray())
            .allowedMethods("GET", "POST", "OPTIONS")
            .allowedHeaders("Content-Type", "Accept")
            .maxAge(3600)
        // /internal i /admin namerno NEMAJU CORS — zovu se sa servera, ne iz browsera.
    }
}
