"""Bazna klasa za adaptere.

Svaki adapter pokriva jednu platformu (Onesystem, b2cservice, ...).
Adapter zna HTML/JSON format sajta, ali NE zna za bazu.
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from typing import AsyncGenerator, ClassVar

from travelcore.models import OfferIn, RawOffer

from .fetch import HttpFetcher


class BaseAdapter(ABC):
    """Apstraktna baza za sve adaptere.

    Implementacija:
        class OnesystemAdapter(BaseAdapter):
            source_slug = "1a-travel-letovanje"
            allowed_domains = {"1atravel.rs", "www.1atravel.rs"}

            async def scrape(self, fetcher):
                for page in ...:
                    yield await self._parse_page(page)
    """

    # Svaka subklasa mora da definiše ove atribute.
    source_slug: ClassVar[str]
    allowed_domains: ClassVar[set[str]]

    @abstractmethod
    async def scrape(self, fetcher: HttpFetcher) -> AsyncGenerator[OfferIn, None]:
        """Skrepuje sve ponude ovog izvora i yields-uje ih jednu po jednu.

        Paginacija i parsiranje su unutar adaptera.
        Fetcher je vec konfigurisan sa allowlistom i rate limitom.
        Yield-ujemo OfferIn, ne RawOffer — adapter vrsi normalizaciju.
        """
        # yield je obavezno ovde da bi Python prepoznao ovo kao generator.
        # Subklase to zamenjuju pravim yield-om.
        yield  # type: ignore[misc]
        raise NotImplementedError

    # -- Pomocnici koje adapteri mogu koristiti --------------------------------

    def _make_raw(self, external_id: str, url: str, **kwargs: object) -> RawOffer:
        return RawOffer(external_id=external_id, url=url, **kwargs)  # type: ignore[arg-type]
