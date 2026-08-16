# Travelland — travelland.rs

Recon: 15.08.2026. · Pouzdanost: **medium** · Težina: **3/5** · Dohvaćeno: **da**

> Generisano automatski iz recon izveštaja. Prijavljeno je samo ono što je agent stvarno
> video u dohvaćenom sadržaju. Prazno polje znači da nije provereno, **ne** da ne postoji.

## Platforma

**WordPress**

meta generator: WordPress 6.1.1; robots.txt ima Yoast SEO blok

## Pravni status

robots.txt dohvaćen: **ne**
Blokira nas: **ne**

```
User-agent: *
Disallow:

Sitemap: https://www.travelland.rs/sitemap_index.xml
```

## Sitemap

- https://www.travelland.rs/sitemap_index.xml

## Renderovanje

**nejasno, moguce JS/AJAX**

## URL-ovi liste

- https://www.travelland.rs/destinacije/grcka/letovanje/
- https://www.travelland.rs/letovanje/
- https://www.travelland.rs/destinacije/grcka/letovanje/hoteli/halkidiki/

## Šablon URL-a detalja

https://www.travelland.rs/destinacije/[drzava]/[tip]/.../[region]/ hijerarhijski; tacan URL pojedinacnog hotela nije pronadjen

## Query parametri

_nema_

## Paginacija

_nije utvrđeno u ovom reconu_

## Gde su podaci

_nije utvrđeno u ovom reconu_

## Primer tabele cena

**Nije nađen.** Bez doslovnog primera cenovnika adapter se ne može dovršiti — ovo je obavezan sledeći korak, lokalno.

## Tipovi proizvoda

- hotel

## Tipovi prevoza

- avion
- autobus

## Prepreke

- Nije pronadjen konkretan URL pojedinacne hotelske detalj-stranice (budzet potrosen)
- Cene vidjene samo u search snippet-ima (npr Hotel Hydra Beach Resort), ne u punom WebFetch sadrzaju - moguce JS/AJAX ucitavanje

## Napomene

_nije utvrđeno u ovom reconu_

## Proverene stranice

- firecrawl_search site:travelland.rs
- WebFetch robots.txt
- WebFetch /destinacije/grcka/letovanje/
- WebFetch /destinacije/grcka/letovanje/hoteli/halkidiki/
