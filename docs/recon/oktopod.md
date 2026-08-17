# Oktopod Travel — oktopod.rs

Recon: 15.08.2026. · Pouzdanost: **low** · Težina: **4/5** · Dohvaćeno: **da**

> Generisano automatski iz recon izveštaja. Prijavljeno je samo ono što je agent stvarno
> video u dohvaćenom sadržaju. Prazno polje znači da nije provereno, **ne** da ne postoji.

## Platforma

****

Nije utvrdjeno; korisnik pomenuo proveriti vs1536.cloudhosting.rs kao deljenu platformu/hosting - nije provereno (budzet potrosen)

## Pravni status

robots.txt dohvaćen: **ne**
Blokira nas: **ne**

_robots.txt nije dohvaćen — proveriti lokalno pre uključivanja izvora._

## Sitemap

_nema_

## Renderovanje

**nejasno**

## URL-ovi liste

- https://www.oktopod.rs/sr/grcka-apartmani/4
- https://www.oktopod.rs/sr/grcka-hoteli/10

## Šablon URL-a detalja

https://www.oktopod.rs/sr/putovanje/[naziv-slug]/[ID]

## Query parametri

_nema_

## Paginacija

_nije utvrđeno u ovom reconu_

## Gde su podaci

_nije utvrđeno u ovom reconu_

## Primer tabele cena

**Nije nađen.** Bez doslovnog primera cenovnika adapter se ne može dovršiti — ovo je obavezan sledeći korak, lokalno.

## Tipovi proizvoda

- apartman
- hotel

## Tipovi prevoza

_nema_

## Prepreke

- robots.txt nije nadjen na www.oktopod.rs ni na oktopod.rs (404 oba puta)
- Cene se ne vide u WebFetch markdown izlazu ni na listing ni na detail stranici (vila-penny-hanioti/8339)
- vs1536.cloudhosting.rs alternativa nije provereno u ovoj rundi

## Napomene

_nije utvrđeno u ovom reconu_

## Proverene stranice

- firecrawl_search site:oktopod.rs
- WebFetch www.oktopod.rs/robots.txt (404)
- WebFetch oktopod.rs/robots.txt (404)
- WebFetch /sr/nei-pori/453
- WebFetch /sr/putovanje/vila-penny-hanioti/8339


---

## Dopuna 16.08.2026. — fixture snimljen

Fixture: `apps/scrapers/tests/fixtures/oktopod/putovanje_vila_penny.html`
Izvor: `https://www.oktopod.rs/sr/putovanje/vila-penny-hanioti/8339`

**Ispravka ranijeg nalaza:** dve `table.CSSTableGenerator` na stranici NISU dva prevoza
nego dve DUŽINE boravka — 10 noći i 7 noći. Obe nose naslov
`PAKET ARANŽMAN (apartmanski smeštaj i autobuski prevoz)`, dakle obe su BUS.
Cena za sopstveni prevoz se ne objavljuje u tabeli; dobija se kroz formu
(`Tip prevoza: Agencijski prevoz (autobus) / Sopstveni prevoz`).

Oblik tabele:

```
red 0   <td colspan=N> naslov paketa
red 1   <td rowspan=3>Struktura</td> <td rowspan=3>Broj pomoćnih ležaja</td>
        <td rowspan=3>Broj plativih osoba</td> <td colspan=M>PERIOD BORAVKA / BROJ NOĆENJA</td>
red 2   broj noćenja po periodu
red 3   datumi, oblik "20.05. 30.05." — dva datuma, BEZ crtice između
red 4+  struktura, pomoćni ležaji, plative osobe, pa cena po periodu
```

**`Broj plativih osoba` je najvredniji podatak na celom sajtu.** Za `1/3+1 STD` piše `4`,
što znači da se cena množi sa 4. Kapacitet se ne mora izvoditi iz oznake sobe —
agencija ga je već objavila.

Ostalo: `-` u koloni pomoćnih ležaja znači nula; `*` iza cene je uslovan period
(fusnota ispod tabele); `1/2 STD RENOV*` — tu je zvezdica deo imena strukture, ne cene.
