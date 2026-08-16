"""Testovi za soleazur.rs adapter.

Testiraju parsiranje cena i strukture bez HTTP poziva.
Koristimo HTML fixture koji odgovara strukturi /lm/display_prices.php.

NAPOMENA: Fixture je konstruisan na osnovu markdown-a koji WebFetch vraća.
Selektori (h2, thead, tbody) su PRETPOSTAVLJENI i treba ih verifikovati
lokalno pokretanjem: travelscrape snapshot soleazur-grcka https://soleazur.rs/lm/display_prices.php
"""

from __future__ import annotations

from datetime import date
from decimal import Decimal

import pytest

from travelscrape.adapters.soleazur import (
    _dates_from_header,
    _parse_price_cell,
    _parse_room,
    _transports_from_header,
    _PeriodCol,
    parse_price_page,
)
from travelscrape.core.enums import TransportType

# ---------------------------------------------------------------------------
# Unit testovi parsiranja
# ---------------------------------------------------------------------------


class TestTransportFromHeader:
    def test_sopstveni_bus(self):
        result = _transports_from_header("11d/10n (28.08.-07.09.) Sopstveni/Bus")
        assert result == [TransportType.OWN, TransportType.BUS]

    def test_avio_only(self):
        result = _transports_from_header("11d/10n (22.08.-01.09.) Avio")
        assert result == [TransportType.PLANE]

    def test_lowercase(self):
        result = _transports_from_header("sopstveni/bus")
        assert TransportType.OWN in result
        assert TransportType.BUS in result


class TestDatesFromHeader:
    def test_standard(self):
        result = _dates_from_header("11d/10n (28.08.-07.09.) Sopstveni/Bus", 2026)
        assert result == (date(2026, 8, 28), date(2026, 9, 7))

    def test_dec_to_jan(self):
        result = _dates_from_header("25.12.-04.01.", 2026)
        assert result == (date(2026, 12, 25), date(2027, 1, 4))

    def test_no_dates(self):
        result = _dates_from_header("Objekat", 2026)
        assert result is None


class TestParsePriceCell:
    def _col(self, transports=None) -> _PeriodCol:
        return _PeriodCol(
            start_date=date(2026, 8, 28),
            end_date=date(2026, 9, 7),
            nights=10,
            transports=transports or [TransportType.OWN, TransportType.BUS],
        )

    def test_sopstveni_bus_with_promo(self):
        entries = _parse_price_cell("209€ (235€) / 275€ (305€)", self._col())
        assert len(entries) == 2
        assert entries[0].transport == TransportType.OWN
        assert entries[0].amount == Decimal("209")
        assert entries[0].original_amount == Decimal("235")
        assert entries[0].is_promo is True
        assert entries[1].transport == TransportType.BUS
        assert entries[1].amount == Decimal("275")
        assert entries[1].original_amount == Decimal("305")

    def test_unavailable_slash(self):
        entries = _parse_price_cell("/", self._col())
        assert entries == []

    def test_empty_cell(self):
        entries = _parse_price_cell("", self._col())
        assert entries == []

    def test_x_unavailable(self):
        entries = _parse_price_cell("x€ (235€) / 275€ (305€)", self._col())
        # "x€" nije broj, preskačemo
        assert len(entries) == 1
        assert entries[0].transport == TransportType.BUS

    def test_no_promo(self):
        entries = _parse_price_cell("195€ / 259€", self._col())
        assert len(entries) == 2
        assert entries[0].original_amount is None
        assert entries[0].is_promo is False


class TestParseRoom:
    def test_studio_1_3_plus_1(self):
        code, adults, extra = _parse_room("Studio 1/3+1 dvorište")
        assert code == "1/3+1"
        assert adults == 3
        assert extra == 1

    def test_standard_1_2(self):
        code, adults, extra = _parse_room("Studio 1/2")
        assert code == "1/2"
        assert adults == 2
        assert extra == 0

    def test_mezoneta_1_4(self):
        code, adults, extra = _parse_room("Mezoneta 1/4")
        assert code == "1/4"
        assert adults == 4
        assert extra == 0

    def test_no_standard_code(self):
        # Hoteli ponekad imaju "Superior" bez 1/N šifre
        code, adults, extra = _parse_room("Superior")
        assert adults == 2  # fallback


# ---------------------------------------------------------------------------
# Integralni test parsiranja HTML stranice
# ---------------------------------------------------------------------------

FIXTURE_HTML = """
<!DOCTYPE html>
<html>
<body>
<h2>Neos Marmaras leto 2026</h2>
<table>
  <thead>
    <tr>
      <th>Objekat</th>
      <th>Soba</th>
      <th>11d/10n (28.08.-07.09.) Sopstveni/Bus</th>
      <th>11d/10n (07.09.-17.09.) Sopstveni/Bus</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Ridos house</td>
      <td>Studio 1/3+1 dvorište D1</td>
      <td>209€ (235€) / 275€ (305€)</td>
      <td>/</td>
    </tr>
    <tr>
      <td></td>
      <td>Mezoneta 1/4</td>
      <td>265€ / 335€</td>
      <td>215€ (255€) / 285€ (335€)</td>
    </tr>
  </tbody>
</table>

<h2>Nei Pori leto 2026</h2>
<table>
  <thead>
    <tr>
      <th>Objekat</th>
      <th>Soba</th>
      <th>11d/10n (23.08.-02.09.) Sopstveni/Bus</th>
      <th>11d/10n (02.09.-12.09.) Sopstveni/Bus</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Vila Filio</td>
      <td>Studio 1/2</td>
      <td>229€ (289€) / 295€ (369€)</td>
      <td>195€ (229€) / 259€ (309€)</td>
    </tr>
  </tbody>
</table>
</body>
</html>
"""


class TestParsePricePage:
    def test_finds_two_offers(self):
        offers = parse_price_page(FIXTURE_HTML, default_year=2026)
        assert len(offers) == 2

    def test_ridos_house_offer(self):
        offers = parse_price_page(FIXTURE_HTML, default_year=2026)
        ridos = next(o for o in offers if "Ridos" in o.title)
        assert ridos.destination_raw == "Neos Marmaras"
        assert ridos.country_raw == "Grčka"
        assert ridos.accommodation is not None
        assert ridos.accommodation.name == "Ridos house"

    def test_ridos_departures_count(self):
        offers = parse_price_page(FIXTURE_HTML, default_year=2026)
        ridos = next(o for o in offers if "Ridos" in o.title)
        # Studio 1/3+1: period1 ima OWN+BUS, period2 nema ("/")
        # Mezoneta 1/4: period1 ima OWN+BUS, period2 ima OWN+BUS
        # Ukupno: 2 + 4 = 6 departure redova
        assert len(ridos.departures) == 6

    def test_dates_correct(self):
        offers = parse_price_page(FIXTURE_HTML, default_year=2026)
        ridos = next(o for o in offers if "Ridos" in o.title)
        start_dates = {d.start_date for d in ridos.departures}
        assert date(2026, 8, 28) in start_dates

    def test_transport_types(self):
        offers = parse_price_page(FIXTURE_HTML, default_year=2026)
        ridos = next(o for o in offers if "Ridos" in o.title)
        transports = {d.transport_type for d in ridos.departures}
        assert TransportType.OWN in transports
        assert TransportType.BUS in transports

    def test_is_last_minute(self):
        offers = parse_price_page(FIXTURE_HTML, default_year=2026)
        for offer in offers:
            for dep in offer.departures:
                assert dep.is_last_minute is True

    def test_promo_price(self):
        offers = parse_price_page(FIXTURE_HTML, default_year=2026)
        ridos = next(o for o in offers if "Ridos" in o.title)
        promo_deps = [d for d in ridos.departures if d.prices and d.prices[0].is_promo]
        # Studio i Mezoneta sa (regularnom) cenom
        assert len(promo_deps) > 0

    def test_vila_filio_both_periods(self):
        offers = parse_price_page(FIXTURE_HTML, default_year=2026)
        vila = next(o for o in offers if "Vila Filio" in o.title)
        # Studio 1/2: 2 perioda × 2 prevoza = 4 departures
        assert len(vila.departures) == 4

    def test_source_slug(self):
        offers = parse_price_page(FIXTURE_HTML, default_year=2026)
        for offer in offers:
            assert offer.source_slug == "soleazur-grcka"
