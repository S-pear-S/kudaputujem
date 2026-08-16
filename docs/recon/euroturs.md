# euroturs — euroturs.rs

Recon: 15.08.2026. · Pouzdanost: **medium** · Težina: **3/5** · Dohvaćeno: **da**

> Generisano automatski iz recon izveštaja. Prijavljeno je samo ono što je agent stvarno
> video u dohvaćenom sadržaju. Prazno polje znači da nije provereno, **ne** da ne postoji.

## Platforma

**sopstveni/custom (nije identifikovan WP)**

nema WordPress markera u fetch-u detalj stranice

## Pravni status

robots.txt dohvaćen: **ne**
Blokira nas: **ne**

```
User-agent: * ; Disallow na: iframe parametre, partner booking redirect putanje, download sekcije, zastarele ponude, statican arhiv ponuda
```

## Sitemap

_nema_

## Renderovanje

**SSR**

## URL-ovi liste

- https://euroturs.rs/leto/
- https://euroturs.rs/leto/grcka/
- https://euroturs.rs/leto/grcka/grcka-apartmani/olimpska-regija/

## Šablon URL-a detalja

https://euroturs.rs/leto/grcka/grcka-apartmani/<regija>/<mesto>/

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

- autobus
- sopstveni
- avion

## Prepreke

_nema_

## Napomene

Na proverenoj stranici (nei-pori) cene su prikazane kao ukupne cene po osobi za aranzman ('od 88 €'), bez eksplicitne tabele po tipu sobe (1/2, 1/4). Moguce da se struktura po sobama dobija tek na detalju konkretnog objekta koji nije proveren zbog budzeta.

## Proverene stranice

- firecrawl_search site:euroturs.rs
- WebFetch robots.txt
- WebFetch /leto/grcka/grcka-apartmani/olimpska-regija/nei-pori/
