# Uputstvo za Claude Code

Kopiraj ovo u terminal kao poruku, posle `git apply` patch-a.

---

## Šta je stiglo

Primenjen je patch `0001-soleazur-adapter-verifikovan-nad-pravim-fixture-om-f.patch`.

Fixture-i su snimljeni **kroz pravi Chrome, iz DOM-a**, ne iz konvertovanog markdowna.
Selektori u `docs/recon/` više nisu pretpostavka za soleazur i oktopod.

Novo u repou:

```
apps/scrapers/tests/fixtures/soleazur/display_prices.html
apps/scrapers/tests/fixtures/oktopod/putovanje_vila_penny.html
apps/scrapers/src/travelscrape/adapters/soleazur.py     ← prepravljen
apps/scrapers/tests/test_soleazur.py                    ← 19 testova nad fixture-om
docs/recon/soleazur.md, docs/recon/oktopod.md           ← dopunjeni
CLAUDE.md                                               ← status, rizici, pravila 14 i 15
```

Pokreni `pytest` da potvrdiš. Kod mene: 19 testova soleazur, ceo paket prolazi, `ruff` čist.

## Šta je bilo pogrešno u prethodnom adapteru

Četiri greške koje ne bi bacile izuzetak nego tiho dale pogrešne podatke:

1. **`rowspan` na imenu objekta.** Redovi posle prvog imaju **jednu ćeliju manje**.
   `cells[0]` je tada soba, a `cells[1]` je cena. Ceo objekat se čitao pomereno.
2. **`css("h2, table")` u selectolax ne vraća redosled dokumenta** nego prvo sve `h2`
   pa sve `table`. Svaka tabela je dobijala poslednju destinaciju sa stranice.
   Rešenje: `tree.root.traverse(include_text=False)`.
3. **Jedan `DepartureIn` po ceni** je pravio više termina sa istim datumima u istoj ponudi,
   što krši `UNIQUE (offer_id, start_date, end_date, departure_place_raw)` iz `V1__init.sql`.
   Ingest bi pukao na prvoj rundi. Sada je **jedan offer po prevozu** (`__own`, `__bus`).
4. **Ime objekta je u `<h6><a>` unutar `td[rowspan]`**, ne goli tekst ćelije.

Plus tri ispravke podataka, proverene na izvoru:

- **Cena je PO OSOBI.** `soleazur.rs/hoteli/ridos-house` piše doslovno
  `CENA ARANŽMANA PO OSOBI`, uz `smeštaj 10 noćenja (usluga najam)`.
  Tvoj `PriceSlot.ADULT` je bio ispravan; moj raniji recon koji je tvrdio `UNIT` nije.
  `board_type = RO`.
- **Puna cena ume da bude NIŽA od akcijske** — `619€ (585€)` stvarno postoji na sajtu.
  `is_promo` se ne sme izvoditi iz samog postojanja zagrade.
- **Kolone nemaju isti broj prevoza ni isto trajanje.** Kefalonija ima kolone samo za
  `Avio prevoz` (jedna cena, bez `/`) i `12 dana/11 noci` pored `11 dana/10 noci`.

## Ne čekaj fixture za maestral i aquatravel

Proverio sam ih u browseru:

- **maestral.co.rs** nema cenovnik nigde na sajtu. Detalj stranica ima samo dugme
  „Uradi rezervaciju" i formular za upit. Nema šta da se skrepuje.
- **aquatravel.rs** prikazuje cene tek posle AJAX poziva iz forme za pretragu.
  Tab „CENOVNIK" sadrži samo formu. Statičnog cenovnika nema.

Skini ih sa liste čekanja. Umesto njih idi ovim redom:

| Redosled | Sajt | Zašto | Fixture |
|---|---|---|---|
| 1 | **oktopod.rs** | `table.CSSTableGenerator`, kolona `Broj plativih osoba` daje kapacitet direktno | ✓ u repou |
| 2 | **grandtours.rs** | 3× `table.tablepress`, treća je cena prevoza po polaznom gradu | traži se |
| 3 | **euroturs.rs** | `table.main-table`, red `ND \|\| PO OSOBI \|\| 31 €` | traži se |
| 4 | **belvi.rs** | 4× `table.table-bordered`, ista struktura kao soleazur | traži se |
| 5 | **planatravel.rs** | cenovnik tek uz `?checkinDate=…&nights=7&adults[0]=2`, pun page reload | traži se |

Detalji za svaki su u `docs/recon/<slug>.md`, sekcija „Mapiranje kroz pravi browser".

## Sledeći zadatak

**Napiši adapter za `oktopod.rs`** nad fixture-om koji je već u repou.

Struktura tabele, potvrđena:

```
red 0   <td colspan=N> naslov paketa
red 1   <td rowspan=3>Struktura</td> <td rowspan=3>Broj pomoćnih ležaja</td>
        <td rowspan=3>Broj plativih osoba</td> <td colspan=M>PERIOD BORAVKA / BROJ NOĆENJA</td>
red 2   broj noćenja po periodu
red 3   datumi, oblik "20.05. 30.05."  ← dva datuma, BEZ crtice između
red 4+  struktura, pomoćni ležaji, plative osobe, pa cena po periodu
```

Na šta pazi:

- Dve tabele na stranici NISU dva prevoza nego **dve dužine boravka**, 10 i 7 noći.
  Obe su `PAKET ARANŽMAN (apartmanski smeštaj i autobuski prevoz)`, dakle obe `BUS`.
- **`Broj plativih osoba` koristi umesto izvođenja kapaciteta iz oznake.** Za `1/3+1 STD`
  piše `4`. To je tačniji podatak nego bilo šta što `parse_room_code()` može da izvede.
- `-` u koloni pomoćnih ležaja znači nula.
- `*` iza cene je uslovan period, fusnota ispod tabele. Ali u `1/2 STD RENOV*` zvezdica
  je deo **imena strukture**, ne cene.
- Datumi nemaju crticu, pa `dates.parse_date_range()` neće raditi kao za soleazur.
  Ako dodaješ novi obrazac, ide u `normalize/dates.py` uz test, ne u adapter (pravilo 6).
- `discover()` treba listu URL-ova `/sr/putovanje/<slug>/<id>`. Sitemap nije proveren —
  proveri `oktopod.rs/sitemap.xml` pre nego što pišeš enumeraciju.

Isti postupak kao za soleazur: prvo testovi nad fixture-om, pa tek onda živi run.

## Odluke su donete, ne otvaraj ih ponovo

Primeni i drugi patch, `0001-Odluka-devet-blokiranih-izvora-trajno-van-opsega-bez.patch`.

**Devet blokiranih izvora je trajno van opsega** (`CLAUDE.md` pravilo 13, prepravljeno).
`bigblue.rs`, `fibula.rs`, `filiptravel.rs`, `odeontravel.rs`, `deustravel.rs`,
`feniks-tours.rs`, `vivatravel.rs`, `balkanviator.com`, `lasta.rs`.

Konkretno:

- ne pišu se adapteri za njih
- **ne šalju im se mejlovi** ni za dozvolu ni za feed; ne kontaktiramo ih uopšte
- **ne traže se zaobilazni putevi** — ni drugi poddomen, ni partnerski sajt koji
  preprodaje istu ponudu, ni preimenovanje bota

Princip projekta: koristi se samo ono do čega se dolazi **brzo i jednostavno, sa sajta
same agencije, uz njen pristanak izražen kroz `robots.txt`.** Sve ostalo se preskače.

To važi i za `lidertravel.rs` u delu gde poziva `putovanja.bigblue.rs/…/HotelPrices.aspx`.
Taj host ima sopstveni `robots.txt` koji `.aspx` **ne** zabranjuje, ali se po istom
principu ne koristi. Ako uopšte praviš adapter za Lidera, ograniči ga na `lidertravel.rs`
i na ono što je već u njegovom DOM-u (`HotelPrice_roomsPerHotel` daje tipove soba bez
ijednog poziva ka partnerskom hostu).

Ostaje **24 upotrebljiva izvora** od 33, realno **22** jer `maestral.co.rs` i
`aquatravel.rs` ne objavljuju cenovnik.

## Podsetnik na pravila koja su ovim dobila poklopac

`CLAUDE.md` §8 je dobio dva nova pravila iz ovih grešaka:

- **14.** `selectolax` `css("a, b")` ne vraća redosled dokumenta — koristi `traverse()`
- **15.** tabele sa `rowspan` se ne čitaju po fiksnom indeksu ćelije

Oba su tiho pogrešan rezultat, ne greška. Zato su u tvrdim pravilima.
