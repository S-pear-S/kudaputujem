# Odeon Travel (Odeon World Travel) — odeontravel.rs

Recon: 15.08.2026. · Pouzdanost: **medium** · Težina: **5/5** · Dohvaćeno: **da**

> Generisano automatski iz recon izveštaja. Prijavljeno je samo ono što je agent stvarno
> video u dohvaćenom sadržaju. Prazno polje znači da nije provereno, **ne** da ne postoji.

## Platforma

**SaaS booking engine, JS templating (Vue/Angular-stil)**

/lokacija/krf/hotels vraća template: {{offer.rooms[0].roomName}}, {{offer.price.amount}} — isti obrazac kao filiptravel.rs. robots blokira *.asmx/*.ashx (ASP.NET web service). Nije nađen cms./b2c. poddomen.

## Pravni status

robots.txt dohvaćen: **ne**
Blokira nas: **DA**

```
Allow:*; Disallow: /*.asmx, /*.ashx; Sitemap: https://www.odeontravel.rs/Sitemap.xml
```

## Sitemap

- https://www.odeontravel.rs/Sitemap.xml

## Renderovanje

**client-side JS (SPA/XHR), markdown fetch ne vidi cene**

## URL-ovi liste

- https://www.odeontravel.rs/lokacija/grcka/
- https://www.odeontravel.rs/lokacija/turska/
- https://www.odeontravel.rs/stranica/leto-avionom/

## Šablon URL-a detalja

https://www.odeontravel.rs/lokacija/[destinacija]/hotels (npr. /lokacija/krf/hotels, /lokacija/rodos/hotels, /lokacija/krit/hotels, /lokacija/skijatos/hotels)

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
- paket aranžman

## Tipovi prevoza

- avio
- bus
- sopstveni prevoz

## Prepreke

- Cene i sobe učitavaju se JS-om (Vue/Angular template), WebFetch markdown ih ne prikazuje
- robots.txt blokira *.asmx i *.ashx — verovatan API/backend put je disallowed za crawlere
- Nije potvrđen cms./b2c. poddomen niti TourVisio brend u dostupnom sadržaju — treba proveriti network zahteve u browseru za potvrdu platforme

## Napomene

_nije utvrđeno u ovom reconu_

## Proverene stranice

- firecrawl_search site:odeontravel.rs
- https://odeontravel.rs/robots.txt
- https://www.odeontravel.rs/lokacija/grcka/
- https://www.odeontravel.rs/lokacija/krf/hotels
