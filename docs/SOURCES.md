# Katalog izvora

> **Odluka 16.08.2026.** Devet izvora čiji `robots.txt` blokira skrepere je **trajno van
> opsega**: `bigblue.rs`, `fibula.rs`, `filiptravel.rs`, `odeontravel.rs`, `deustravel.rs`,
> `feniks-tours.rs`, `vivatravel.rs`, `balkanviator.com`, `lasta.rs`.
> Ne pišu se adapteri, **ne šalju im se mejlovi**, ne traže se zaobilazni putevi.
> Projekat koristi samo ono do čega se dolazi jednostavno i sa sajta same agencije.
> Lista se može revidirati kad sajt poraste; do tada se ne dira.

Status: **recon završen za 33 sajta** — vidi [docs/recon/](recon/README.md). Kolone `robots` i `ToS` se popunjavaju tek posle ručne provere, i izvor se
ne uključuje dok obe nisu zelene.

## Najvažniji nalaz recona: grupisati po PLATFORMI, ne po agenciji

Srpsko tržište nema 200 različitih sajtova. Ima **nekoliko rezervacionih platformi** koje agencije
kupuju kao gotov proizvod, i onda šaku samostalnih WordPress sajtova. Jedan adapter po platformi
pokriva 5-15 agencija odjednom.

| Platforma | Prepoznaje se po | Agencije (potvrđeno reconom) | Prioritet |
|---|---|---|---|
| **Onesystem** (Joy Group, Beograd) | `onesystem-powered.png` u footeru, WP tema `onesystem_wp_theme`, sitemap na `admin-ajax.php?action=os_sitemap`, DB prefiks `onesystem_` | 1A Travel — potvrđeno | 3 (nema cenovnik u HTML-u) |
| ~~**TourVisio B2C**~~ (SAN Tourism Software Group) | `Disallow: /*.asmx` i `/*.ashx` u robots.txt, `/sr/search-router/`, neizrenderovan template kod (`{{offer.price.amount}}`) | Big Blue, Kon Tiki, Filip Travel, Odeon Travel — **sve četiri ISKLJUČENE**, blokiraju baš putanje sa podacima | — |
| ~~**Fibula sopstveni**~~ | SPA + inventar iz **Peakwork** huba, cene dinamičke po upitu | Fibula Air Travel — **ISKLJUČENA**, robots.txt blokira skrepere uključujući Scrapy | — |
| **cloudhosting.rs multi-tenant** | `vs<broj>.cloudhosting.rs/<Destinacija>?prevoz=autobus&sort=1&page=N` | Oktopod Travel | 2 |
| **WordPress + ručne HTML tabele cena** | `wp-content`, tabela sa datumima polaska u zaglavlju i `1/2`, `1/3`, `1/4` redovima | Feniks Tours (isključen, robots), Plana Travel, Euroturs, Vivatravel (isključen, robots) | 1 |
| **Sopstveni CMS** | — | Travelland, Aqua Travel, Felix Travel, Tim Travel, Sabra, Grand Tours, Deus Travel (isključen, robots), Lider Travel, Belvi, Olympic, Sole Azur, Amos, Hedonic, Magic Travel, Maestral, Rapsody, Online Travel, Time Travel | 1–3, vidi `docs/recon/README.md` |

### Šta ovo menja u planu

Pretpostavka "prvo velike platforme" je **opovrgnuta** reconom od 33 sajta. Velike agencije jesu
na zajedničkim platformama, ali su te platforme zatvorene za skrepovanje:

1. **TourVisio grupa (4 agencije) je zatvorena.** Big Blue, Kon Tiki, Filip Travel i Odeon Travel
   dele isti engine, ali robots.txt kod sve četiri blokira `.asmx`/`.ashx` i `/sr/search-router/` —
   baš putanje koje nose cene. Ne piše se adapter dok se ne otvori (npr. dogovorom o feedu).
2. **Onesystem (1A Travel) je potvrđen, ali ide u treći talas.** Nema tabelu cena u HTML-u — cena
   je funkcija popunjenosti, dobija se tek parametrizovanom pretragom. Vidi CLAUDE.md §4.4b.
3. **Prava prilika su mali sajtovi sa ručnim HTML cenovnicima i otvorenim robots.txt.** `soleazur.rs`
   ima PHP endpoint koji vraća gotovu tabelu cena — najbolji nalaz recona, prvi napisani adapter.
4. **Devet sajtova blokira skrepere u robots.txt** (uključujući ClaudeBot eksplicitno) i ostaje
   isključeno dok kruska ne odluči drugačije — vidi CLAUDE.md pravilo 13 i `docs/recon/README.md`.

## Kandidati — aranžmani (PACKAGE)

| Agencija | Domen | Platforma | Tip ponude | robots | ToS | Status |
|---|---|---|---|---|---|---|
| Big Blue | bigblue.rs | TourVisio | bus, avio, sopstveni, ture | ✗ blokira | ? | **isključen** |
| Kon Tiki | kontiki.rs | TourVisio | avio, sopstveni, ture, daleke | ✗ blokira | ? | talas 3 |
| 1A Travel | 1atravel.rs | Onesystem | avio (čarter) | dozvoljava | ? | talas 3 |
| Fibula Air Travel | fibula.rs | sopstvena (Peakwork) | avio (čarter), sopstveni | ✗ blokira | ? | **isključen** |
| Travelland | travelland.rs | sopstveni CMS | avio, sopstveni, ture | ? | ? | talas 2 |
| Aqua Travel | aquatravel.rs | sopstveni CMS (WordPress) | bus, avio, sopstveni | dozvoljava | ? | talas 1 |
| Filip Travel | filiptravel.rs | TourVisio | bus, avio | ✗ blokira | ? | **isključen** |
| Oktopod Travel | oktopod.rs | cloudhosting | bus, sopstveni | ? | ? | talas 2 |
| Felix Travel | felixtravel.rs | sopstveni CMS | bus, avio | ? | ? | talas 2 |
| Tim Travel | timtravel.rs | sopstveni CMS | bus, sopstveni | ? | ? | talas 2 |
| Sabra Travel | sabra.rs | sopstveni CMS | bus, avio | ? | ? | talas 2 |
| Grand Tours | grandtours.rs | sopstveni CMS | bus, sopstveni | ? | ? | talas 2 |
| Deus Travel | deustravel.rs | WordPress + Elementor | sopstveni (Grčka) | ✗ blokira | ? | **isključen** |
| Lider Travel | lidertravel.rs | sopstveni CMS | avio, bus | ? | ? | talas 2 |
| Belvi Travel | belvi.rs | WordPress + WPBakery | avio, bus | ? | ? | talas 2 |
| Olympic | olympic.rs | sopstveni CMS | bus, avio | ? | ? | talas 3 |
| Plana Travel | planatravel.rs | WebKlik CMS | bus, sopstveni | dozvoljava | ? | talas 1 |
| Feniks Tours | feniks-tours.rs | WordPress (AIOSEO) | bus, sopstveni | ✗ blokira | ? | **isključen** |
| Euroturs | euroturs.rs | sopstveni/custom | bus, sopstveni | dozvoljava | ? | talas 2 |
| Viva Travel | vivatravel.rs | WordPress | bus, avio | ✗ blokira | ? | **isključen** |
| Sole Azur | soleazur.rs | sopstveni CMS | bus | dozvoljava | ? | **gotov adapter** |
| Amos Travel | amostravel.rs | WordPress | bus, sopstveni | ? | ? | talas 2 |
| Hedonic Travel | hedonictravel.rs | sopstveni CMS | bus, avio, sopstveni | ? (nedohvaćen) | ? | talas 2 |
| Odeon Travel | odeontravel.rs | TourVisio | avio, bus | ✗ blokira | ? | **isključen** |
| Argus Tours | argus.rs | sopstveni CMS | bus, transferi | ? | ? | nije reconovan |
| Magic Travel | magictravel.rs | sopstveni CMS | avio, bus | ? | ? | talas 2 |
| Maestral | maestral.co.rs | WordPress | bus, izleti | dozvoljava (eksplicitno ClaudeBot) | ? | talas 1 |
| Rapsody Travel | rapsodytravel.rs | sopstveni CMS | avio, mladi | ? | ? | talas 2 |
| Time Travel | timetravel.rs | sopstveni CMS (CipeeCMS) | bus, avio | ? | ? | talas 3 |
| Online Travel | onlinetravel.rs | WordPress | mešano | ? | ? | talas 1 |

## Kandidati — samo prevoz (TRANSPORT)

| Izvor | Domen | Napomena |
|---|---|---|
| Polazak | polazak.rs | prodaja autobuskih karata, ima strukturisanu pretragu po relaciji i datumu |
| BalkanViator | balkanviator.com | red vožnje + karte, regionalno pokrivanje — **isključen**, robots.txt blokira ClaudeBot |
| Red vožnje | redvoznje.net | samo red vožnje, bez cena |
| Teroplan | teroplan.rs | isti vlasnik kao BalkanViator/Vollo, moguć partnerski pristup |
| FlixBus | flixbus.rs | ima javni GTFS i partnerski program |
| Lasta | lasta.rs | domaći i međunarodni linijski prevoz — **isključen**, robots.txt blokira ClaudeBot |
| Niš Ekspres | nis-ekspres.rs | jug Srbije |
| Air Serbia | airserbia.com | avio, ToS verovatno zabranjuje skreping — ide preko partnerskog programa ili nikako |
| Srbijavoz | srbijavoz.rs | voz |

## Kandidati — samo smeštaj (ACCOMMODATION)

Domaći smeštaj (Zlatibor, Kopaonik, banje, Vojvodina) je slabo pokriven agencijskim sajtovima i
uglavnom se prodaje direktno. Kandidati:

| Izvor | Domen | Napomena |
|---|---|---|
| Deus Travel | deustravel.rs | grčki hoteli bez prevoza, već ima pretragu po hotelu i datumu |
| Kon Tiki / Big Blue | — | imaju "Smeštaj (sopstveni prevoz)" tab, isti adapter |
| Travelland | travelland.rs | tab "Smeštaj (sopstveni prevoz)" |
| Booking.com, Airbnb | — | **ne skrepujemo.** ToS izričito zabranjuje. Ako zatreba, partnerski API |

## Postojeća konkurencija (za analizu, ne za skreping)

| Sajt | Šta radi | Šta im nedostaje |
|---|---|---|
| travelist.rs | direktorijum agencija + članci | nema pretragu ponuda po datumu i broju osoba |
| putujsigurno.rs | direktorijum + provera licenci | isto |
| aquatravel.rs | agencija koja se ponaša kao agregator (sub-agent login) | prikazuje samo svoju ponudu |

Nijedan od njih ne radi ono što mi planiramo: **pretragu preko svih agencija po datumu, broju
putnika i rasporedu po sobama.** To je slobodan prostor.

## Postupak pre uključivanja izvora

1. `travelscrape recon <url>` → `docs/recon/<slug>.md`
2. Ručno pročitati `robots.txt` i Uslove korišćenja; upisati datum provere u ovu tabelu
3. Ako ToS zabranjuje automatizovan pristup → poslati mejl za dozvolu/feed, izvor ostaje isključen
4. Napisati adapter (vidi `travel-scraping` veštinu)
5. Fixture test
6. `travelscrape run <slug> --limit 20 --dry-run --explain`
7. Uključiti izvor sa `crawl_delay_ms >= 2000`
