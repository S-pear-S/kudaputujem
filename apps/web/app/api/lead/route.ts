import { NextRequest, NextResponse } from 'next/server';

// TODO: Kad Lead API bude gotov na backendu, ovo ce proslediti zahtev ka /api/leads.
// Za sada vraca placeholder uspeh da forma radi end-to-end.
export async function POST(req: NextRequest) {
  const body = await req.json();

  // Validacija obaveznih polja
  if (!body.name || !body.email || !body.phone || !body.offerId) {
    return NextResponse.json(
      { error: 'Nedostaju obavezna polja: name, email, phone, offerId' },
      { status: 400 },
    );
  }

  // TODO: proslediti ka http://localhost:8080/api/leads kad endpoint bude implementiran
  console.log('[lead] upit za ponudu', body.offerId, '—', body.name, body.email);

  return NextResponse.json({ status: 'ok' });
}
