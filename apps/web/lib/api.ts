import type { OfferCard, PageResponse, SearchParams } from './types';

const API_URL = process.env.API_URL ?? 'http://localhost:8080';

// Pretvara SearchParams u URLSearchParams za API poziv.
// childAges može biti niz — šalje se kao ?childAges=5&childAges=8.
function buildSearchQuery(params: SearchParams): string {
  const q = new URLSearchParams();
  const append = (key: string, val: string | undefined) => {
    if (val !== undefined && val !== '') q.append(key, val);
  };

  append('productKind', params.productKind);
  append('destinationId', params.destinationId);
  append('countryCode', params.countryCode);
  append('dateFrom', params.dateFrom);
  append('dateTo', params.dateTo);
  append('nightsMin', params.nightsMin);
  append('nightsMax', params.nightsMax);
  append('adults', params.adults);
  append('rooms', params.rooms);
  append('transportType', params.transportType);
  append('boardType', params.boardType);
  append('priceMax', params.priceMax);
  append('starsMin', params.starsMin);
  append('sortBy', params.sortBy);
  append('sortDir', params.sortDir);
  append('page', params.page);
  append('pageSize', params.pageSize);

  const ages = params.childAges;
  if (ages) {
    const arr = Array.isArray(ages) ? ages : [ages];
    arr.forEach((a) => q.append('childAges', a));
  }

  return q.toString();
}

export async function fetchOffers(
  params: SearchParams,
): Promise<PageResponse<OfferCard>> {
  const qs = buildSearchQuery(params);
  const url = `${API_URL}/api/search${qs ? `?${qs}` : ''}`;

  const res = await fetch(url, {
    // Pretraga se kešira 5 minuta — cene se retko menjaju, upiti se ponavljaju.
    next: { revalidate: 300 },
  });

  if (!res.ok) {
    throw new Error(`API greška ${res.status}: ${await res.text()}`);
  }

  return res.json() as Promise<PageResponse<OfferCard>>;
}
