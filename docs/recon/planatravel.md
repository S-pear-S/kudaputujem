# Plan A Travel — planatravel.rs

Recon: 15.08.2026. · Pouzdanost: **medium** · Težina: **3/5** · Dohvaćeno: **da**

> Generisano automatski iz recon izveštaja. Prijavljeno je samo ono što je agent stvarno
> video u dohvaćenom sadržaju. Prazno polje znači da nije provereno, **ne** da ne postoji.

## Platforma

**WebKlik (meta generator "WebKlik")**

meta generator tag: WebKlik

## Pravni status

robots.txt dohvaćen: **ne**
Blokira nas: **ne**

```
Joomla-stil robots.txt (napomena: sitemap referiše www.planatours.rs, moguć alias/rebrand domena); blokirano /administrator/, /api/, /bin/, /cache/, /cli/, /components/, /includes/, /installation/, /language/, /layouts/, /libraries/, /logs/, /media/, /modules/, /plugins/, /tmp/; dozvoljeni statički fajlovi (.js/.css/.png/.jpg/.gif/.webp); Sitemap: https://www.planatours.rs/sitemap.xml
```

## Sitemap

- https://www.planatours.rs/sitemap.xml

## Renderovanje

**SSR HTML, cenovnik na stranici kao lista**

## URL-ovi liste

- https://www.planatravel.rs/letovanje.html
- https://www.planatravel.rs/letovanje/grcka.html
- https://www.planatravel.rs/letovanje/grcka/jonska-regija.html

## Šablon URL-a detalja

https://www.planatravel.rs/letovanje/<zemlja>/<regija>.html (regionalna stranica sa više vila/hotela i cena po terminu, ne odvojena stranica po hotelu)

## Query parametri

_nema_

## Paginacija

nepoznato, izgleda kao statička hijerarhija zemlja/regija

## Gde su podaci

_nije utvrđeno u ovom reconu_

## Primer tabele cena

```
15.08 – 25.08.2026: Parga Vila Limona: St. 1/2 -325€; Vrachos Vila Filoxenia: St. 1/2 -275€; 1/3 -215€; Sivota Vila Ionion: St. 1/2 -325€ | 25.08 – 04.09.2026: Parga Vila Limona: St. 1/2 -295€; 1/3 -235€
```

## Tipovi proizvoda

- PACKAGE

## Tipovi prevoza

- BUS
- OWN

## Prepreke

- Napomena: sitemap URL upućuje na drugi domen (planatours.rs) — proveriti da li je to redirect/isti sajt pre pisanja adaptera
- Nejasno da li postoji odvojena stranica po hotelu ili je sve na jednoj regionalnoj stranici (uticaj na external_id stabilnost)

## Napomene

_nije utvrđeno u ovom reconu_

## Proverene stranice

- firecrawl_search site:planatravel.rs
- https://www.planatravel.rs/robots.txt
- https://www.planatravel.rs/letovanje/grcka/jonska-regija.html
