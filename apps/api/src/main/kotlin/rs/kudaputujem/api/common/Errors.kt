package rs.kudaputujem.api.common

import jakarta.servlet.http.HttpServletRequest
import java.time.Instant
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice

/**
 * Tipizovane greske. Poruka je na srpskom jer je vidi krajnji korisnik,
 * `code` je na engleskom jer ga cita frontend i logovi.
 */
sealed class ApiException(
    val status: HttpStatus,
    val code: String,
    message: String,
) : RuntimeException(message)

class NotFoundException(what: String, code: String = "not_found") :
    ApiException(HttpStatus.NOT_FOUND, code, "$what nije pronađeno")

class BadRequestException(message: String, code: String = "bad_request") :
    ApiException(HttpStatus.BAD_REQUEST, code, message)

class ConflictException(message: String, code: String = "conflict") :
    ApiException(HttpStatus.CONFLICT, code, message)

class RateLimitException(message: String = "Previše zahteva. Pokušajte kasnije.") :
    ApiException(HttpStatus.TOO_MANY_REQUESTS, "rate_limited", message)

data class ErrorResponse(
    val error: String,
    val code: String,
    val path: String,
    val timestamp: Instant = Instant.now(),
    val details: Map<String, String>? = null,
)

@RestControllerAdvice
class GlobalExceptionHandler {

    private val log = LoggerFactory.getLogger(GlobalExceptionHandler::class.java)

    @ExceptionHandler(ApiException::class)
    fun handleApi(ex: ApiException, request: HttpServletRequest): ResponseEntity<ErrorResponse> {
        // Ocekivane greske se ne loguju kao ERROR; inace alarmi postanu suma.
        log.debug("{} na {}: {}", ex.code, request.requestURI, ex.message)
        return ResponseEntity.status(ex.status).body(
            ErrorResponse(ex.message ?: "Greška", ex.code, request.requestURI)
        )
    }

    @ExceptionHandler(MethodArgumentNotValidException::class)
    fun handleValidation(
        ex: MethodArgumentNotValidException,
        request: HttpServletRequest,
    ): ResponseEntity<ErrorResponse> {
        val details = ex.bindingResult.fieldErrors.associate {
            it.field to (it.defaultMessage ?: "neispravna vrednost")
        }
        return ResponseEntity.badRequest().body(
            ErrorResponse("Neispravni podaci u zahtevu", "validation_failed", request.requestURI, details = details)
        )
    }

    @ExceptionHandler(IllegalArgumentException::class)
    fun handleIllegalArgument(
        ex: IllegalArgumentException,
        request: HttpServletRequest,
    ): ResponseEntity<ErrorResponse> =
        ResponseEntity.badRequest().body(
            ErrorResponse(ex.message ?: "Neispravan zahtev", "bad_request", request.requestURI)
        )

    @ExceptionHandler(Exception::class)
    fun handleUnexpected(ex: Exception, request: HttpServletRequest): ResponseEntity<ErrorResponse> {
        log.error("Neocekivana greska na {}", request.requestURI, ex)
        // Poruka izuzetka NIKAD ne ide korisniku — moze da sadrzi SQL, putanje, imena kolona.
        return ResponseEntity.internalServerError().body(
            ErrorResponse("Došlo je do greške na serveru", "internal_error", request.requestURI)
        )
    }
}
