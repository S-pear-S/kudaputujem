package rs.kudaputujem.api.config

import io.swagger.v3.oas.models.OpenAPI
import io.swagger.v3.oas.models.info.Info
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class OpenApiConfig {

    @Bean
    fun openApi(): OpenAPI = OpenAPI().info(
        Info()
            .title("Kuda putujem API")
            .version("0.1.0")
            .description(
                "Metapretrazivac ponuda srpskih turistickih agencija. " +
                    "/api/** je javno, /internal/** koriste skreperi, /admin/** je administracija."
            )
    )
}
