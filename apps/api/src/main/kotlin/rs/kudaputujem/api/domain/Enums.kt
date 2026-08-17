package rs.kudaputujem.api.domain

/**
 * Kanonske šifre.
 *
 * Ove vrednosti moraju da se poklapaju sa:
 *   - `apps/scrapers/src/travelscrape/core/enums.py`
 *   - CHECK ograničenjima u Flyway migracijama
 *
 * Zato su sve vrednosti stringovi i zato ovde stoji `fromDb`, koji na nepoznatoj
 * vrednosti vraća fallback umesto da baci izuzetak — jedan neočekivan red iz baze
 * ne sme da obori celu pretragu.
 */

enum class ProductKind {
    /** Aranžman: smeštaj + prevoz (ili smeštaj sa opcijom sopstvenog prevoza). */
    PACKAGE,

    /** Samo prevoz: autobuska ili avio karta, transfer. */
    TRANSPORT,

    /** Samo smeštaj, bez prevoza. */
    ACCOMMODATION;

    companion object {
        fun fromDb(value: String?): ProductKind =
            entries.firstOrNull { it.name == value } ?: PACKAGE
    }
}

enum class TransportType {
    BUS, PLANE, TRAIN, FERRY, MINIVAN,

    /** Sopstveni prevoz. */
    OWN,

    NONE;

    companion object {
        fun fromDb(value: String?): TransportType =
            entries.firstOrNull { it.name == value } ?: NONE
    }
}

/** Usluga ishrane. Srpske skraćenice: ND=BB, PP=HB, PU=FB, NA/SO=RO. */
enum class BoardType(val labelSr: String, val rank: Int) {
    RO("Najam (bez ishrane)", 1),
    BB("Noćenje s doručkom", 2),
    HB("Polupansion", 3),
    FB("Pun pansion", 4),
    AI("All inclusive", 5),
    UAI("Ultra all inclusive", 6),
    NONE("Nije navedeno", 0);

    companion object {
        fun fromDb(value: String?): BoardType =
            entries.firstOrNull { it.name == value } ?: NONE
    }
}

enum class PricingBasis(val perNight: Boolean, val perUnit: Boolean) {
    PER_PERSON_PER_STAY(false, false),
    PER_PERSON_PER_NIGHT(true, false),
    PER_UNIT_PER_STAY(false, true),
    PER_UNIT_PER_NIGHT(true, true);

    companion object {
        fun fromDb(value: String?): PricingBasis =
            entries.firstOrNull { it.name == value } ?: PER_PERSON_PER_STAY
    }
}

/** Ko zauzima ležaj na koji se cena odnosi. */
enum class PriceSlot {
    ADULT,
    CHILD,
    INFANT,

    /** Pomoćni ležaj bez obzira na uzrast. */
    EXTRA_BED,

    /** Cela smeštajna jedinica (apartman, studio, vila). */
    UNIT,

    /** Doplata kad jedna osoba koristi dvokrevetnu sobu. */
    SINGLE_SUPPLEMENT;

    companion object {
        fun fromDb(value: String?): PriceSlot =
            entries.firstOrNull { it.name == value } ?: ADULT
    }
}

enum class SurchargeCode {
    /** Boravišna taksa. */
    TOURIST_TAX,
    INSURANCE,
    TRANSPORT,
    FUEL,
    LOCAL_FEE,
    RESERVATION_FEE,
    OTHER;

    companion object {
        fun fromDb(value: String?): SurchargeCode =
            entries.firstOrNull { it.name == value } ?: OTHER
    }
}

enum class SurchargeKind { MANDATORY, OPTIONAL }

enum class SurchargeUnit { PER_PERSON, PER_PERSON_PER_NIGHT, PER_UNIT, PER_UNIT_PER_NIGHT, PER_BOOKING }

enum class Payable { IN_ADVANCE, ON_SITE }

enum class AccommodationKind {
    HOTEL, APARTMENT, VILLA, HOSTEL, RESORT, ROOM, CAMP, OTHER;

    companion object {
        fun fromDb(value: String?): AccommodationKind =
            entries.firstOrNull { it.name == value } ?: HOTEL
    }
}

enum class DestinationKind { COUNTRY, REGION, CITY, RESORT, ISLAND }

enum class CrawlStatus {
    RUNNING,
    OK,

    /** Runda je vratila sumnjivo malo rezultata; podaci se NE upisuju. */
    SUSPECT,

    FAILED,
    CANCELLED
}

enum class SourceHealth { OK, DEGRADED, FAILING, DISABLED, UNKNOWN }

enum class LeadStatus { NEW, SENT, FAILED, CONTACTED, CLOSED, SPAM }

enum class AliasStatus { CONFIRMED, PENDING, REJECTED }

/**
 * Dozvoljena polja za sortiranje. Whitelist — `sort` parametar ne moze direktno u SQL.
 * Vrednosti moraju odgovarati aliasima kolona u SearchService CTE-u.
 */
enum class SortBy(val sqlExpression: String) {
    PRICE("total_rsd"),
    PRICE_PER_PERSON("per_person_rsd"),
    DATE("start_date"),
    NIGHTS("nights"),
    STARS("stars"),
    RATING("rating_avg"),
    UPDATED("last_seen_at");

    companion object {
        fun fromParam(value: String?): SortBy =
            entries.firstOrNull { it.name.equals(value, ignoreCase = true) } ?: PRICE
    }
}

enum class SortDirection {
    ASC, DESC;

    companion object {
        fun fromParam(value: String?): SortDirection =
            entries.firstOrNull { it.name.equals(value, ignoreCase = true) } ?: ASC
    }
}
