import SearchForm from '@/components/SearchForm';

export default function HomePage() {
  return (
    <>
      {/* Hero */}
      <section className="bg-gradient-to-br from-blue-600 to-blue-800 text-white py-16 px-4">
        <div className="max-w-2xl mx-auto text-center mb-10">
          <h1 className="text-4xl sm:text-5xl font-bold mb-4">Kuda putujem?</h1>
          <p className="text-blue-100 text-lg">
            Poredite ponude srpskih agencija na jednom mestu.
          </p>
        </div>
        <div className="max-w-2xl mx-auto">
          <SearchForm />
        </div>
      </section>

      {/* Vrednosti */}
      <section className="max-w-4xl mx-auto px-4 py-16">
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-8 text-center">
          <div>
            <p className="text-3xl mb-3">🔍</p>
            <h2 className="font-semibold text-slate-900 mb-1">Sve agencije na jednom mestu</h2>
            <p className="text-sm text-slate-500">
              Ne morate da obiđete 20 sajtova. Mi radimo to umesto vas.
            </p>
          </div>
          <div>
            <p className="text-3xl mb-3">💰</p>
            <h2 className="font-semibold text-slate-900 mb-1">Poređenje cena</h2>
            <p className="text-sm text-slate-500">
              Vidite ko ima najjeftiniju ponudu za vaš termin i grupu.
            </p>
          </div>
          <div>
            <p className="text-3xl mb-3">✉️</p>
            <h2 className="font-semibold text-slate-900 mb-1">Direktan kontakt</h2>
            <p className="text-sm text-slate-500">
              Šaljete upit agenciji i oni vas kontaktuju. Bez posrednika.
            </p>
          </div>
        </div>
      </section>
    </>
  );
}
