"""Registar adaptera.

Adapter se registruje dekoratorom @register i pronalazi po source_slug-u.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from .adapter import BaseAdapter

_registry: dict[str, type[BaseAdapter]] = {}


def register(cls: type[BaseAdapter]) -> type[BaseAdapter]:
    """Dekorator koji registruje adapter klasu.

    Primer:
        @register
        class OnesystemAdapter(BaseAdapter):
            source_slug = "1a-travel-letovanje"
            ...
    """
    slug = getattr(cls, "source_slug", None)
    if not slug:
        raise ValueError(f"{cls.__name__} nema source_slug atribut")
    if slug in _registry:
        raise ValueError(f"source_slug {slug!r} vec postoji: {_registry[slug].__name__}")
    _registry[slug] = cls
    return cls


def get(source_slug: str) -> BaseAdapter:
    """Vraca instancu adaptera za dati izvor. Baca KeyError ako nije registrovan."""
    cls = _registry.get(source_slug)
    if cls is None:
        available = sorted(_registry.keys())
        raise KeyError(
            f"Adapter za {source_slug!r} nije registrovan. "
            f"Dostupni: {available}"
        )
    return cls()


def list_sources() -> list[str]:
    """Vraca sortiranu listu svih registrovanih source_slug-ova."""
    return sorted(_registry.keys())
