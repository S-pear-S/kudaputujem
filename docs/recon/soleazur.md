# soleazur — soleazur.rs

Recon: 15.08.2026. · Pouzdanost: **high** · Težina: **2/5** · Dohvaćeno: **da**

> Generisano automatski iz recon izveštaja. Prijavljeno je samo ono što je agent stvarno
> video u dohvaćenom sadržaju. Prazno polje znači da nije provereno, **ne** da ne postoji.

## Platforma

**sopstveni/custom (PHP)**

endpoint /lm/display_prices.php, .php ekstenzija

## Pravni status

robots.txt dohvaćen: **ne**
Blokira nas: **ne**

```
User-agent: * ; Disallow: (prazno — sve dozvoljeno)
```

## Sitemap

_nema_

## Renderovanje

**SSR + PHP endpoint sa cenovnom tabelom**

## URL-ovi liste

- https://soleazur.rs/grcka-hoteli
- https://soleazur.rs/grcka-apartmani
- https://soleazur.rs/last-minute-grcka

## Šablon URL-a detalja

https://soleazur.rs/<mesto-ili-region>-apartmani ; https://soleazur.rs/lm/display_prices.php (cenovni endpoint)

## Query parametri

_nema_

## Paginacija

_nije utvrđeno u ovom reconu_

## Gde su podaci

_nije utvrđeno u ovom reconu_

## Primer tabele cena

```
| Objekat | Soba | 11 dana/10 noci... |
|---------|------|------------------|
| Ridos house | Studio 1/3+1 | 209€ (235€) / 275€ (305€) |
```

## Tipovi proizvoda

- hotel
- apartman
- studio

## Tipovi prevoza

- sopstveni
- autobus
- avion

## Prepreke

_nema_

## Napomene

Robots.txt potpuno otvoren. display_prices.php vraca strukturisanu tabelu (objekat/soba/cena) sto je dobar znak za nizak difficulty — vredi ispitati da li je pravi JSON/AJAX endpoint iza njega u sledecem koraku (Network tab).

## Proverene stranice

- firecrawl_search site:soleazur.rs
- WebFetch robots.txt
- WebFetch /last-minute-grcka
- WebFetch /lm/display_prices.php


---

## Dopuna 16.08.2026. — fixture i adapter

Fixture: `apps/scrapers/tests/fixtures/soleazur/display_prices.html`, snimljen iz DOM-a.
Adapter: `apps/scrapers/src/travelscrape/adapters/soleazur.py`, 19 testova nad fixture-om.

Strukturni detalji koje naivni parser promaši:

- **`rowspan` na imenu objekta.** Redovi posle prvog imaju jednu ćeliju MANJE.
  Čitanje `cells[0]` kao objekta na tim redovima pročita sobu, a kao sobu — cenu.
- **Ime objekta je u `<h6><a>` unutar `td[rowspan]`**, nije goli tekst ćelije.
- **Broj prevoza po koloni nije konstantan.** Halkidiki: `Sopstveni prevoz/Bus prevoz`
  (dve cene, razdvojene sa `/`). Kefalonija: kolone samo `Avio prevoz` (jedna cena, bez `/`).
- **Različito trajanje po koloni** u istoj tabeli: `11 dana/10 noci` i `12 dana/11 noci`.
- **`619€ (585€)`** — puna cena niža od akcijske. Greška u podacima na sajtu, javlja se.
  Ne pretpostavljati `original > amount`.
- **`h2` je destinacija, `h6` je hotel.** `css("h2, table")` u selectolax NE vraća redosled
  dokumenta nego prvo sve `h2` pa sve `table`; mora `root.traverse()`.

Jedna agencijska ponuda se deli na dve naše (`__own`, `__bus`) jer `departure` ima
UNIQUE `(offer_id, start_date, end_date, departure_place_raw)` bez `transport_type`.
