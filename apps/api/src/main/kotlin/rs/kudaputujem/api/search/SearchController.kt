package rs.kudaputujem.api.search

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.Parameter
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.validation.annotation.Validated
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.ModelAttribute
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import rs.kudaputujem.api.common.PageResponse

@Tag(name = "Pretraga", description = "Pretraga ponuda svih agencija")
@Validated
@RestController
@RequestMapping("/api")
class SearchController(private val service: SearchService) {

    @Operation(
        summary = "Pretraga ponuda",
        description = "Filtrira ponude iz departure_price_index i vraca stranicu OfferCard objekata." +
            " Za grupe sa decom, tacna cena se racuna OccupancySolverom za svaku ponudu na strani."
    )
    @GetMapping("/search")
    fun search(
        @Parameter(description = "Parametri pretrage")
        @Valid @ModelAttribute req: SearchRequest,
    ): ResponseEntity<PageResponse<OfferCard>> =
        ResponseEntity.ok(service.search(req))
}
