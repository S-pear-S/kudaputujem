"""Testovi za `core/fetch.py` SSRF zaštitu. Bez mreže — `socket.getaddrinfo` je mockovan.

Regresija za: `getaddrinfo()` tipski može vratiti `tuple[int, bytes]` kao sockaddr
za egzotične adresne familije. Stari kod je prosleđivao `info[4][0]` direktno u
`_is_forbidden_ip()`, koja poziva `ipaddress.ip_address()` — ta funkcija PRIHVATA
`int` kao celobrojnu IP adresu umesto da baci `ValueError`, pa fail-closed grana
(`except ValueError: return True`) se ne bi ni pozvala. Test simulira tačno taj
oblik povratne vrednosti.
"""

from __future__ import annotations

import socket

import pytest

from travelscrape.core.fetch import SsrfError, _validate_ssrf


def test_neparsirana_int_adresa_se_odbija(monkeypatch: pytest.MonkeyPatch) -> None:
    """`getaddrinfo` vraća sockaddr oblika `(int, bytes)` — mora biti odbijeno.

    1500000000 kao IP celobrojno mapira na 89.104.47.0, koji `ipaddress` NE
    smatra privatnom/loopback/link-local adresom — stari kod bi ovo tiho
    propustio kao "dozvoljeno" umesto da ga odbije jer je pogrešnog tipa.
    """

    def fake_getaddrinfo(host: str, port: object) -> list[tuple]:
        # Isti oblik kao stvarni povratak za egzotične adresne familije
        # (npr. AF_PACKET): peti element nije `(str, int)` nego `(int, bytes)`.
        return [(socket.AF_INET, socket.SOCK_STREAM, 6, "", (1500000000, b"\x00"))]

    monkeypatch.setattr(socket, "getaddrinfo", fake_getaddrinfo)

    with pytest.raises(SsrfError):
        _validate_ssrf("primer.rs", allowed_domains=None)


def test_normalna_privatna_ip_se_i_dalje_odbija(monkeypatch: pytest.MonkeyPatch) -> None:
    """Regresija ne sme da pokvari postojeću proveru za obične privatne IP adrese."""

    def fake_getaddrinfo(host: str, port: object) -> list[tuple]:
        return [(socket.AF_INET, socket.SOCK_STREAM, 6, "", ("127.0.0.1", 0))]

    monkeypatch.setattr(socket, "getaddrinfo", fake_getaddrinfo)

    with pytest.raises(SsrfError):
        _validate_ssrf("primer.rs", allowed_domains=None)


def test_normalna_javna_ip_prolazi(monkeypatch: pytest.MonkeyPatch) -> None:
    def fake_getaddrinfo(host: str, port: object) -> list[tuple]:
        return [(socket.AF_INET, socket.SOCK_STREAM, 6, "", ("93.184.216.34", 0))]

    monkeypatch.setattr(socket, "getaddrinfo", fake_getaddrinfo)

    _validate_ssrf("primer.rs", allowed_domains=None)
