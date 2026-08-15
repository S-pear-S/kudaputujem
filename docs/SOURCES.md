# Katalog izvora

Status: **recon faza**. Kolone `robots` i `ToS` se popunjavaju tek posle ručne provere, i izvor se
ne uključuje dok obe nisu zelene.

## Najvažniji nalaz recona: grupisati po PLATFORMI, ne po agenciji

Srpsko tržište nema 200 različitih sajtova. Ima **nekoliko rezervacionih platformi** koje agencije
kupuju kao gotov proizvod, i onda šaku samostalnih WordPress sajtova. Jedan adapter po platformi
pokriva 5-15 agencija odjednom.

| Platforma | Prepoznaje se po | Agencije (potvrđeno reconom) | Prioritet |
|---|---|---|---|
| **Onesystem** (Joy Group, Beograd) | `onesystem-powered.png` u footeru, WP tema `onesystem_wp_theme`, parametri `packagecountryid`, `packagecityid`, `packagedeparture`, `packageduration` | 1A Travel | **1** |
| **B2C engine sa `b2cservice` / `newcms` poddomenima** | URL-ovi `/sr/search-router/...`, `/sr/hotel/...`, parametri `SearchType`, `Hotel`, `CheckIn`, `R1Adult`, `Night`, `HpCode`, `Criteria` | Big Blue, Kon Tiki (isti vlasnik i isti engine), verovatno Odeon Travel | **1** |
| **Fibula sopstveni** | `/search?productType=2&to=1962-Region&nights=5,6,7,8,9` — čist REST-oliki upit, ID destinacije u obliku `<id>-Region` | Fibula Air Travel | 2 |
| **cloudhosting.rs multi-tenant** | `vs<broj>.cloudhosting.rs/<Destinacija>?prevoz=autobus&sort=1&page=N` | Oktopod Travel | 2 |
| **WordPress + ručne HTML tabele cena** | `wp-content`, tabela sa datumima polaska u zaglavlju i `1/2`, `1/3`, `1/4` redovima | Feniks Tours, Plana Travel, Euroturs, Vivatravel | 3 |
| **Sopstveni CMS** | — | Travelland, Aqua Travel, Felix Travel, Tim Travel, Sabra, Filip Travel, Grand Tours, Deus Travel, Lider Travel, Belvi, Olympic, Sole Azur, Amos, Hedonic, Magic Travel, Maestral, Rapsody, Online Travel, Time Travel | 3 |

### Šta ovo menja u planu

1. **Prvo Onesystem i b2cservice engine.** Dva adaptera → realno 10+ agencija.
2. **Onesystem se kontaktira za feed.** Njihov marketing eksplicitno pominje integracije i slanje
   podataka partnerima, i integrisani su sa E-Turist sistemom. Ako daju partnerski feed, dobijamo
   strukturisane podatke umesto skrepovanja — čistije, brže i pravno bez rizika.
3. WordPress sajtovi sa ručnim tabelama su najteži (tabela je slika strukture, ne podataka) i idu
   poslednji, ali su i najbrojniji na dugom repu.

## Kandidati — aranžmani (PACKAGE)

| Agencija | Domen | Platforma | Tip ponude | robots | ToS | Status |
|---|---|---|---|---|---|---|
| Big Blue | bigblue.rs | b2cservice | bus, avio, sopstveni, ture | ? | ? | recon |
| Kon Tiki | kontiki.rs | b2cservice | avio, sopstveni, ture, daleke | ? | ? | recon |
| 1A Travel | 1atravel.rs | Onesystem | avio (čarter) | ? | ? | recon |
| Fibula Air Travel | fibula.rs | sopstvena | avio (čarter), sopstveni | ? | ? | recon |
| Travelland | travelland.rs | sopstveni CMS | avio, sopstveni, ture | ? | ? | recon |
| Aqua Travel | aquatravel.rs | sopstveni CMS | bus, avio, sopstveni | ? | ? | recon |
| Filip Travel | filiptravel.rs | sopstveni CMS | bus, avio | ? | ? | recon |
| Oktopod Travel | oktopod.rs | cloudhosting | bus, sopstveni | ? | ? | recon |
| Felix Travel | felixtravel.rs | sopstveni CMS | bus, avio | ? | ? | recon |
| Tim Travel | timtravel.rs | sopstveni CMS | bus, sopstveni | ? | ? | recon |
| Sabra Travel | sabra.rs | sopstveni CMS | bus, avio | ? | ? | recon |
| Grand Tours | grandtours.rs | sopstveni CMS | bus, sopstveni | ? | ? | recon |
| Deus Travel | deustravel.rs | sopstveni CMS | sopstveni (Grčka) | ? | ? | recon |
| Lider Travel | lidertravel.rs | sopstveni CMS | avio, bus | ? | ? | recon |
| Belvi Travel | belvi.rs | sopstveni CMS | avio, bus | ? | ? | recon |
| Olympic | olympic.rs | sopstveni CMS | bus, avio | ? | ? | recon |
| Plana Travel | planatravel.rs | WordPress | bus, sopstveni | ? | ? | recon |
| Feniks Tours | feniks-tours.rs | WordPress | bus, sopstveni | ? | ? | recon |
| Euroturs | euroturs.rs | WordPress | bus, sopstveni | ? | ? | recon |
| Viva Travel | vivatravel.rs | WordPress | bus, avio | ? | ? | recon |
| Sole Azur | soleazur.rs | sopstveni CMS | bus | ? | ? | recon |
| Amos Travel | amostravel.rs | sopstveni CMS | bus, sopstveni | ? | ? | recon |
| Hedonic Travel | hedonictravel.rs | sopstveni CMS | bus, avio, sopstveni | ? | ? | recon |
| Odeon Travel | odeontravel.rs | verovatno b2cservice | avio, bus | ? | ? | recon |
| Argus Tours | argus.rs | sopstveni CMS | bus, transferi | ? | ? | recon |
| Magic Travel | magictravel.rs | sopstveni CMS | avio, bus | ? | ? | recon |
| Maestral | maestral.co.rs | sopstveni CMS | bus, izleti | ? | ? | recon |
| Rapsody Travel | rapsodytravel.rs | sopstveni CMS | avio, mladi | ? | ? | recon |
| Time Travel | timetravel.rs | sopstveni CMS | bus, avio | ? | ? | recon |
| Online Travel | onlinetravel.rs | sopstveni CMS | mešano | ? | ? | recon |

## Kandidati — samo prevoz (TRANSPORT)

| Izvor | Domen | Napomena |
|---|---|---|
| Polazak | polazak.rs | prodaja autobuskih karata, ima strukturisanu pretragu po relaciji i datumu |
| BalkanViator | balkanviator.com | red vožnje + karte, regionalno pokrivanje |
| Red vožnje | redvoznje.net | samo red vožnje, bez cena |
| Teroplan | teroplan.rs | isti vlasnik kao BalkanViator/Vollo, moguć partnerski pristup |
| FlixBus | flixbus.rs | ima javni GTFS i partnerski program |
| Lasta | lasta.rs | domaći i međunarodni linijski prevoz |
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
