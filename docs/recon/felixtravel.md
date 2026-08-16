# Felix Travel — felixtravel.rs

Recon: 15.08.2026. · Pouzdanost: **low** · Težina: **3/5** · Dohvaćeno: **da**

> Generisano automatski iz recon izveštaja. Prijavljeno je samo ono što je agent stvarno
> video u dohvaćenom sadržaju. Prazno polje znači da nije provereno, **ne** da ne postoji.

## Platforma

**sopstveni CMS (custom PHP, direktorijumi /core/ /themes/ /cache/)**

robots.txt disallow: /core/, /themes/, /cache/ — tipično za samostalan/custom CMS, ne prepoznatljivo kao WordPress/Onesystem/TourVisio. Sitemap je HTML (site-map.html), ne XML.

## Pravni status

robots.txt dohvaćen: **ne**
Blokira nas: **ne**

```
User-agent: *; Disallow: /core/, /themes/, /cache/; Sitemap: https://www.felixtravel.rs/site-map.html
```

## Sitemap

- https://www.felixtravel.rs/site-map.html

## Renderovanje

**SSR/staticki HTML**

## URL-ovi liste

- https://www.felixtravel.rs/letovanje.html
- https://www.felixtravel.rs/letovanje-grcka.html
- https://www.felixtravel.rs/letovanje-crna-gora.html

## Šablon URL-a detalja

https://www.felixtravel.rs/letovanje-[destinacija](-[regija]).html ; pretraga: /search.html&s=<termin>

## Query parametri

- plp
- nlp
- dlp
- s
- page

## Paginacija

search.html&plp=<per_page>&nlp=&dlp=&s=<query>&page=<n> (viđeno u search rezultatima)

## Gde su podaci

_nije utvrđeno u ovom reconu_

## Primer tabele cena

**Nije nađen.** Bez doslovnog primera cenovnika adapter se ne može dovršiti — ovo je obavezan sledeći korak, lokalno.

## Tipovi proizvoda

- hotel
- paket aranžman

## Tipovi prevoza

- avio
- bus
- sopstveni prevoz

## Prepreke

- U dostupnom budžetu nije lociran konkretan hotel/cenovnik ni tabela po sobama (1/2, 1/2+1, 1/4) — landing i regionalne stranice su opisne, cene su verovatno dublje (per-hotel podstranica)
- Nema sitemap.xml, samo HTML mapa sajta — otežava enumeraciju URL-ova

## Napomene

_nije utvrđeno u ovom reconu_

## Proverene stranice

- firecrawl_search site:felixtravel.rs
- https://felixtravel.rs/robots.txt
- https://www.felixtravel.rs/letovanje-grcka.html
- https://www.felixtravel.rs/letovanje-grcka-halkidiki.html
