"""Mapiranje načina prevoza."""

from __future__ import annotations

import re

from ..enums import TransportType
from .text import normalize

_RULES: list[tuple[re.Pattern[str], TransportType]] = [
    (
        re.compile(
            r"\b(sopstveni\w*|sopstvenim|svojim prevoz\w*|individualn\w+ prevoz|"
            r"licni prevoz|bez prevoza|own transport|self ?drive|automobil\w*|kolima)\b"
        ),
        TransportType.OWN,
    ),
    (
        re.compile(r"\b(avio\w*|avion\w*|carter|carter let|charter|let\b|flight|aviom)\b"),
        TransportType.PLANE,
    ),
    (re.compile(r"\b(minibus\w*|minivan\w*|kombi\w*|van)\b"), TransportType.MINIVAN),
    (re.compile(r"\b(autobus\w*|bus\w*|busom|autobuski)\b"), TransportType.BUS),
    (re.compile(r"\b(voz\w*|vozom|train|zeleznic\w*)\b"), TransportType.TRAIN),
    (re.compile(r"\b(brod\w*|trajekt\w*|ferry|katamaran\w*)\b"), TransportType.FERRY),
]

LABELS_SR: dict[TransportType, str] = {
    TransportType.BUS: "Autobus",
    TransportType.PLANE: "Avion",
    TransportType.TRAIN: "Voz",
    TransportType.FERRY: "Brod",
    TransportType.MINIVAN: "Minibus",
    TransportType.OWN: "Sopstveni prevoz",
    TransportType.NONE: "Nije navedeno",
}


def parse_transport(text: str | None) -> TransportType:
    if not text:
        return TransportType.NONE
    norm = normalize(text)
    for pattern, kind in _RULES:
        if pattern.search(norm):
            return kind
    return TransportType.NONE


def parse_transport_options(text: str | None) -> list[TransportType]:
    """Za ponude tipa 'autobusom ili sopstvenim prevozom' vraća SVE opcije.

    Ovo je važno: ista ponuda se u pretrazi mora naći i pod BUS i pod OWN.
    """
    if not text:
        return []
    norm = normalize(text)
    found: list[TransportType] = []
    for pattern, kind in _RULES:
        if pattern.search(norm) and kind not in found:
            found.append(kind)
    return found
