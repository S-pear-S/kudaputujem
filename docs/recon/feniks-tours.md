# feniks-tours — feniks-tours.rs

Recon: 15.08.2026. · Pouzdanost: **medium** · Težina: **5/5** · Dohvaćeno: **da**

> Generisano automatski iz recon izveštaja. Prijavljeno je samo ono što je agent stvarno
> video u dohvaćenom sadržaju. Prazno polje znači da nije provereno, **ne** da ne postoji.

## Platforma

**WordPress (AIOSEO)**

generator AIOSEO 4.3.8, /wp-content/ URLs

## Pravni status

robots.txt dohvaćen: **ne**
Blokira nas: **DA**

```
Content-Signal framework: search=yes, ai-train=no; ClaudeBot/GPTBot/Amazonbot Disallow: /
```

## Sitemap

_nema_

## Renderovanje

**SSR (WordPress, statican HTML)**

## URL-ovi liste

- https://www.feniks-tours.rs/category/letovanje/
- https://www.feniks-tours.rs/first-last-minute-popusti/

## Šablon URL-a detalja

https://www.feniks-tours.rs/<naziv-vile-destinacija>-leto/

## Query parametri

_nema_

## Paginacija

_nije utvrđeno u ovom reconu_

## Gde su podaci

_nije utvrđeno u ovom reconu_

## Primer tabele cena

**Nije nađen.** Bez doslovnog primera cenovnika adapter se ne može dovršiti — ovo je obavezan sledeći korak, lokalno.

## Tipovi proizvoda

- vila
- apartman

## Tipovi prevoza

- autobus
- sopstveni

## Prepreke

- robots.txt blokira poznate AI botove (ClaudeBot, GPTBot, Amazonbot) sa Disallow: / — generic scraper/httpx UA verovatno prolazi, ali treba proveriti UA politiku pre skrepovanja

## Napomene

Cenovnik na primeru vila-lazos stranice prikazan kao PNG slika (LAZOS-CENOVNIK-LETOVANJE-2026.png), ne kao HTML tabela — cene nisu masinski citljive na toj stranici. Neke druge stranice (first-last-minute-popusti) imaju tekstualne cene po regiji ali ne strukturisanu tabelu po sobama.

## Proverene stranice

- firecrawl_search site:feniks-tours.rs
- WebFetch robots.txt
- WebFetch /vila-lazos-olympic-beach-leto/
