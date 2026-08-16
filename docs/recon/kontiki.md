# Kon Tiki Travel (KonTiki Travel & Service, Beograd) — kontiki.rs

Recon: 15.08.2026. · Pouzdanost: **srednja** · Težina: **4/5** · Dohvaćeno: **NE**

> Generisano automatski iz recon izveštaja. Prijavljeno je samo ono što je agent stvarno
> video u dohvaćenom sadržaju. Prazno polje znači da nije provereno, **ne** da ne postoji.

## Platforma

**SANTSG TourVisio B2C + SanCMS (SAN Tourism Software Group) — NIJE Onesystem/WordPress**

1) https://cms.kontiki.rs/ dohvacen WebFetch-om, naslov doslovno: "Welcome To Cms Control Panel". 2) Isti URL u indeksu (firecrawl_search site:cms.kontiki.rs) daje puni tekst login stranice: "Welcome To SanCMS ControlPanel ; Site Name. select. Kontiki Rs; Kontiki Co Me; Kontiki Ba ; Remember Me ; Auto Login ; Powered by SAN Tourism Software Group. v 1.0." — dakle JEDNA SanCMS instanca opsluzuje tri storefronta (kontiki.rs, kontiki.co.me, kontiki.ba). 3) Isti SanCMS panel nadjen na cms.odeontravel.rs (v 1.0.614.0), cms.fibula.ro (v 1.0.153.0), cms.merittravel.com.tr (v 1.0.620.0). 4) https://newcms.bigblue.rs/ dohvacen — isti naslov "Welcome To Cms Control Panel". 5) Dohvacen https://www.santsg.com/en/references/tourvisio-b2c/ — u listi referenci proizvoda TourVisio B2C stoje "Big Blue (Serbia)", "Odeon World Travel Doo (Serbia)", "Flip Travel (Serbia)". Kon Tiki NIJE na toj javnoj listi referenci, ali njegov CMS je SanCMS istog proizvodjaca. 6) Dohvacena homepage sestrinskog kontiki.ba — u futeru doslovno: "Plan your trip with SANTSG. Buy Holiday Packages, airline tickets, read reviews & reserve a hotel."

## Pravni status

robots.txt dohvaćen: **ne**
Blokira nas: **ne**

_robots.txt nije dohvaćen — proveriti lokalno pre uključivanja izvora._

## Sitemap

- NEPOTVRDJENO: https://www.kontiki.rs/Sitemap.xml — kandidat po sablonu engine-a; NIJE dohvacen (ceo host kontiki.rs je nedostupan).
- https://b2c.kontiki.rs/Sitemap.xml — POKUSANO, vraca HTTP 404 (host postoji i odgovara, fajl na toj putanji ne postoji).
- http://b2c.kontiki.ba/Sitemap.xml — doslovno deklarisan u robots.txt sestrinskog kontiki.ba; https varijanta vraca 404, http nije testiran.
- REFERENCA (isti engine, radi): https://www.odeontravel.rs/Sitemap.xml — dohvacen, obican <urlset> (ne sitemap index), prve stavke tipa https://www.odeontravel.rs/stranica/... 

## Renderovanje

**MIXED**

NIJE direktno provereno na kontiki.rs (HTML nikad nije dohvacen). Indirektno: (a) robots.txt sestrinskog kontiki.ba i istog engine-a odeontravel.rs doslovno sadrzi "Disallow: /*.asmx" i "Disallow: /*.ashx" — ASP.NET web-service handleri, tj. engine ima XHR sloj; (b) dohvacena listing strana istog engine-a https://www.odeontravel.rs/lokacija/tasos/ u HTML-u bez JS-a sadrzi SAMO search/filter panele ("Paket aranzman", "Hoteli", "Samo avion", "Rent A Car", "Transfer", "Izlet") i kurs "1 € = 117,3433 RSD" — NIJEDNU karticu ponude i nijednu cenu; (c) ipak, Google i Firecrawl indeksiraju tekst kartica sa kontiki.rs zajedno sa cenama (vidi price_table_example / notes), pa je bar deo sadrzaja dostupan renderu. Zakljucak: rezultati pretrage/kartice se skoro sigurno pune XHR-om preko .asmx/.ashx, dok su meta/naslov/opis hotela SSR.

## URL-ovi liste

- https://kontiki.rs/sr/packages/srbija~beograd~grcka~zakintos/
- https://kontiki.rs/sr/packages/srbija~beograd~grcka~skijatos/
- https://kontiki.rs/sr/packages/srbija~beograd~turska~cesme/
- https://kontiki.rs/sr/packages/srbija~beograd~grcka~hanja/
- https://kontiki.rs/sr/packages/srbija~beograd~kiparska-republika~protaras/
- https://kontiki.rs/sr/location/grcka/
- https://kontiki.rs/sr/location/malta/
- https://kontiki.rs/sr/location/dubai/
- https://kontiki.rs/sr/location/kusadasi/
- https://kontiki.rs/sr/grcka-ostrva-letovanje-sopstveni-prevoz/
- https://kontiki.rs/sr/grcka-letovanje-sopstveni-prevoz/
- https://kontiki.rs/sr/grcka-ostrva-junski-polasci/
- https://kontiki.rs/sr/kipar/

## Šablon URL-a detalja

https://kontiki.rs/sr/hotel/{zemlja-slug}/{destinacija-slug}/{hotel-slug}/  — potvrdjeni primeri iz indeksa: /sr/hotel/grcka/zakintos/caretta-paradise/ , /sr/hotel/tajland/koh-samui/bandara-spa-resort---pool-villas/ , /sr/hotel/united-states/hawaii/outrigger-kaanapali-beach-resort/ . Postoji i varijanta /sr/hotel/rotator/{slug}/ za kurirane liste (npr. /sr/hotel/rotator/grcka-leto-top-10-izdvajamo-iz-ponude-avio-prevoz/). Napomena: slug pravi '-' od razmaka i '---' od ' & ' (bandara-spa-resort---pool-villas = 'BANDARA SPA RESORT & POOL VILLAS'). Prefiks /sr/ je jezicki (sestrinski kontiki.ba koristi /bs/, bigblue.rs ima i /en).

## Query parametri

- PL=27012-551-16357-5074387 — deep link ka konkretnoj ponudi/cenovnoj liniji, 4 numericka segmenta odvojena '-'. VAZNO: vidjen na SESTRINSKOM kontiki.ba (https://www.kontiki.ba/bs/hotel/turska/side/bella-resort-hotel?PL=27012-551-16357-5074387 i .../aydinbey-kings-palace?PL=25000-592-17823-4709502), NIJE potvrdjen na kontiki.rs jer HTML .rs sajta nikad nije dohvacen. Znacenje segmenata nije utvrdjeno.
- Nijedan drugi query parametar nije vidjen ni na jednom kontiki.rs URL-u.

## Paginacija

Nije vidjeno. Nijedna paginaciona kontrola ni parametar nisu observirani — listing stranice kontiki.rs nisu dohvacene, a na dohvacenoj listing strani istog engine-a (odeontravel.rs/lokacija/tasos/) u HTML-u bez JS-a nema ni kartica ni paginacije, sto sugerise da je paginacija/lazy-load deo XHR sloja.

## Gde su podaci

NEMA CSS SELEKTORA — HTML kontiki.rs nikad nije dohvacen, pa bi svaki selektor bio izmisljen. Ono sto je stvarno videno, opisno:
(1) Kartice ponuda na kontiki.rs — tekst izvucen iz indeksa pretrage (Google/Firecrawl), doslovni konkatenirani isecci: "KIPAR PORODICNI HOTELI 2026-7 Noci-po osobi 1.17500 -5% Default TASIA MARIS SEASONS -ADULTS ONLY" (sa /sr/kipar/); "2026-8 Noci-po osobi 96400 Default ALEXANDRE HOTEL GALA. Noci-po osobi 1.09200. HOTELHOTEL NA PLAZILUKSUZAN HOTEL Al Raha Beach Resort & Spa" (sa homepage); "HOTELHOTEL NA PLAZISmene 10 noci:20.8-30.8.30.8-9.9.9.9-19.9. ci-po osobi 59900 -13% Noci-po osobi 10300" (sa /sr/grcka-ostrva-letovanje-sopstveni-prevoz/); "ci-po osobi 79900 72700 ... mene 10 noci:30.8-9.9.9.9-" (sa /sr/grcka-letovanje-sopstveni-prevoz/).
Iz toga se vidi struktura kartice: broj noci + oznaka "Noci-po osobi" + cena + opcioni procenat popusta ("-5%", "-13%") + opciona precrtana stara cena ("79900 72700") + tagovi hotela ("HOTEL", "HOTEL NA PLAZI", "LUKSUZAN HOTEL", "PORODICNI HOTELI", "ADULTS ONLY") + naziv hotela + lista smena ("Smene 10 noci: 20.8-30.8 / 30.8-9.9 / 9.9-19.9").
KRITICNO ZA PARSER: cena je razbijena u dva elementa — celi deo i dvocifreni deo para. "1.17500" = 1.175,00 EUR; "96400" = 964,00; "59900" = 599,00; "1.09200" = 1.092,00. Naivni text-extract lepi ih zajedno i daje 100x vecu cenu. Parser mora citati celi deo i decimale iz odvojenih cvorova, ne iz .text celog elementa.
(2) Tabele cena po sobama/slotovima: potvrdjeno postoje u PDF katalozima na cms.kontiki.rs (vidi price_table_example). Da li ista tabela postoji i u HTML-u detaljne strane hotela — NIJE provereno.
(3) Zvezdice: u nazivu hotela u PDF-u kao "3*", "4*"; u HTML-u nije provereno.
(4) Naslov detaljne strane (iz indeksa, doslovno): "CARETTA PARADISE ZAKINTOS - Kontiki Travel & Service", meta opis: "Rezervisite hotel preko Kontiki turisticke agencije - veliki izbor destinacija, povoljne cene i sigurna online rezervacija ... CARETTA PARADISE. BEOGRAD - ..." — dakle na detaljnoj strani postoji i polaziste (BEOGRAD -) i, sudeci po drugom snippetu, datumi u zagradi ("Zakintos (19.07.)", "Hoteli 3* (06.09 ...").

## Primer tabele cena

```
IZ PDF-a NA cms.kontiki.rs (NIJE iz HTML stranice hotela — HTML kontiki.rs nikad nije dohvacen).
Izvor: https://cms.kontiki.rs/b2cDocuments/pdf/Leto/Grcka/Zakintos-sopstveni-prevoz.pdf ("ZAKINTOS LETO 2024.")
Zaglavlje: "CENA PUTOVANJA PO OSOBI U EVRIMA"
Kolone (datumi polazaka): 16.06 | 26.06 | 07.07 | 17.07 | 28.07 | 07.08 | 18.08 | 28.08 | 08.09
Oznake redova (slotovi): "Po osobi u dvokrevetnoj sobi" | "Prvo dete 2-8 god." | "Prvo dete 8-12 god." | "Drugo dete 2-8 god." | "Drugo dete 8-12god." | "Treca odrasla osoba" | "Porodicna soba" | "Nocenje sa dorucom" | "All inclusive"
Oznake smestaja: "Sandy Maria studios", "Apollon Hotel 3*, S", "ILIESSA BEACH HOTEL 3*", "ALYKANAS GRAND BEACH HOTEL 4*", "BLUE WAVES APART HOTEL", "TSILIVI BEACH HOTEL 4*", "PALAZETTO HOTEL 4*", "HOTEL CARETTA PARADISE 4*"
Doplata — boravisna/ekoloska taksa, doslovno (sa originalnim greskama u kucanju): "obavezna ekoloska taksa u vezi sa klimatskim promenama ce se racunati kao fiksni iznos po danu i po sobi, uzavisnosti od vrste smestaja i iznosice: 10 € za hotele sa 5*; 7 € za hotele sa 4*; 3 € za hotele sa 3*, 1.5 € za hotele sa 2*, studjia i apartmane"
U novijem PDF-u (https://cms.kontiki.rs/b2cDocuments/pdf/Leto/Grcka/Zakintos/Zakintos-sopstveni-prevoz.pdf) iste kolone glase: 21.06 | 01.07 | 12.07 | 22.07 | 02.08 | 12.08 | 23.08 | 02.09 | 13.09, a taksa: "4 € za hotele sa 5*; 3 € za hotele sa 4*; 1,5 € za hotele sa 3*; 0,5 € za hotele sa 2*, studija i apartmane".
UPOZORENJE: pojedinacne brojcane celije NAMERNO nisu prenete — PDF je prosao kroz sumarizacioni model i brojevi u celijama nisu pouzdani (npr. ponavljalo se '12' na mestima gde je verovatno 'GRATIS'/oznaka fusnote). Labeli kolona i redova su dvostruko potvrdjeni (WebFetch PDF-a + nezavisni firecrawl snippet: "CENA PUTOVANJA PO OSOBI U EVRIMA. Smestaj. Sandy Maria studios ... Po osobi u dvokrevetnoj sobi. Prvo dete 2-8 god. Prvo dete 8-12 god. Drugo dete 2-8 god. Drugo dete 8-12god. Apollon Hotel 3*, S. Po osobi u.").
```

## Tipovi proizvoda

- paket aranzman / letovanje (avio i sopstveni prevoz)
- samo hotel (na kontiki.ba tab doslovno "Only Hotel")
- daleke destinacije
- evropske metropole (avio, gradski break)
- autobuske ture ("Tour Culture" tab na kontiki.ba)
- wellness & spa
- zimovanje
- vize (cms.kontiki.rs/b2cDocuments/pdf/Vize/...)
- avio karte
- "Online region" (hoteli Srbija/Slovenija/Hrvatska/BiH) — https://kontiki.rs/sr/online-region/

## Tipovi prevoza

- avio prevoz
- sopstveni prevoz
- autobuski prevoz
- redovna avio linija (npr. PDF Madrid: "Redovna linija Air Serbia")

## Prepreke

- KRITICNO: ceo host kontiki.rs (i www.kontiki.rs) je nedostupan mojim alatima — /robots.txt ulazi u beskonacnu petlju redirekcija, pa WebFetch odbija svaki URL na tom hostu sa ROBOTS_DISALLOWED. Nijedan bajt HTML-a sa kontiki.rs nije vidjen.
- Direktan curl je blokiran organizacionom egress politikom: gateway vraca 403 na CONNECT za kontiki.rs, bigblue.rs, b2c.bigblue.rs, newcms.bigblue.rs, putovanja.bigblue.rs, 1atravel.rs. Nije zaobilazeno.
- Deep strane engine-a vracaju "Too many redirects" i za sestrinski kontiki.ba i za bigblue.rs kada ih dohvata obican klijent bez kolacica — dok homepage prolazi. Skreper ce morati na session sa cookie jar-om (verovatno culture/locale kolacic), a mozda i na Playwright. Ovo je istovremeno i dokaz da su .rs i .ba i bigblue.rs isti engine sa istom konfiguracijom.
- web.archive.org je blokiran proxy-jem (403), pa ni arhivirani HTML nije mogao da se pogleda.
- robots.txt za kontiki.rs NIJE vidjen. Na sestrinskom kontiki.ba i na odeontravel.rs (isti engine) sablon je: Allow:*, Disallow: /*.asmx, Disallow: /*.ashx. Ako je isti sablon i na .rs, onda su XHR endpointi engine-a (ASP.NET .asmx/.ashx), tj. bas ono sto bi adapter zvao, robots-om ZABRANJENI, dok su HTML strane dozvoljene. Ovo treba proveriti pre pisanja adaptera i odluciti politiku.
- Nema nijednog CSS selektora ni JSON putanje — sve sto pise u data_location je opisno i izvedeno iz teksta koji su indeksirali pretrazivaci.
- PL= deep-link parametar je vidjen samo na kontiki.ba, ne na kontiki.rs; znacenje 4 numericka segmenta nije utvrdjeno.

## Napomene

ODGOVOR NA HIPOTEZU "isti engine kao Big Blue": POTVRDJENO na nivou platforme i URL sablona, NIJE potvrdjeno na nivou query parametara i XHR payload-a (nijedan od ta dva sajta nije dao HTML).

Sta je konkretno potvrdjeno:
- Identican /packages/ sablon, do na slug: kontiki.rs/sr/packages/srbija~beograd~grcka~skijatos/ i bigblue.rs/sr/packages/srbija~beograd~grcka~skijatos/ — doslovno ista putanja, oba u indeksu. Isto i za turska~cesme / turska~side / turska~fetije.
- Identican /location/ sablon: kontiki.rs/sr/location/malta/ ↔ bigblue.rs/sr/location/skijatos/, /santorini/, /majorka/. Big Blue ima i podrutu /sr/location/kasandra/hotel.
- Identican /hotel/ sablon: kontiki.rs/sr/hotel/grcka/zakintos/caretta-paradise/ ↔ www.bigblue.rs/sr/hotel/grcka/atina/hotel-3--velika-grcka-tura i /sr/hotel/grcka/peloponez/grecotel-ilia-palms---aqua-park (isto pravilo '---' za ' & ').
- Oba sajta imaju CMS backend istog proizvoda: cms.kontiki.rs i newcms.bigblue.rs vracaju isti naslov "Welcome To Cms Control Panel", a indeks pokazuje da je kontiki-jev "SanCMS ... Powered by SAN Tourism Software Group".
- SAN TSG na svojoj stranici referenci za proizvod TourVisio B2C eksplicitno navodi "Big Blue (Serbia)".
- Oba se identicno ponasaju prema plain HTTP klijentu (beskonacna redirekcija na deep stranama).

Razlike koje adapter mora da parametrizuje:
- Jezicki prefiks: kontiki.rs = /sr/, kontiki.ba = /bs/, bigblue.rs ima i /en. Odeon Travel (isti engine) uopste ne koristi jezicki prefiks nego lokalizovane rute: /lokacija/{slug}/ i /hotel/{zemlja}/{dest}/{slug}/ i /stranica/{slug}. Dakle rute su per-site konfiguracija, ne hard-coded.
- Trailing slash: kontiki URL-ovi u indeksu su sa zavrsnom kosom crtom, deo bigblue URL-ova bez nje.
PREPORUKA: jedan adapter klasa "SantsgTourvisioB2C" sa konfiguracijom (base_domain, lang_prefix, route_map, trailing_slash) pokriva Kon Tiki, Big Blue, a verovatno i Odeon Travel i Flip Travel. Ne pisati dva odvojena adaptera.

DODATNO KORISNO:
- Jedna SanCMS instanca (cms.kontiki.rs) opsluzuje tri storefronta: "Kontiki Rs; Kontiki Co Me; Kontiki Ba". Ista ponuda se verovatno pojavljuje na sva tri domena — bitno za dedupe (ne tretirati kontiki.ba i kontiki.rs kao dve nezavisne agencije).
- cms.kontiki.rs/b2cDocuments/pdf/... je otvoren direktorijum PDF kataloga (Leto/, Daleka/, Evropa/Avion/, Wellness/, Individualna/, Vize/) i JEDINI izvor sa kog sam stvarno procitao tabelu cena po slotovima. Za programe "sopstveni prevoz" ovi PDF-ovi su cesto jedini nosilac tabele cena. Vredi ih tretirati kao poseban izvor u ingest-u (PDF parser), nezavisno od HTML adaptera.
- Doplate: boravisna/ekoloska taksa je eksplicitno IZVAN istaknute cene i data je kao fiksni iznos po danu i po sobi stepenovan po kategoriji hotela (5*/4*/3*/2*+studio) — iznosi se razlikuju izmedju 2024 i 2026 verzije PDF-a. Medjunarodno putno zdravstveno osiguranje je obavezno za EU destinacije i takodje nije u ceni.
- Cene u karticama su razbijene na celi i decimalni deo u odvojenim elementima; naivno citanje teksta daje 100x vecu cenu. Ovo je najverovatniji tihi bug u buducem adapteru.
- SIGURNOST/PROMPT INJECTION: nista sto lici na instrukciju meni nije nadjeno ni u jednom dohvacenom sadrzaju (PDF-ovi, CMS login, robots.txt, homepage kontiki.ba). Sav sadrzaj je tretiran kao podatak.
- Sve sto je oznaceno kao "iz indeksa" dolazi iz Google/Firecrawl snippeta, tj. jeste stvarni tekst sa kontiki.rs, ali konkateniran i skracen od strane pretrazivaca — nije zamena za dohvatanje HTML-a. Sledeci korak: ponoviti recon sa klijentom koji ima cookie jar i prati redirekcije (httpx sa follow_redirects i cookies, ili Playwright), sa srpskim Accept-Language, i tek tada popuniti selektore, paginaciju i XHR endpoint.

## Proverene stranice

- https://kontiki.rs/robots.txt — NEUSPEH: ROBOTS_DISALLOWED, "robots.txt fetch failed: Exceeded maximum allowed redirects"
- https://kontiki.rs/sr/packages/srbija~beograd~grcka~zakintos/ — NEUSPEH: isti robots redirect loop
- https://kontiki.rs/sr/hotel/grcka/zakintos/caretta-paradise/ — NEUSPEH: isti robots redirect loop
- https://www.kontiki.rs/sr/hotel/grcka/zakintos/caretta-paradise/ — NEUSPEH: isti robots redirect loop
- https://cms.kontiki.rs/ — USPEH: "Welcome To Cms Control Panel"
- https://cms.kontiki.rs/robots.txt — 404
- https://cms.kontiki.rs/b2cDocuments/pdf/Leto/Grcka/Zakintos/Zakintos-sopstveni-prevoz.pdf — USPEH (cenovnik 2026 + boravisna taksa)
- https://cms.kontiki.rs/b2cDocuments/pdf/Leto/Grcka/Zakintos-sopstveni-prevoz.pdf — USPEH (cenovnik ZAKINTOS LETO 2024 sa oznakama redova/kolona)
- https://b2c.kontiki.rs/ — 404 (host odgovara)
- https://b2c.kontiki.rs/Sitemap.xml — 404
- https://kontiki.ba/ — USPEH (sestrinski storefront, ista CMS instanca; futer "Plan your trip with SANTSG")
- https://kontiki.ba/robots.txt — USPEH, doslovno: "User-agent: *\nAllow:*\nDisallow: /*.asmx\nDisallow: /*.ashx\n\nSitemap: http://b2c.kontiki.ba/Sitemap.xml"
- https://kontiki.ba/bs/hotel/turska/side/club-nena — NEUSPEH: Too many redirects
- https://www.kontiki.ba/bs/hotel/turska/side/bella-resort-hotel?PL=27012-551-16357-5074387 — NEUSPEH: Too many redirects
- https://kontiki.ba/en/about-us — NEUSPEH: Too many redirects
- https://kontiki.co.me/ — 302 na http://www.kontiki.co.me/ ; https://www.kontiki.co.me/robots.txt — SSL hostname mismatch
- https://b2c.kontiki.ba/Sitemap.xml — 404
- https://www.bigblue.rs/sr/hotel/grcka/peloponez/grecotel-ilia-palms---aqua-park — NEUSPEH: Too many redirects (isto ponasanje kao kontiki)
- https://newcms.bigblue.rs/ — USPEH: "Welcome To Cms Control Panel" (isti naslov kao cms.kontiki.rs)
- https://odeontravel.rs/robots.txt — USPEH: identican sablon (Allow:*, Disallow /*.asmx, /*.ashx, Sitemap: https://www.odeontravel.rs/Sitemap.xml)
- https://www.odeontravel.rs/Sitemap.xml — USPEH (urlset)
- https://www.odeontravel.rs/lokacija/tasos/ — USPEH: u HTML-u samo search widget, bez kartica i cena
- https://www.odeontravel.rs/hotel/grcka/tasos/ilio-mare/ — NEUSPEH: server error
- https://www.santsg.com/en/references/tourvisio-b2c/ — USPEH: Big Blue (Serbia), Odeon World Travel Doo (Serbia), Flip Travel (Serbia) na listi referenci TourVisio B2C
- https://archive.org/wayback/available?url=kontiki.rs/... — NEUSPEH (server error); https://web.archive.org/cdx/... — NEUSPEH: proxy 403
- curl na kontiki.rs preko HTTPS_PROXY — NEUSPEH: 403 CONNECT (org egress politika; isto i za bigblue.rs, b2c.bigblue.rs, 1atravel.rs)
- WebSearch: site:kontiki.rs letovanje 2026 cene ; site:bigblue.rs letovanje 2026 ; site:bigblue.rs hotel grcka ; "/sr/packages/srbija~beograd~" letovanje ; site:kontiki.ba hotel ; site:odeontravel.rs hotel grcka 2026
- firecrawl_search: site:cms.kontiki.rs ; "SanCMS Control Panel" OR "SAN Tourism Software Group" ; site:kontiki.rs hotel Zakintos cene po osobi
