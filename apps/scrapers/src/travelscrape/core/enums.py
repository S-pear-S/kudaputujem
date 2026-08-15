"""Kanonske šifre. Moraju da se poklapaju sa enumima u Kotlin API-ju.

Ako se ovde nešto doda, dodaje se i u `rs.kudaputujem.api.domain.enums` i u CHECK
ograničenja migracije. Zato su vrednosti stringovi, ne brojevi.
"""

from __future__ import annotations

from enum import StrEnum


class ProductKind(StrEnum):
    PACKAGE = "PACKAGE"            # aranžman: smeštaj + prevoz (ili smeštaj sa opcijom sopstvenog)
    TRANSPORT = "TRANSPORT"        # samo prevoz
    ACCOMMODATION = "ACCOMMODATION"  # samo smeštaj


class TransportType(StrEnum):
    BUS = "BUS"
    PLANE = "PLANE"
    TRAIN = "TRAIN"
    FERRY = "FERRY"
    MINIVAN = "MINIVAN"
    OWN = "OWN"                    # sopstveni prevoz
    NONE = "NONE"


class BoardType(StrEnum):
    RO = "RO"      # najam / bez ishrane / samo smeštaj
    BB = "BB"      # noćenje sa doručkom
    HB = "HB"      # polupansion
    FB = "FB"      # pun pansion
    AI = "AI"      # all inclusive
    UAI = "UAI"    # ultra all inclusive
    NONE = "NONE"


class PricingBasis(StrEnum):
    PER_PERSON_PER_STAY = "PER_PERSON_PER_STAY"
    PER_PERSON_PER_NIGHT = "PER_PERSON_PER_NIGHT"
    PER_UNIT_PER_STAY = "PER_UNIT_PER_STAY"
    PER_UNIT_PER_NIGHT = "PER_UNIT_PER_NIGHT"


class PriceSlot(StrEnum):
    ADULT = "ADULT"
    CHILD = "CHILD"
    INFANT = "INFANT"
    EXTRA_BED = "EXTRA_BED"
    UNIT = "UNIT"                        # cela jedinica (apartman, studio)
    SINGLE_SUPPLEMENT = "SINGLE_SUPPLEMENT"


class SurchargeCode(StrEnum):
    TOURIST_TAX = "TOURIST_TAX"          # boravišna taksa
    INSURANCE = "INSURANCE"              # putno osiguranje
    TRANSPORT = "TRANSPORT"              # doplata za prevoz
    FUEL = "FUEL"
    LOCAL_FEE = "LOCAL_FEE"              # taksa koja se plaća na licu mesta
    RESERVATION_FEE = "RESERVATION_FEE"
    OTHER = "OTHER"


class SurchargeKind(StrEnum):
    MANDATORY = "MANDATORY"
    OPTIONAL = "OPTIONAL"


class SurchargeUnit(StrEnum):
    PER_PERSON = "PER_PERSON"
    PER_PERSON_PER_NIGHT = "PER_PERSON_PER_NIGHT"
    PER_UNIT = "PER_UNIT"
    PER_BOOKING = "PER_BOOKING"


class Payable(StrEnum):
    IN_ADVANCE = "IN_ADVANCE"
    ON_SITE = "ON_SITE"


class AccommodationKind(StrEnum):
    HOTEL = "HOTEL"
    APARTMENT = "APARTMENT"
    VILLA = "VILLA"
    HOSTEL = "HOSTEL"
    RESORT = "RESORT"
    ROOM = "ROOM"
    CAMP = "CAMP"
    OTHER = "OTHER"


class CrawlStatus(StrEnum):
    RUNNING = "RUNNING"
    OK = "OK"
    SUSPECT = "SUSPECT"      # sumnjivo malo rezultata; ingest se odbija
    FAILED = "FAILED"
    CANCELLED = "CANCELLED"
