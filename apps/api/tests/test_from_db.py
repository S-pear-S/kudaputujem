"""`from_db()` — Odluka B (CLAUDE.md §7 korak 4): rezerva ostaje, ali prestaje da bude tiha."""

from __future__ import annotations

import logging

import pytest
from travelcore.enums import CrawlStatus

from travelapi.common.from_db import from_db


@pytest.fixture(autouse=True)
def _capture_warnings(caplog: pytest.LogCaptureFixture) -> None:
    caplog.set_level(logging.WARNING, logger="travelapi.common.from_db")


def test_none_passes_through_without_warning(caplog: pytest.LogCaptureFixture) -> None:
    result = from_db(CrawlStatus, None, default=CrawlStatus.OK, table="crawl_run", column="status")
    assert result is None
    assert caplog.text == ""


def test_known_value_maps_to_enum_member(caplog: pytest.LogCaptureFixture) -> None:
    result = from_db(
        CrawlStatus, "SUSPECT", default=CrawlStatus.OK, table="crawl_run", column="status"
    )
    assert result is CrawlStatus.SUSPECT
    assert caplog.text == ""


def test_unknown_value_falls_back_and_warns(caplog: pytest.LogCaptureFixture) -> None:
    result = from_db(
        CrawlStatus, "BOGUS", default=CrawlStatus.OK, table="crawl_run", column="status"
    )
    assert result is CrawlStatus.OK
    assert "Nepoznata vrednost" in caplog.text
    assert "'BOGUS'" in caplog.text
    assert "crawl_run" in caplog.text
    assert "status" in caplog.text
