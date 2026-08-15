"""Ugovor između skrepera i API-ja.

Ovo je JEDINA stvar koju obe strane moraju da razumeju. Skreper ne zna za bazu,
API ne zna za HTML. Svaka promena ovde je promena ugovora i mora da ide zajedno
sa promenom u `rs.kudaputujem.api.ingest.dto`.

Tri nivoa:
    RawOffer   — šta je adapter pokupio, sve stringovi, ništa nije garantovano
    OfferIn    — validirano i normalizovano, ovo ide preko HTTP-a
    (baza)     — kanonski oblik, brine API
"""

from __future__ import annotations

import hashlib
import json
from datetime import date
from decimal import Decimal
from typing import Any

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

from .enums import (
    AccommodationKind,
    BoardType,
    Payable,
    PriceSlot,
    PricingBasis,
    ProductKind,
    SurchargeCode,
    SurchargeKind,
    SurchargeUnit,
    TransportType,
)

# ---------------------------------------------------------------------------
# Sirovi sloj
# ---------------------------------------------------------------------------


class RawOffer(BaseModel):
    """Sirov izlaz adaptera. Namerno bez validacije — hvatamo šta ima na sajtu."""

    model_config = ConfigDict(extra="allow")

    external_id: str
    url: str
    title: str | None = None
    raw: dict[str, Any] = Field(default_factory=dict)
    source_url: str | None = None


# ---------------------------------------------------------------------------
# Normalizovani sloj
# ---------------------------------------------------------------------------


class PriceIn(BaseModel):
    """Jedna cena za jednu kombinaciju sobe i slota.

    Primeri:
        1/2 po osobi 349 EUR
            room_code="1/2", capacity_adults=2, slot=ADULT,
            basis=PER_PERSON_PER_STAY, amount=349
        dete 2-11 na pomoćnom ležaju 199 EUR
            room_code="1/2+1", capacity_adults=2, capacity_extra=1, slot=CHILD,
            child_age_from=2, child_age_to=11, amount=199
        apartman za 4 osobe 60 EUR/dan
            room_code="A2/4", capacity_total=4, slot=UNIT,
            basis=PER_UNIT_PER_NIGHT, amount=60
    """

    room_code: str
    room_name: str | None = None
    capacity_adults: int = 2
    capacity_extra: int = 0
    capacity_total: int | None = None

    slot: PriceSlot = PriceSlot.ADULT
    pricing_basis: PricingBasis = PricingBasis.PER_PERSON_PER_STAY
    board_type: BoardType | None = None

    child_age_from: int | None = None
    child_age_to: int | None = None

    amount: Decimal
    currency: str = "EUR"
    original_amount: Decimal | None = None
    discount_label: str | None = None
    is_promo: bool = False

    min_stay_nights: int | None = None
    notes: str | None = None

    @field_validator("currency")
    @classmethod
    def _currency_upper(cls, v: str) -> str:
        v = v.strip().upper()
        if len(v) != 3:
            raise ValueError(f"valuta mora biti ISO 4217 kod od 3 slova, dobijeno {v!r}")
        return v

    @field_validator("amount", "original_amount")
    @classmethod
    def _non_negative(cls, v: Decimal | None) -> Decimal | None:
        if v is not None and v < 0:
            raise ValueError("cena ne može biti negativna")
        return v

    @model_validator(mode="after")
    def _fill_capacity_total(self) -> PriceIn:
        if self.capacity_total is None:
            self.capacity_total = self.capacity_adults + self.capacity_extra
        if self.slot is PriceSlot.CHILD and self.child_age_to is None:
            # Ako agencija ne kaže do koliko godina, uzimamo standard za srpsko tržište.
            self.child_age_to = 11
        return self


class SurchargeIn(BaseModel):
    """Doplata koja NIJE u istaknutoj ceni. Bez ovoga poređenje cena laže."""

    code: SurchargeCode = SurchargeCode.OTHER
    name: str
    kind: SurchargeKind = SurchargeKind.MANDATORY
    unit: SurchargeUnit = SurchargeUnit.PER_PERSON
    amount: Decimal | None = None
    currency: str | None = None
    payable: Payable = Payable.IN_ADVANCE
    raw_text: str | None = None


class TransportLegIn(BaseModel):
    leg_index: int = 0
    direction: str = "OUTBOUND"          # OUTBOUND / RETURN
    mode: TransportType
    carrier_name: str | None = None
    carrier_code: str | None = None
    vehicle_number: str | None = None
    from_place_raw: str
    from_terminal: str | None = None
    to_place_raw: str
    to_terminal: str | None = None
    depart_at: str | None = None         # ISO 8601 ako postoji pun datum i vreme
    arrive_at: str | None = None
    depart_local: str | None = None      # "07:30" kad sajt daje samo vreme
    arrive_local: str | None = None
    duration_minutes: int | None = None
    stops: int = 0


class DepartureIn(BaseModel):
    external_id: str | None = None
    start_date: date
    end_date: date
    nights: int | None = None
    days: int | None = None
    transport_type: TransportType = TransportType.NONE
    departure_place_raw: str | None = None
    board_type: BoardType | None = None
    is_available: bool = True
    seats_left: int | None = None
    is_last_minute: bool = False

    prices: list[PriceIn] = Field(default_factory=list)
    surcharges: list[SurchargeIn] = Field(default_factory=list)
    legs: list[TransportLegIn] = Field(default_factory=list)

    @model_validator(mode="after")
    def _check_dates(self) -> DepartureIn:
        if self.end_date < self.start_date:
            raise ValueError(f"end_date {self.end_date} pre start_date {self.start_date}")
        if self.nights is None:
            self.nights = (self.end_date - self.start_date).days
        if self.days is None:
            self.days = self.nights + 1
        if self.nights > 60:
            raise ValueError(f"sumnjivo dug termin: {self.nights} noći")
        return self


class AccommodationIn(BaseModel):
    name: str
    kind: AccommodationKind = AccommodationKind.HOTEL
    stars: float | None = None
    destination_raw: str | None = None
    address: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    distance_to_beach_m: int | None = None
    description: str | None = None
    amenities: list[str] = Field(default_factory=list)
    images: list[str] = Field(default_factory=list)
    external_id: str | None = None

    @field_validator("stars")
    @classmethod
    def _stars_range(cls, v: float | None) -> float | None:
        if v is not None and not (0 <= v <= 7):
            raise ValueError(f"nemoguć broj zvezdica: {v}")
        return v


class OfferIn(BaseModel):
    """Kanonska ponuda spremna za ingest."""

    source_slug: str
    external_id: str
    product_kind: ProductKind
    title: str
    url: str

    country_raw: str | None = None
    destination_raw: str | None = None
    accommodation: AccommodationIn | None = None

    transport_type: TransportType = TransportType.NONE
    board_type: BoardType = BoardType.NONE

    description: str | None = None
    images: list[str] = Field(default_factory=list)
    highlights: list[str] = Field(default_factory=list)
    included: list[str] = Field(default_factory=list)
    not_included: list[str] = Field(default_factory=list)
    raw_attributes: dict[str, Any] = Field(default_factory=dict)

    currency: str = "EUR"
    departures: list[DepartureIn] = Field(default_factory=list)
    surcharges: list[SurchargeIn] = Field(default_factory=list)

    @field_validator("url")
    @classmethod
    def _absolute_url(cls, v: str) -> str:
        if not v.startswith(("http://", "https://")):
            raise ValueError(f"url mora biti apsolutan, dobijeno {v!r}")
        return v

    @field_validator("title")
    @classmethod
    def _title_not_empty(cls, v: str) -> str:
        v = " ".join(v.split())
        if len(v) < 2:
            raise ValueError("naslov je prazan")
        return v

    @model_validator(mode="after")
    def _sanity(self) -> OfferIn:
        if self.product_kind is ProductKind.PACKAGE and not self.departures:
            raise ValueError("aranžman bez ijednog termina")
        if self.product_kind is ProductKind.PACKAGE and self.accommodation is None:
            raise ValueError("aranžman bez smeštaja")
        return self

    def content_hash(self) -> str:
        """Stabilan hash sadržaja; API po njemu zna da li se ponuda promenila.

        Namerno preskače polja koja se menjaju bez promene suštine (nema ih ovde),
        i koristi sortirane ključeve da JSON redosled ne pravi lažne promene.
        """
        payload = self.model_dump(mode="json", exclude_none=True)
        blob = json.dumps(payload, sort_keys=True, ensure_ascii=False, separators=(",", ":"))
        return hashlib.sha256(blob.encode("utf-8")).hexdigest()

    # -- dijagnostika, koristi je `--dry-run` i SUSPECT detekcija ---------------

    def completeness(self) -> dict[str, bool]:
        acc = self.accommodation
        return {
            "ima_termine": bool(self.departures),
            "ima_cene": any(d.prices for d in self.departures),
            "ima_destinaciju": bool(self.destination_raw),
            "ima_smestaj": acc is not None,
            "ima_zvezdice": bool(acc and acc.stars),
            "ima_slike": bool(self.images or (acc and acc.images)),
            "ima_opis": bool(self.description),
            "ima_prevoz": self.transport_type is not TransportType.NONE,
            "ima_uslugu": self.board_type is not BoardType.NONE,
            "ima_doplate": bool(self.surcharges or any(d.surcharges for d in self.departures)),
        }

    def completeness_score(self) -> float:
        checks = self.completeness()
        return round(sum(checks.values()) / len(checks), 3)


# ---------------------------------------------------------------------------
# Ingest omotači
# ---------------------------------------------------------------------------


class IngestBatch(BaseModel):
    run_id: int
    source_slug: str
    offers: list[OfferIn]
    dry_run: bool = False


class IngestResult(BaseModel):
    received: int = 0
    created: int = 0
    updated: int = 0
    unchanged: int = 0
    failed: int = 0
    errors: list[str] = Field(default_factory=list)


class RunSummary(BaseModel):
    run_id: int
    source_slug: str
    status: str
    pages_fetched: int = 0
    items_found: int = 0
    items_created: int = 0
    items_updated: int = 0
    items_failed: int = 0
    items_expired: int = 0
    duration_seconds: float = 0.0
    avg_completeness: float = 0.0
    error_message: str | None = None
