# vivatravel — vivatravel.rs

Recon: 15.08.2026. · Pouzdanost: **medium** · Težina: **5/5** · Dohvaćeno: **da**

> Generisano automatski iz recon izveštaja. Prijavljeno je samo ono što je agent stvarno
> video u dohvaćenom sadržaju. Prazno polje znači da nije provereno, **ne** da ne postoji.

## Platforma

**WordPress 6.4.3**

meta generator WordPress 6.4.3, GTM-TC3BF95R

## Pravni status

robots.txt dohvaćen: **ne**
Blokira nas: **DA**

```
Cloudflare managed content-signal (search=yes, ai-train=no) ALI odvojen Yoast blok sa 'Disallow:' bez putanje (prazno = dozvoljeno), plus eksplicitni Disallow: / za ClaudeBot/GPTBot/Amazonbot i druge AI agente
```

## Sitemap

_nema_

## Renderovanje

**SSR + verovatno XHR/AJAX za cene**

## URL-ovi liste

- https://www.vivatravel.rs/letovanje/grcka/
- https://www.vivatravel.rs/last-minute/

## Šablon URL-a detalja

https://www.vivatravel.rs/letovanje/grcka/<hotel-ili-destinacija>/

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
- apartman

## Tipovi prevoza

- avion
- autobus
- sopstveni

## Prepreke

- Eksplicitni Disallow: / za AI crawlere (ClaudeBot i drugi) u robots.txt — konfliktan fajl (Cloudflare blok vs Yoast blok), treba proveriti pre skrepovanja generic UA-om

## Napomene

Provereni detalj (skijatos-avion) nema statican cenovnik u HTML-u — samo forma za pretragu; cene se verovatno ucitavaju XHR pozivom nakon interakcije. Trazi network inspekciju za pravi endpoint.

## Proverene stranice

- firecrawl_search site:vivatravel.rs
- WebFetch robots.txt
- WebFetch /letovanje/grcka/skijatos-avion/
