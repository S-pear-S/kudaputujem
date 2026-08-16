# Filip Travel — filiptravel.rs

Recon: 15.08.2026. · Pouzdanost: **medium** · Težina: **5/5** · Dohvaćeno: **da**

> Generisano automatski iz recon izveštaja. Prijavljeno je samo ono što je agent stvarno
> video u dohvaćenom sadržaju. Prazno polje znači da nije provereno, **ne** da ne postoji.

## Platforma

**sopstveni/SaaS booking engine (nepoznato ime), Vue/Angular-stil templating**

Stranica hotela (/sr/hotel/...) vrađa neizrenderovan template kod: {{roomInfo.name}}, cene se ucitavaju JS-om posle izbora datuma/broja osoba. Isti obrazac templatinga viđen i na odeontravel.rs.

## Pravni status

robots.txt dohvaćen: **ne**
Blokira nas: **DA**

```
Crawl-delay: 30; Disallow: *.asmx, *.ashx, *.pdf, /b2cDocuments/, /sr/packages/, /sr/search-router/, /en/, PL= parametri, /[A-Z]/, */sr/tour/*; blokirani poddomeni white.filiptravel.rs i service.filiptravel.rs; Sitemap: https://www.filiptravel.rs/Sitemap.xml
```

## Sitemap

- https://www.filiptravel.rs/Sitemap.xml

## Renderovanje

**client-side JS (SPA/XHR), markdown fetch ne vidi cene**

## URL-ovi liste

- https://www.filiptravel.rs/sr/location/grcka/
- https://www.filiptravel.rs/sr/location/turska/
- https://www.filiptravel.rs/sr/stranica/letovanje/

## Šablon URL-a detalja

https://www.filiptravel.rs/sr/hotel/[destinacija]/[mesto]/[hotel-slug] ; rezultati pretrage: /sr/search-router/... (disallowed u robots)

## Query parametri

- PL=

## Paginacija

_nije utvrđeno u ovom reconu_

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

- Cene i tabele po sobama učitavaju se JS-om (XHR), WebFetch markdown ih ne prikazuje
- robots.txt disallow na /sr/search-router/ i /sr/tour/ (glavni putevi do konkretnih ponuda) i na *.asmx/*.ashx (verovatni API endpoint)
- Nije pronađen javni JSON endpoint u dostupnom budžetu poziva

## Napomene

_nije utvrđeno u ovom reconu_

## Proverene stranice

- firecrawl_search site:filiptravel.rs
- https://filiptravel.rs/robots.txt
- https://www.filiptravel.rs/sr/location/grcka/
- https://www.filiptravel.rs/sr/hotel/thassos/potos/hotel-potos
