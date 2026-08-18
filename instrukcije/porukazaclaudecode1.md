# Poruka za Claude Code

Kopiraj sve ispod crte u terminal.

---

Tri stvari sa moje strane.

## 0. Bug u `scrape()` je moj

`parse_price_page(html: str)` je dobijao ceo `httpx.Response`, a `HttpFetcher.get()`
vraća `Response`, ne string. Treba `resp.text`. Ti si to dobro uočio, greška je moja.
Popravi na tom jednom mestu, ne diraj potpis `parse_price_page`.

## 1. Oktopod: valuta je EUR, potvrđeno

U zaglavlju sajta stoji kurs `1€ = 117.34 RSD`. Sve cene u cenovnim tabelama su **EUR**.
Nemoj ih tretirati kao RSD i nemoj ih konvertovati.

Uz to, na detalj stranici postoji stavka:

```
AC - uz doplatu na licu mesta od 6€ dnevno
```

To nije deo cene aranžmana nego doplata. Ide kao `surcharge`:

- `payable = ON_SITE`
- `pricing_basis = PER_UNIT_PER_NIGHT`
- `currency = EUR`
- `amount = 6`

## 2. Oktopod: `discover()` ide preko sitemap-a

`https://www.oktopod.rs/sitemap.xml` postoji i ima **1427** `<loc>` unosa,
od kojih je **1093** oblika `/sr/putovanje/<slug>/<id>`.

To je ceo katalog. Prepiši `discover()` da čita sitemap i filtrira po tom obrascu.
Izbaci generičku ekstrakciju linkova sa listing stranica — nije potrebna i pravi
nepotreban saobraćaj ka sajtu.

## 3. Oktopod: broj na kraju URL-a nije paginacija

Proverio sam u browseru. Broj na kraju kategorijskih URL-ova je **ID kategorije**:

```
/sr/leto-2026/1
/sr/grcka-apartmani/4
/sr/stavros/34
/sr/rimini/811
/sr/italija/782
```

Ne piši petlju koja inkrementira taj broj. Nema stranu 2.

## 4. Python 3.12 je instaliran, venv je aktivan

Okruženje je sređeno sa moje strane. Pokreni `pytest` ponovo u aktivnom venv-u
i javi rezultat. Očekivanje: 19 soleazur testova prolazi, ceo paket prolazi, `ruff` čist.

`strict=False` u `zip()` ostaje netaknut. On nije bio problem — problem je bio
Python 3.8. Nemoj spuštati sintaksu na niže verzije.

Upiši u `CLAUDE.md` §9 (poznati problemi):

- projekat se od sada pokreće na Python 3.12 u venv-u
- „prolazi na 3.8" nije bio dokaz ispravnosti nego posledica pogrešnog interpretera
- pre prijavljivanja rezultata testova, proveri `python --version`

## 5. grandtours fixture

Radim na njemu. Chrome ekstenzija još nema dozvolu za taj domen, pa kasni.
Nemoj čekati — kreni na oktopod adapter po prethodnim instrukcijama.
