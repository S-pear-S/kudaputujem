'use client';

import { Search } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { useCallback, useState } from 'react';
import type { SearchParams, SortBy, TransportType } from '@/lib/types';
import PaxSelector from './PaxSelector';

const TRANSPORT_OPTIONS: { value: TransportType | ''; label: string }[] = [
  { value: '', label: 'Svi prevozi' },
  { value: 'BUS', label: '🚌 Autobus' },
  { value: 'PLANE', label: '✈️ Avion' },
  { value: 'OWN', label: '🚗 Sopstveni' },
];

const NIGHTS_OPTIONS = [
  { value: '', label: 'Bilo koji broj noćenja' },
  { value: '7', label: '7 noćenja' },
  { value: '8', label: '8 noćenja' },
  { value: '10', label: '10 noćenja' },
  { value: '14', label: '14 noćenja' },
];

const SORT_OPTIONS: { value: SortBy; label: string }[] = [
  { value: 'PRICE_PER_PERSON', label: 'Cena po osobi' },
  { value: 'DATE', label: 'Datum polaska' },
  { value: 'STARS', label: 'Broj zvezdica' },
  { value: 'RATING', label: 'Ocena' },
  { value: 'UPDATED', label: 'Najsvežije' },
];

interface Props {
  defaults?: SearchParams;
}

export default function SearchForm({ defaults = {} }: Props) {
  const router = useRouter();
  const [dateFrom, setDateFrom] = useState(defaults.dateFrom ?? '');
  const [dateTo, setDateTo] = useState(defaults.dateTo ?? '');
  const [nights, setNights] = useState(defaults.nightsMin ?? '');
  const [transport, setTransport] = useState<TransportType | ''>(
    (defaults.transportType as TransportType | undefined) ?? '',
  );
  const [sortBy, setSortBy] = useState<SortBy>(
    (defaults.sortBy as SortBy | undefined) ?? 'PRICE_PER_PERSON',
  );
  const [pax, setPax] = useState({
    adults: Number(defaults.adults ?? 2),
    childAges: defaults.childAges
      ? (Array.isArray(defaults.childAges) ? defaults.childAges : [defaults.childAges]).map(Number)
      : [],
  });

  const handleSubmit = useCallback(
    (e: React.FormEvent) => {
      e.preventDefault();
      const params = new URLSearchParams();
      if (dateFrom) params.set('dateFrom', dateFrom);
      if (dateTo) params.set('dateTo', dateTo);
      if (nights) {
        params.set('nightsMin', nights);
        params.set('nightsMax', nights);
      }
      params.set('adults', String(pax.adults));
      pax.childAges.forEach((age) => params.append('childAges', String(age)));
      if (transport) params.set('transportType', transport);
      params.set('sortBy', sortBy);
      router.push(`/pretraga?${params.toString()}`);
    },
    [dateFrom, dateTo, nights, pax, transport, sortBy, router],
  );

  return (
    <form
      onSubmit={handleSubmit}
      className="bg-white rounded-2xl shadow-lg border border-slate-100 p-5 space-y-4"
    >
      {/* Red 1: datumi */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <div>
          <label className="block text-xs font-medium text-slate-500 mb-1">Od</label>
          <input
            type="date"
            value={dateFrom}
            onChange={(e) => setDateFrom(e.target.value)}
            className="w-full px-3 py-2.5 border border-slate-300 rounded-lg text-sm focus:outline-none focus:border-blue-500"
          />
        </div>
        <div>
          <label className="block text-xs font-medium text-slate-500 mb-1">Do</label>
          <input
            type="date"
            value={dateTo}
            min={dateFrom}
            onChange={(e) => setDateTo(e.target.value)}
            className="w-full px-3 py-2.5 border border-slate-300 rounded-lg text-sm focus:outline-none focus:border-blue-500"
          />
        </div>
      </div>

      {/* Red 2: putnici i nocenja */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <div>
          <label className="block text-xs font-medium text-slate-500 mb-1">Putnici</label>
          <PaxSelector value={pax} onChange={setPax} />
        </div>
        <div>
          <label className="block text-xs font-medium text-slate-500 mb-1">Noćenja</label>
          <select
            value={nights}
            onChange={(e) => setNights(e.target.value)}
            className="w-full px-3 py-2.5 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:border-blue-500"
          >
            {NIGHTS_OPTIONS.map((o) => (
              <option key={o.value} value={o.value}>
                {o.label}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Red 3: prevoz i sortiranje */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <div>
          <label className="block text-xs font-medium text-slate-500 mb-1">Prevoz</label>
          <select
            value={transport}
            onChange={(e) => setTransport(e.target.value as TransportType | '')}
            className="w-full px-3 py-2.5 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:border-blue-500"
          >
            {TRANSPORT_OPTIONS.map((o) => (
              <option key={o.value} value={o.value}>
                {o.label}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="block text-xs font-medium text-slate-500 mb-1">Sortiraj po</label>
          <select
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value as SortBy)}
            className="w-full px-3 py-2.5 border border-slate-300 rounded-lg text-sm bg-white focus:outline-none focus:border-blue-500"
          >
            {SORT_OPTIONS.map((o) => (
              <option key={o.value} value={o.value}>
                {o.label}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Dugme */}
      <button
        type="submit"
        className="w-full flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-6 rounded-xl transition-colors"
      >
        <Search size={18} />
        Traži
      </button>
    </form>
  );
}
