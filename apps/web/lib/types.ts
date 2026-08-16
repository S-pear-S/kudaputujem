// Preslikava DTOs iz apps/api/src/main/kotlin/rs/kudaputujem/api/search/SearchResult.kt
// Svaka promena Kotlin DTO-a mora da se odrazi i ovde.

export type ProductKind = 'PACKAGE' | 'TRANSPORT' | 'ACCOMMODATION';
export type TransportType = 'BUS' | 'PLANE' | 'TRAIN' | 'FERRY' | 'MINIVAN' | 'OWN' | 'NONE';
export type BoardType = 'RO' | 'BB' | 'HB' | 'FB' | 'AI' | 'UAI' | 'NONE';
export type SortBy =
  | 'PRICE'
  | 'PRICE_PER_PERSON'
  | 'DATE'
  | 'NIGHTS'
  | 'STARS'
  | 'RATING'
  | 'UPDATED';
export type SortDirection = 'ASC' | 'DESC';

export interface AgencySnippet {
  id: number;
  name: string;
  slug: string;
  logoUrl: string | null;
}

export interface AccommodationSnippet {
  id: number;
  name: string;
  slug: string;
  stars: number | null;
  ratingAvg: number | null;
}

export interface DestinationSnippet {
  id: number;
  nameSr: string;
  slug: string;
  countryCode: string;
}

export interface DepartureSnippet {
  departureId: number;
  startDate: string; // ISO date "2026-07-15"
  endDate: string;
  nights: number;
  transportType: TransportType;
  boardType: BoardType;
  departurePlaceRaw: string | null;
  seatsLeft: number | null;
}

export interface PriceSnippet {
  totalAmount: number;
  perPersonAmount: number;
  currency: string;
  totalRsd: number;
  isExact: boolean;
}

export interface OfferCard {
  offerId: number;
  title: string;
  slug: string;
  url: string;
  productKind: ProductKind;
  agency: AgencySnippet;
  accommodation: AccommodationSnippet | null;
  destination: DestinationSnippet | null;
  departure: DepartureSnippet;
  price: PriceSnippet;
  images: string[];
  lastSeenAt: string; // ISO timestamp
  isLastMinute: boolean;
}

export interface PageResponse<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
  hasNext: boolean;
}

// -- Parametri pretrage -------------------------------------------------------

export interface SearchParams {
  productKind?: ProductKind;
  destinationId?: string;
  countryCode?: string;
  dateFrom?: string;
  dateTo?: string;
  nightsMin?: string;
  nightsMax?: string;
  adults?: string;
  childAges?: string | string[];
  rooms?: string;
  transportType?: TransportType;
  boardType?: BoardType;
  departurePlaceId?: string;
  priceMax?: string;
  starsMin?: string;
  sortBy?: SortBy;
  sortDir?: SortDirection;
  page?: string;
  pageSize?: string;
}
