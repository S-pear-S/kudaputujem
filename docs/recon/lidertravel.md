# Lider Travel — lidertravel.rs

Recon: 15.08.2026. · Pouzdanost: **medium** · Težina: **4/5** · Dohvaćeno: **da**

> Generisano automatski iz recon izveštaja. Prijavljeno je samo ono što je agent stvarno
> video u dohvaćenom sadržaju. Prazno polje znači da nije provereno, **ne** da ne postoji.

## Platforma

**WordPress (custom tema "SunTour")**

wp-content/themes/SunTour/, wp-content/uploads/

## Pravni status

robots.txt dohvaćen: **ne**
Blokira nas: **ne**

```
Cloudflare content-signal politika: "search=yes,ai-train=no,use=reference"; eksplicitan Disallow za ClaudeBot/GPTBot/Amazonbot i sl. AI botove; generic User-agent nije blokiran.
```

## Sitemap

_nema_

## Renderovanje

**SSR HTML, cenovnik verovatno iza AJAX/dropdown**

## URL-ovi liste

- https://lidertravel.rs/putovanja/letovanje/
- https://lidertravel.rs/nea-vrasna-grcka-letovanje/

## Šablon URL-a detalja

https://lidertravel.rs/<destinacija>-letovanje/ (jedna stranica po destinaciji/hotelu, ne po hotel-ID)

## Query parametri

_nema_

## Paginacija

kategorija/mesec arhive: /putovanja/<mesec>/page/N/

## Gde su podaci

_nije utvrđeno u ovom reconu_

## Primer tabele cena

**Nije nađen.** Bez doslovnog primera cenovnika adapter se ne može dovršiti — ovo je obavezan sledeći korak, lokalno.

## Tipovi proizvoda

- PACKAGE

## Tipovi prevoza

- BUS
- AVIO
- OWN

## Prepreke

- Cene po sobi/terminu učitane dinamički, nisu vidljive u statičkom HTML-u (WebFetch)
- Content-signal politika izričito zabranjuje AI-train, proveriti pravni rizik pre uključivanja

## Napomene

_nije utvrđeno u ovom reconu_

## Proverene stranice

- firecrawl_search site:lidertravel.rs
- https://lidertravel.rs/robots.txt
- https://lidertravel.rs/nea-vrasna-grcka-letovanje/
