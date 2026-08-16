'use client';

import { X } from 'lucide-react';
import { useState } from 'react';
import type { OfferCard } from '@/lib/types';

interface Props {
  offer: OfferCard;
}

type State = 'idle' | 'submitting' | 'done' | 'error';

export default function LeadModal({ offer }: Props) {
  const [open, setOpen] = useState(false);
  const [state, setState] = useState<State>('idle');
  const [errorMsg, setErrorMsg] = useState('');

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setState('submitting');

    const fd = new FormData(e.currentTarget);
    const body = {
      offerId: offer.offerId,
      offerTitle: offer.title,
      offerUrl: offer.url,
      agencyName: offer.agency.name,
      name: fd.get('name'),
      email: fd.get('email'),
      phone: fd.get('phone'),
      message: fd.get('message'),
    };

    try {
      const res = await fetch('/api/lead', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });
      if (!res.ok) throw new Error(await res.text());
      setState('done');
    } catch (err) {
      setErrorMsg(err instanceof Error ? err.message : 'Greška pri slanju.');
      setState('error');
    }
  }

  return (
    <>
      <button
        onClick={() => { setOpen(true); setState('idle'); }}
        className="bg-blue-600 hover:bg-blue-700 text-white text-sm font-semibold px-4 py-2.5 rounded-lg transition-colors whitespace-nowrap"
      >
        Pošalji upit
      </button>

      {open && (
        <div
          className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
          onClick={(e) => e.target === e.currentTarget && setOpen(false)}
        >
          <div className="bg-white rounded-2xl shadow-xl w-full max-w-md">
            <div className="flex items-center justify-between p-5 border-b border-slate-100">
              <h2 className="font-semibold text-slate-900">Pošalji upit agenciji</h2>
              <button onClick={() => setOpen(false)} className="text-slate-400 hover:text-slate-700">
                <X size={20} />
              </button>
            </div>

            {state === 'done' ? (
              <div className="p-8 text-center">
                <p className="text-2xl mb-2">✅</p>
                <p className="font-semibold text-slate-900 mb-1">Upit je poslat!</p>
                <p className="text-sm text-slate-500">
                  Agencija {offer.agency.name} će vas kontaktirati.
                </p>
                <button
                  onClick={() => setOpen(false)}
                  className="mt-6 text-sm text-blue-600 font-medium"
                >
                  Zatvori
                </button>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="p-5 space-y-4">
                <div className="bg-slate-50 rounded-lg p-3 text-sm text-slate-600">
                  <p className="font-medium text-slate-800">{offer.accommodation?.name ?? offer.title}</p>
                  <p className="text-slate-500 mt-0.5">{offer.agency.name}</p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1">Ime i prezime *</label>
                  <input
                    name="name"
                    required
                    className="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-blue-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1">Email *</label>
                  <input
                    name="email"
                    type="email"
                    required
                    className="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-blue-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1">Telefon *</label>
                  <input
                    name="phone"
                    type="tel"
                    required
                    className="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-blue-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1">Poruka (opciono)</label>
                  <textarea
                    name="message"
                    rows={3}
                    className="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:border-blue-500 resize-none"
                  />
                </div>

                <label className="flex items-start gap-2 text-sm text-slate-600">
                  <input name="consent" type="checkbox" required className="mt-0.5" />
                  <span>
                    Slažem se da se moji kontakt podaci prosleđuju agenciji radi odgovora na upit.
                  </span>
                </label>

                {state === 'error' && (
                  <p className="text-sm text-red-600">{errorMsg}</p>
                )}

                <button
                  type="submit"
                  disabled={state === 'submitting'}
                  className="w-full bg-blue-600 hover:bg-blue-700 disabled:opacity-60 text-white font-semibold py-3 rounded-xl transition-colors"
                >
                  {state === 'submitting' ? 'Šalje se...' : 'Pošalji upit'}
                </button>

                <p className="text-xs text-slate-400 text-center">
                  Nema plaćanja. Agencija potvrđuje dostupnost i cenu.
                </p>
              </form>
            )}
          </div>
        </div>
      )}
    </>
  );
}
