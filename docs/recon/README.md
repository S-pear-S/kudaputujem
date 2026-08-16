# Recon srpskih travel sajtova

Stanje: **33 sajta profilisana.** Metod i format su u veštini `site-recon`.

Osnovno pravilo: prijavljeno je samo ono što je agent stvarno video u dohvaćenom sadržaju.
Prazno polje znači "nije provereno", **ne** "ne postoji". Nijedan CSS selektor nije potvrđen —
alat za dohvatanje vraća konvertovan markdown i selektori se gube. To se zatvara tek lokalno.

## Redosled pisanja adaptera

Rangirano po odnosu uloženog rada i dobijenih ponuda.

### Prvi talas — pisati odmah

| Sajt | Zašto | Težina |
|---|---|---|
| **soleazur.rs** | robots potpuno otvoren, ima `/lm/display_prices.php` koji vraća **strukturisanu tabelu** objekat/soba/cena. Najbolji nalaz celog recona. | 2 |
| **planatravel.rs** | WebKlik CMS, cenovnik u HTML-u, robots ok | 3 |
| **onlinetravel.rs** | WordPress, tabela cena u HTML-u (po terminu), sitemap postoji | 3 |
| **maestral.co.rs** | WordPress, sitemap index, **robots eksplicitno dozvoljava ClaudeBot** | 3 |
| **aquatravel.rs** | WordPress, uredan hijerarhijski URL, sitemap, velika ponuda | 3 |

### Drugi talas — SSR, treba dokopati cenovnik

`travelland.rs`, `felixtravel.rs`, `timtravel.rs`, `grandtours.rs`, `euroturs.rs`,
`magictravel.rs`, `amostravel.rs`, `rapsodytravel.rs`, `belvi.rs`, `lidertravel.rs`,
`hedonictravel.rs`, `sabra.rs`, `oktopod.rs`

Svi su SSR ili blizu toga. Kod većine cenovnik nije nađen u budžetu recona, ali nema dokaza da
je iza JS-a — samo nije pogođena prava stranica. Za ove se prvo dohvati jedna stranica hotela
lokalno, pa se odluči.

### Treći talas — teški

`1atravel.rs` (Onesystem), `kontiki.rs` (TourVisio), `olympic.rs`, `timetravel.rs` (CipeeCMS).
Kod svih je cena funkcija popunjenosti ili iza JS-a.

### Isključeni — robots.txt blokira skrepere

`bigblue.rs`, `fibula.rs`, `filiptravel.rs`, `odeontravel.rs`, `deustravel.rs`,
`feniks-tours.rs`, `vivatravel.rs`, `balkanviator.com`, `lasta.rs`

Vidi §Pravno.

## Nalazi koji menjaju plan

### 1. TourVisio je veći nego što smo mislili, ali je zatvoren

`filiptravel.rs` i `odeontravel.rs` vraćaju **neizrenderovan template kod** u HTML-u:
`{{offer.rooms[0].roomName}}`, `{{offer.price.amount}}`, `{{roomInfo.name}}`. Isti obrazac,
isti `Disallow: /*.asmx` i `/*.ashx`, iste `/sr/search-router/` rute kao Big Blue i Kon Tiki.

Dakle **četiri agencije na istom engine-u**: Big Blue, Kon Tiki, Filip Travel, Odeon Travel.
To bi bio najvredniji adapter na tržištu — ali sve četiri instalacije blokiraju baš one putanje
koje nose podatke. Filip Travel dodatno ima `Crawl-delay: 30` i zabranjuje `/sr/search-router/`
i `/sr/tour/`.

Zaključak: TourVisio grupa se **ne skrepuje**. Ako se ikada otvori, jedan adapter odjednom
pokriva četiri agencije — vredi im poslati mejl za feed.

### 2. Prava prilika su mali sajtovi, ne veliki

Suprotno očekivanju. Veliki lanci su na zatvorenim SaaS platformama sa dinamičkim cenama.
Male agencije drže ručne HTML cenovnike, imaju otvoren robots.txt i SSR. `soleazur.rs` ima
PHP endpoint koji vraća gotovu tabelu cena.

Sedam malih sajtova daje više upotrebljivih ponuda po uloženom satu nego jedan Big Blue.

### 3. Blokiranje AI botova je masovno

Devet od 33 sajta imaju `Disallow: /` za `ClaudeBot`, `GPTBot`, `CCBot` i slične. Većina koristi
Cloudflare "content-signal" politiku (`search=yes, ai-train=no`). Neki idu dalje i blokiraju
`Scrapy` (Fibula) ili SEO alate.

Suprotan primer: `maestral.co.rs` eksplicitno **dozvoljava** `ClaudeBot` i `anthropic-ai`.

## Pravno

Naš bot se zove `KudaPutujemBot` i **nije naveden ni na jednom spisku**. Po slovu Robots
Exclusion Protocol-a, pravilo za `ClaudeBot` se na nas ne odnosi.

Ali namera je nedvosmislena: sajt koji nabraja 40 skrepera i svima daje `Disallow: /` ne želi
automatizovan pristup. Preimenovati bota da bi se provukao kroz rupu u slovu pravila je isto
što i lažirati Chrome User-Agent — nešto što projekat izričito ne radi (`CLAUDE.md`, pravilo 7).

Zato: **devet blokiranih izvora ostaje isključeno dok vlasnik projekta ne odluči drugačije.**
Tri opcije po izvoru: preskočiti, poslati mejl za dozvolu ili XML feed, ili uključiti uz
pisano obrazloženje.

Poseban slučaj `bigblue.rs`: robots dozvoljava sve osim `.asmx` i `.ashx`. HTML stranice smemo,
njihove web servise ne. Praktično to znači da nam ostaje samo prazan SPA shell.

## Šta se ne može saznati iz oblaka

Isti zid u sve 33 runde:

- **XHR endpointi se ne vide** — potreban je pravi browser sa DevTools Network tabom
- **Sirov HTML se ne vidi** — dobija se konvertovan markdown, pa nestaju CSS selektori,
  `name=` atributi forme i `<script>` blokovi sa podacima
- Stranice sa punim setom query parametara često vraćaju 403 kroz proxy
- Cenovnik u obliku **slike** (`feniks-tours.rs` ima PNG cenovnik) ili PDF-a se ne čita

Zato ni jedan izveštaj nema potvrđene selektore, a samo šest ima primer tabele cena.

## Sledeći korak, lokalno

Za pet sajtova iz prvog talasa:

1. otvoriti stranicu hotela u Chrome-u, DevTools → Network → XHR, snimiti pozive
2. sačuvati sirov HTML kao fixture u `apps/scrapers/tests/fixtures/<slug>/`
3. tek onda pisati adapter

Za `soleazur.rs` prvo proveriti da li iza `/lm/display_prices.php` stoji JSON — ako da,
to je adapter za pola dana.

## Metod

Prva runda: 21 agent, opus, visok effort, prosečno 95k tokena po sajtu. Prekinuta na limitu.
Druga runda: 8 agenata, sonnet, nizak effort, ograničen budžet od 5 poziva alata po sajtu,
shema sa `maxLength` na svakom polju. **13k tokena po sajtu, sedam puta jeftinije.**

Pouka: skupo nije bilo istraživanje nego dužina odgovora. Agent koji sme da piše eseje piše eseje.
