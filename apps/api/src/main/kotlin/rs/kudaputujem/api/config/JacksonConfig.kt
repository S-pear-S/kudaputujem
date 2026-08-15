package rs.kudaputujem.api.config

import com.fasterxml.jackson.databind.SerializationFeature
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule
import com.fasterxml.jackson.module.kotlin.KotlinModule
import org.springframework.boot.autoconfigure.jackson.Jackson2ObjectMapperBuilderCustomizer
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class JacksonConfig {

    @Bean
    fun jacksonCustomizer(): Jackson2ObjectMapperBuilderCustomizer =
        Jackson2ObjectMapperBuilderCustomizer { builder ->
            builder.modules(KotlinModule.Builder().build(), JavaTimeModule())
            // Datumi kao ISO 8601 stringovi, ne kao timestamp brojevi.
            builder.featuresToDisable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)
            // BigDecimal kao string bi bio sigurniji, ali frontend racuna sa brojevima;
            // zato svuda drzimo scale 2 i ne oslanjamo se na float u JS-u za novac.
            builder.serializationInclusion(com.fasterxml.jackson.annotation.JsonInclude.Include.NON_NULL)
        }
}
