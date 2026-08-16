import type { Metadata } from 'next';
import { Geist } from 'next/font/google';
import Link from 'next/link';
import './globals.css';

const geist = Geist({ subsets: ['latin'], variable: '--font-geist-sans' });

export const metadata: Metadata = {
  title: {
    default: 'Kuda putujem — pretraga aranžmana srpskih agencija',
    template: '%s | Kuda putujem',
  },
  description:
    'Poredite ponude svih srpskih turističkih agencija na jednom mestu. Letovanje, zimovanje, aranžmani.',
  openGraph: {
    type: 'website',
    locale: 'sr_RS',
    siteName: 'Kuda putujem',
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="sr">
      <body className={`${geist.variable} min-h-screen flex flex-col bg-white`}>
        <header className="border-b border-slate-200 bg-white sticky top-0 z-40">
          <div className="max-w-6xl mx-auto px-4 h-14 flex items-center justify-between">
            <Link href="/" className="text-blue-600 font-bold text-lg tracking-tight">
              Kuda putujem
            </Link>
            <nav className="text-sm text-slate-500 hidden sm:flex gap-6">
              <Link href="/pretraga" className="hover:text-slate-900">Pretraga</Link>
            </nav>
          </div>
        </header>

        <main className="flex-1">{children}</main>

        <footer className="border-t border-slate-200 mt-16 py-8 text-center text-sm text-slate-400">
          <p>© 2026 Kuda putujem — metapretraživač srpskih turističkih agencija</p>
          <p className="mt-1">
            Cene su informativnog karaktera. Konačnu cenu potvrđuje agencija.
          </p>
        </footer>
      </body>
    </html>
  );
}
