import { Suspense } from 'react';
import OfferCard from '@/components/OfferCard';
import SearchForm from '@/components/SearchForm';
import { fetchOffers } from '@/lib/api';
import type { SearchParams } from '@/lib/types';

// Next.js 15: searchParams je Promise
type PageProps = {
  searchParams: Promise<SearchParams>;
};

export const metadata = {
  title: 'Rezultati pretrage',
};

export default async function PretragaPage({ searchParams }: PageProps) {
  const params = await searchParams;

  let result;
  let error: string | null = null;

  try {
    result = await fetchOffers(params);
  } catch (err) {
    error = err instanceof Error ? err.message : 'Greška pri učitavanju.';
  }

  return (
    <div className="max-w-6xl mx-auto px-4 py-8">
      {/* Forma za refinement pretrage */}
      <div className="mb-8">
        <SearchForm defaults={params} />
      </div>

      {error ? (
        <div className="bg-red-50 border border-red-200 text-red-700 rounded-xl p-6 text-sm">
          <p className="font-semibold mb-1">Nije moguće učitati rezultate</p>
          <p>{error}</p>
          <p className="mt-2 text-red-500">
            Proverite da li je API server pokrenut na localhost:8080.
          </p>
        </div>
      ) : result ? (
        <>
          {/* Broj rezultata */}
          <p className="text-sm text-slate-500 mb-4">
            {result.total === 0
              ? 'Nema rezultata za zadate kriterijume.'
              : `${result.total} ponuda${result.total !== 1 ? '' : 'a'}`}
          </p>

          {/* Lista ponuda */}
          <div className="space-y-4">
            {result.data.map((offer) => (
              <OfferCard key={offer.offerId} offer={offer} />
            ))}
          </div>

          {/* Paginacija */}
          {result.totalPages > 1 && (
            <div className="mt-8 flex justify-center gap-2">
              <Suspense>
                <Pagination current={result.page} total={result.totalPages} params={params} />
              </Suspense>
            </div>
          )}

          {/* Napomena o ceni */}
          <p className="mt-8 text-xs text-slate-400 text-center">
            * Cena je aproksimacija za odrasle putnike. Tačnu cenu za decu potvrđuje agencija.
            Cene su ažurirane u poslednjih 96 sati.
          </p>
        </>
      ) : null}
    </div>
  );
}

function Pagination({
  current,
  total,
  params,
}: {
  current: number;
  total: number;
  params: SearchParams;
}) {
  function pageHref(page: number) {
    const q = new URLSearchParams();
    Object.entries(params).forEach(([k, v]) => {
      if (k === 'page') return;
      if (Array.isArray(v)) v.forEach((x) => q.append(k, x));
      else if (v !== undefined) q.set(k, v);
    });
    q.set('page', String(page));
    return `/pretraga?${q.toString()}`;
  }

  const pages = Array.from({ length: Math.min(total, 7) }, (_, i) => {
    if (total <= 7) return i + 1;
    if (current <= 4) return i + 1;
    if (current >= total - 3) return total - 6 + i;
    return current - 3 + i;
  });

  return (
    <>
      {current > 1 && (
        <a
          href={pageHref(current - 1)}
          className="px-3 py-2 rounded border border-slate-200 text-sm hover:bg-slate-50"
        >
          ‹ Prethodna
        </a>
      )}
      {pages.map((p) => (
        <a
          key={p}
          href={pageHref(p)}
          className={`px-3 py-2 rounded border text-sm ${
            p === current
              ? 'bg-blue-600 border-blue-600 text-white'
              : 'border-slate-200 hover:bg-slate-50'
          }`}
        >
          {p}
        </a>
      ))}
      {current < total && (
        <a
          href={pageHref(current + 1)}
          className="px-3 py-2 rounded border border-slate-200 text-sm hover:bg-slate-50"
        >
          Sledeća ›
        </a>
      )}
    </>
  );
}
