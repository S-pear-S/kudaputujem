# Olympic Travel — olympic.rs

Recon: 15.08.2026. · Pouzdanost: **medium** · Težina: **5/5** · Dohvaćeno: **da**

> Generisano automatski iz recon izveštaja. Prijavljeno je samo ono što je agent stvarno
> video u dohvaćenom sadržaju. Prazno polje znači da nije provereno, **ne** da ne postoji.

## Platforma

**custom booking engine (nepotvrđeno ime, možda TourVisio)**

detalj URL sadrži numerički ID paketa u query stringu, npr. 255782059-2026-09-02-2026-09-09-1-1, i dateFrom/dateTo/dynamicPackage parametre; listing generator = Yoast SEO

## Pravni status

robots.txt dohvaćen: **ne**
Blokira nas: **ne**

```
User-agent: * / Disallow: (prazno, sve dozvoljeno); Sitemap: https://www.olympic.rs/sitemap_index.xml; Yoast SEO format
```

## Sitemap

- https://www.olympic.rs/sitemap_index.xml

## Renderovanje

**listing SSR, cena na detalju tek kroz JS pretragu**

## URL-ovi liste

- https://www.olympic.rs/letovanje/
- https://www.olympic.rs/letovanje/grcka-promotivne-cene/
- https://www.olympic.rs/letovanje/kipar/

## Šablon URL-a detalja

https://www.olympic.rs/letovanje/<zemlja>/<mesto>/<hotel-slug>/<numericki-id>/

## Query parametri

- dateFrom
- dateTo
- dynamicPackage

## Paginacija

kategorija po zemlji/mestu, listing kartice sa linkovima na detalj

## Gde su podaci

_nije utvrđeno u ovom reconu_

## Primer tabele cena

**Nije nađen.** Bez doslovnog primera cenovnika adapter se ne može dovršiti — ovo je obavezan sledeći korak, lokalno.

## Tipovi proizvoda

- PACKAGE

## Tipovi prevoza

- AVIO
- BUS

## Prepreke

- Cena po sobi/terminu se dobija tek kroz JS pretragu/kalendar dostupnosti, nema statičke tabele
- Moguće da postoji XHR endpoint iza kalendara — vredi proveriti Network tab pre Playwright pristupa

## Napomene

_nije utvrđeno u ovom reconu_

## Proverene stranice

- firecrawl_search site:olympic.rs
- https://www.olympic.rs/robots.txt
- https://www.olympic.rs/letovanje/grcka/uranopolis/hotel-eagles-palace-small-luxury-hotels-of-the-world/114075/
