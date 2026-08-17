"""Testovi za soleazur adapter, nad fixture-om snimljenim sa pravog sajta.

Fixture: `tests/fixtures/soleazur/display_prices.html`, snimljen 16.08.2026.
kroz Chrome, iz DOM-a. Sve vrednosti u ovim testovima su doslovno sa sajta.

Testira se ono što ruši naivni parser:
  - `rowspan` na imenu objekta (redovi nastavka imaju ćeliju manje)
  - kolone sa jednim prevozom (bez `/`) uz kolone sa dva
  - `/`, prazna ćelija i `x€` kao odsustvo cene
  - puna cena niža od akcijske
"""

from __future__ import annotations

import pathlib
from datetime import date
from decimal import Decimal

import pytest

from travelscrape.adapters.soleazur import parse_price_page
from travelscrape.core.enums import (
    BoardType,
    PriceSlot,
    PricingBasis,
    ProductKind,
    TransportType,
)

FIXTURE = pathlib.Path(__file__).parent / "fixtures" / "soleazur" / "display_prices.html"


@pytest.fixture(scope="module")
def offers():
    return parse_price_page(FIXTURE.read_text(encoding="utf-8"))


def _find(offers, accommodation: str, transport: TransportType):
    for offer in offers:
        if offer.accommodation.name == accommodation and offer.transport_type is transport:
            return offer
    return None


# --------------------------------------------------------------- osnovno


def test_parsira_obe_destinacije(offers):
    destinations = {offer.destination_raw for offer in offers}
    assert destinations == {"Neos Marmaras", "Kefalonija"}


def test_godina_se_cita_iz_naslova(offers):
    assert all(dep.start_date.year == 2026 for offer in offers for dep in offer.departures)


def test_svaka_ponuda_je_aranzman_sa_smestajem(offers):
    assert all(offer.product_kind is ProductKind.PACKAGE for offer in offers)
    assert all(offer.accommodation is not None for offer in offers)


def test_usluga_je_najam(offers):
    # Stranica hotela: "smeštaj 10 noćenja (usluga najam)".
    assert all(offer.board_type is BoardType.RO for offer in offers)


def test_cena_je_po_osobi(offers):
    # Stranica hotela: "CENA ARANŽMANA PO OSOBI".
    prices = [p for o in offers for d in o.departures for p in d.prices]
    assert prices
    assert all(p.slot is PriceSlot.ADULT for p in prices)
    assert all(p.pricing_basis is PricingBasis.PER_PERSON_PER_STAY for p in prices)


# --------------------------------------------------------------- rowspan


def test_rowspan_ne_pomera_kolone(offers):
    """Ridos house ima rowspan=3; sobe iz redova nastavka moraju imati tačne cene."""
    offer = _find(offers, "Ridos house", TransportType.OWN)
    assert offer is not None

    # Mezoneta 1/4 je u DRUGOM redu, koji nema ćeliju objekta.
    # Njena cena za sopstveni prevoz u prvom terminu je 265€.
    departure = next(d for d in offer.departures if d.start_date == date(2026, 8, 28))
    price = next(p for p in departure.prices if p.room_code == "1/4")
    assert price.amount == Decimal("265")


def test_sve_tri_sobe_ridos_house_su_pokupljene(offers):
    codes = set()
    for transport in (TransportType.OWN, TransportType.BUS):
        offer = _find(offers, "Ridos house", transport)
        if offer:
            codes |= {p.room_code for d in offer.departures for p in d.prices}
    assert codes == {"1/3+1", "1/4", "1/4+1"}


def test_objekat_bez_rowspana_se_prepoznaje(offers):
    """Vila Aggelos ima jednu sobu, pa ćelija objekta nema rowspan atribut.

    Sve njene cene su `/` ili prazne, pa ponuda ne sme ni da nastane.
    """
    assert _find(offers, "Vila Aggelos", TransportType.OWN) is None
    assert _find(offers, "Vila Aggelos", TransportType.PLANE) is None


# --------------------------------------------------------------- cene i prevoz


def test_dva_prevoza_u_istoj_celiji(offers):
    """`209€ (235€) / 275€ (305€)` -> sopstveni 209, bus 275."""
    own = _find(offers, "Ridos house", TransportType.OWN)
    bus = _find(offers, "Ridos house", TransportType.BUS)
    assert own is not None and bus is not None

    def price_for(offer, start, code):
        departure = next(d for d in offer.departures if d.start_date == start)
        return next(p for p in departure.prices if p.room_code == code)

    own_price = price_for(own, date(2026, 9, 7), "1/3+1")
    bus_price = price_for(bus, date(2026, 9, 7), "1/3+1")

    assert own_price.amount == Decimal("209")
    assert own_price.original_amount == Decimal("235")
    assert bus_price.amount == Decimal("275")
    assert bus_price.original_amount == Decimal("305")


def test_nepoznata_puna_cena_ne_obara_akcijsku(offers):
    """`265€ (x€) / 335€` -> akcijska 265 bez pune cene."""
    own = _find(offers, "Ridos house", TransportType.OWN)
    departure = next(d for d in own.departures if d.start_date == date(2026, 8, 28))
    price = next(p for p in departure.prices if p.room_code == "1/4")

    assert price.amount == Decimal("265")
    assert price.original_amount is None
    assert price.is_promo is False


def test_kolona_sa_jednim_prevozom(offers):
    """Kefalonija ima kolone samo za avio; ćelija tada nema `/`."""
    offer = _find(offers, "Andrew's studios", TransportType.PLANE)
    assert offer is not None
    departure = next(d for d in offer.departures if d.start_date == date(2026, 8, 25))
    price = next(p for p in departure.prices if p.room_code == "1/2")
    assert price.amount == Decimal("675")
    assert departure.nights == 11  # "12 dana/11 noci"


def test_razlicito_trajanje_po_koloni(offers):
    offer = _find(offers, "Andrew's studios", TransportType.OWN)
    departure = next(d for d in offer.departures if d.start_date == date(2026, 8, 22))
    assert departure.nights == 10
    assert departure.end_date == date(2026, 9, 1)


def test_kosa_crta_ne_pravi_cenu(offers):
    """Prvi termin za Ridos house 1/3+1 je `/` — ta soba ne sme biti u tom terminu."""
    own = _find(offers, "Ridos house", TransportType.OWN)
    departure = next(d for d in own.departures if d.start_date == date(2026, 8, 28))
    assert all(p.room_code != "1/3+1" for p in departure.prices)


def test_x_evra_se_preskace(offers):
    """`x€ (x€)` za Andrew's studios 1/3 u trećoj koloni ne sme dati termin."""
    offer = _find(offers, "Andrew's studios", TransportType.PLANE)
    dates = {d.start_date for d in offer.departures}
    assert date(2026, 8, 29) not in dates


def test_puna_cena_niza_od_akcijske_nije_popust(offers):
    """`619€ (585€)` je greška u podacima na sajtu; ne sme se označiti kao promo."""
    offer = _find(offers, "Vila Zaharula, Lassi", TransportType.PLANE)
    assert offer is not None
    departure = next(d for d in offer.departures if d.start_date == date(2026, 8, 25))
    price = next(p for p in departure.prices if p.room_code == "1/3")

    assert price.amount == Decimal("619")
    assert price.original_amount == Decimal("585")
    assert price.is_promo is False


# --------------------------------------------------------------- identitet


def test_jedan_offer_po_prevozu(offers):
    ids = {o.external_id for o in offers if o.accommodation.name == "Ridos house"}
    assert ids == {"neos-marmaras-ridos-house__own", "neos-marmaras-ridos-house__bus"}


def test_nema_dva_termina_sa_istim_datumima_u_istoj_ponudi(offers):
    """Baza ima UNIQUE (offer_id, start_date, end_date, departure_place_raw)."""
    for offer in offers:
        keys = [(d.start_date, d.end_date, d.departure_place_raw) for d in offer.departures]
        assert len(keys) == len(set(keys)), f"duplirani termin u {offer.external_id}"


def test_external_id_je_stabilan():
    """Dva parsiranja istog HTML-a daju iste identifikatore."""
    html = FIXTURE.read_text(encoding="utf-8")
    first = {o.external_id for o in parse_price_page(html)}
    second = {o.external_id for o in parse_price_page(html)}
    assert first == second


def test_oznake_soba_prolaze_kroz_normalizator(offers):
    codes = {p.room_code for o in offers for d in o.departures for p in d.prices}
    assert codes <= {"1/2", "1/3", "1/3+1", "1/4", "1/4+1"}
