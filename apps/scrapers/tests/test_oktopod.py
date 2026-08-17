"""Testovi za oktopod adapter, nad fixture-om snimljenim sa pravog sajta.

Fixture: `tests/fixtures/oktopod/putovanje_vila_penny.html`, snimljen 16.08.2026.
kroz Chrome, iz DOM-a. Sve vrednosti u ovim testovima su doslovno sa sajta
(fixture je skraćen na 5 od 13/19 perioda po tabeli, struktura je netaknuta).

Testira se ono što ruši naivni parser:
  - dve `CSSTableGenerator` tabele su dve DUŽINE boravka, ne dva prevoza
  - `Broj plativih osoba` je merodavan za kapacitet, ne izvedeni iz oznake sobe
  - `1/2 STD` i `1/2 STD RENOV*` dele razlomak ali NISU ista soba
  - `*` iza cene je uslovan period; `*` u imenu sobe nije deo cene
  - `-` u koloni pomoćnih ležaja znači nula
  - datumi bez crtice ("20.05. 30.05.")
"""

from __future__ import annotations

import pathlib
from datetime import date
from decimal import Decimal

import pytest

from travelscrape.adapters.oktopod import _extract_ac_surcharge as extract_ac_surcharge
from travelscrape.adapters.oktopod import detail_urls_from_sitemap, parse_hotel_page
from travelscrape.core.enums import (
    BoardType,
    Payable,
    PriceSlot,
    PricingBasis,
    ProductKind,
    SurchargeUnit,
    TransportType,
)

FIXTURE = pathlib.Path(__file__).parent / "fixtures" / "oktopod" / "putovanje_vila_penny.html"
URL = "https://www.oktopod.rs/sr/putovanje/vila-penny-hanioti/8339"
REFERENCE = date(2026, 8, 16)


@pytest.fixture(scope="module")
def offers():
    return parse_hotel_page(FIXTURE.read_text(encoding="utf-8"), URL, reference=REFERENCE)


def _prices_for(offer, code: str):
    return [p for d in offer.departures for p in d.prices if p.room_code == code]


# --------------------------------------------------------------- osnovno


def test_jedna_ponuda_za_ceo_objekat(offers):
    assert len(offers) == 1
    assert offers[0].accommodation.name == "VILA PENNY"
    assert offers[0].destination_raw == "HANIOTI"


def test_svaka_ponuda_je_aranzman_sa_smestajem(offers):
    assert all(o.product_kind is ProductKind.PACKAGE for o in offers)
    assert all(o.accommodation is not None for o in offers)


def test_usluga_je_najam(offers):
    assert all(o.board_type is BoardType.RO for o in offers)
    assert all(d.board_type is BoardType.RO for o in offers for d in o.departures)


def test_cena_je_po_osobi(offers):
    prices = [p for o in offers for d in o.departures for p in d.prices]
    assert prices
    assert all(p.slot is PriceSlot.ADULT for p in prices)
    assert all(p.pricing_basis is PricingBasis.PER_PERSON_PER_STAY for p in prices)


# ------------------------------------------------------- dve tabele = dve dužine


def test_obe_tabele_su_bus_ne_dva_prevoza(offers):
    """Obe tabele nose 'autobuski prevoz' u naslovu — jedna ponuda, jedan offer."""
    assert offers[0].transport_type is TransportType.BUS
    assert all(d.transport_type is TransportType.BUS for d in offers[0].departures)


def test_deset_termina_iz_dve_tabele(offers):
    """5 perioda x 2 tabele (10 i 7 noći) = 10 termina u jednoj ponudi."""
    nights = sorted(d.nights for d in offers[0].departures)
    assert nights == [7, 7, 7, 7, 7, 10, 10, 10, 10, 10]


def test_nema_dva_termina_sa_istim_datumima_u_istoj_ponudi(offers):
    """Baza ima UNIQUE (offer_id, start_date, end_date, departure_place_raw)."""
    for offer in offers:
        keys = [(d.start_date, d.end_date) for d in offer.departures]
        assert len(keys) == len(set(keys)), f"duplirani termin u {offer.external_id}"


# ------------------------------------------------------- broj plativih osoba


def test_broj_plativih_osoba_je_merodavan_za_kapacitet(offers):
    """'1/3+1 STD' ima 'Broj plativih osoba'=4 — svi plaćaju punu cenu, ne 3."""
    prices = _prices_for(offers[0], "1/3+1-std")
    assert prices
    assert all(p.capacity_adults == 4 for p in prices)
    assert all(p.capacity_extra == 0 for p in prices)


def test_std_i_renov_su_razlicite_sobe(offers):
    """'1/2 STD' i '1/2 STD RENOV*' dele razlomak ali ne smeju deliti room_code."""
    std = _prices_for(offers[0], "1/2-std")
    renov = _prices_for(offers[0], "1/2-std-renov")
    assert std and renov
    assert {p.room_code for p in std} == {"1/2-std"}
    assert {p.room_code for p in renov} == {"1/2-std-renov"}

    dep = next(d for d in offers[0].departures if d.start_date == date(2026, 6, 9))
    std_price = next(p for p in dep.prices if p.room_code == "1/2-std")
    renov_price = next(p for p in dep.prices if p.room_code == "1/2-std-renov")
    assert std_price.amount == Decimal("265")
    assert renov_price.amount == Decimal("285")


def test_pomocni_lezaj_crtica_znaci_nula(offers):
    prices = _prices_for(offers[0], "1/2-std")
    assert all("pomoćni ležaji: 0" in (p.notes or "") for p in prices)


# ------------------------------------------------------------- cene i termini


def test_prvi_period_desete_tabele(offers):
    """Prvi period 10-noćne tabele: 20.05.-30.05., cena 1/2 STD = 170, uslovan."""
    dep = next(
        d for d in offers[0].departures if d.nights == 10 and d.start_date.day == 20
    )
    assert dep.end_date == date(dep.start_date.year, 5, 30)
    price = next(p for p in dep.prices if p.room_code == "1/2-std")
    assert price.amount == Decimal("170")
    assert "uslovan period" in (price.notes or "")


def test_drugi_period_nije_uslovan(offers):
    """Drugi period (200, bez zvezdice) ne sme biti označen kao uslovan."""
    dep = next(d for d in offers[0].departures if d.start_date == date(2027, 5, 30))
    price = next(p for p in dep.prices if p.room_code == "1/2-std")
    assert price.amount == Decimal("200")
    assert "uslovan period" not in (price.notes or "")


def test_sedmodnevna_tabela_nema_1_2_renov(offers):
    """7-noćna tabela u fixture-u ima samo tri reda, bez RENOV varijante."""
    sedam = [d for d in offers[0].departures if d.nights == 7]
    codes = {p.room_code for d in sedam for p in d.prices}
    assert codes == {"1/2-std", "1/3-std", "1/3+1-std"}


def test_datumi_bez_crtice_se_parsiraju(offers):
    """'03.08. 10.08.' (bez crtice) mora dati ispravan opseg."""
    dep = next(d for d in offers[0].departures if d.nights == 7 and d.start_date.month == 8)
    assert dep.start_date == date(2026, 8, 3)
    assert dep.end_date == date(2026, 8, 10)


# ------------------------------------------------------------------- identitet


def test_external_id_iz_url_a(offers):
    assert offers[0].external_id == "8339__bus"


def test_external_id_je_stabilan():
    html = FIXTURE.read_text(encoding="utf-8")
    first = {o.external_id for o in parse_hotel_page(html, URL, reference=REFERENCE)}
    second = {o.external_id for o in parse_hotel_page(html, URL, reference=REFERENCE)}
    assert first == second


def test_url_bez_naslova_ne_daje_ponude():
    assert parse_hotel_page("<html><body>bez title taga</body></html>", URL) == []


# ------------------------------------------------------------------- doplata za AC


def test_ac_doplata_se_prepoznaje_iz_teksta():
    text = "Cenovnik ... AC - uz doplatu na licu mesta od 6€ dnevno ... ostalo"
    surcharge = extract_ac_surcharge(text)
    assert surcharge is not None
    assert surcharge.amount == Decimal("6")
    assert surcharge.currency == "EUR"
    assert surcharge.unit is SurchargeUnit.PER_UNIT_PER_NIGHT
    assert surcharge.payable is Payable.ON_SITE


def test_bez_ac_fraze_nema_doplate():
    assert extract_ac_surcharge("stranica bez pomena klime") is None


def test_ac_doplata_ulazi_u_ponudu_kad_postoji_u_tekstu():
    html = FIXTURE.read_text(encoding="utf-8").replace(
        "</body>", "<p>AC - uz doplatu na licu mesta od 6€ dnevno</p></body>"
    )
    offers = parse_hotel_page(html, URL, reference=REFERENCE)
    assert offers[0].surcharges
    assert offers[0].surcharges[0].amount == Decimal("6")


# ------------------------------------------------------------------- sitemap


def test_sitemap_filtrira_na_putovanje_obrazac():
    xml = """<?xml version="1.0"?><urlset>
        <url><loc>https://www.oktopod.rs/sr/leto-2026/1</loc></url>
        <url><loc>https://www.oktopod.rs/sr/putovanje/vila-penny-hanioti/8339</loc></url>
        <url><loc>https://www.oktopod.rs/sr/putovanje/hotel-x/123/</loc></url>
        <url><loc>https://www.oktopod.rs/sr/rimini/811</loc></url>
    </urlset>"""
    urls = detail_urls_from_sitemap(xml)
    assert urls == [
        "https://www.oktopod.rs/sr/putovanje/vila-penny-hanioti/8339",
        "https://www.oktopod.rs/sr/putovanje/hotel-x/123/",
    ]


def test_sitemap_bez_loc_daje_praznu_listu():
    assert detail_urls_from_sitemap("<urlset></urlset>") == []
