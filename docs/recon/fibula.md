# Fibula Air Travel — fibula.rs

Recon: 15.08.2026. · Pouzdanost: **srednja** · Težina: **5/5** · Dohvaćeno: **da**

> Generisano automatski iz recon izveštaja. Prijavljeno je samo ono što je agent stvarno
> video u dohvaćenom sadržaju. Prazno polje znači da nije provereno, **ne** da ne postoji.

## Platforma

**sopstveni CMS**

Frontend je sopstveni SPA (nije Onesystem/b2cservice/WordPress): sve /search rute vracaju staticki SEO shell sa loading tekstom 'Searching the best hotels for you'. ALI inventar ponuda NIJE sopstveni - u URL-ovima detalja stoji doslovno providerType=Peakwork, uz correlationId=<32 hex>, offerKey=RoomKey%3D2, RoomOpCode, BoardKey, BoardOpCode, DepartureFlightKey=20250614|7319|JU0520|YY|12:00:00*0520. To je potpis Peakwork hub-a (nemacki B2B distribucioni sistem). Sam naziv parametra providerType implicira vise pluggable provajdera. Postoji i drugi, stariji engine na white.fibula.rs (rute /sr/Hotel/<slug>, /sr/location/<slug>) sa tabovima 'SAMO HOTEL CENOVNIK / AVION+HOTEL CENOVNIK / BUS+HOTEL CENOVNIK' - to je odvojena platforma od www.fibula.rs.

## Pravni status

robots.txt dohvaćen: **da**
Blokira nas: **DA**

```
# --- Social media previews ---
User-agent: facebookexternalhit
Allow: /

# --- Major search engines (allow for SEO + Gemini browsing) ---
User-agent: Googlebot
Allow: /

User-agent: Googlebot-Image
Allow: /

User-agent: Googlebot-Video
Allow: /

User-agent: AdsBot-Google
Allow: /

# Bing search (SEO only)
User-agent: bingbot
Allow: /
Crawl-delay: 10

# --- ChatGPT browsing (allow) ---
User-agent: ChatGPT-User
Allow: /

# --- Gemini browsing (allow) ---
# Gemini uses Googlebot for fetching content, so allow Googlebot above.
# But block Google-Extended to prevent AI training.
User-agent: Google-Extended
Disallow: /

# --- Block AI/data scrapers & training bots ---
User-agent: GPTBot
Disallow: /
User-agent: ClaudeBot
Disallow: /
User-agent: Claude-Web
Disallow: /
User-agent: anthropic-ai
Disallow: /
User-agent: PerplexityBot
Disallow: /
User-agent: Applebot
Disallow: /
User-agent: Applebot-Extended
Disallow: /
User-agent: CCBot
Disallow: /
User-agent: Bytespider
Disallow: /
User-agent: AhrefsBot
Disallow: /
User-agent: SemrushBot
Disallow: /
User-agent: dotbot
Disallow: /
User-agent: barkrowler
Disallow: /
User-agent: OAI-SearchBot
Disallow: /

User-agent: AI2Bot
User-agent: Ai2Bot-Dolma
User-agent: Amazonbot
User-agent: anthropic-ai
User-agent: Applebot
User-agent: Applebot-Extended
User-agent: Bytespider
User-agent: CCBot
User-agent: ChatGPT-User
User-agent: Claude-Web
User-agent: ClaudeBot
User-agent: cohere-ai
User-agent: Diffbot
User-agent: DuckAssistBot
User-agent: FacebookBot
User-agent: FriendlyCrawler
User-agent: Google-Extended
User-agent: GoogleOther
User-agent: GoogleOther-Image
User-agent: GoogleOther-Video
User-agent: GPTBot
User-agent: iaskspider/2.0
User-agent: ICC-Crawler
User-agent: ImagesiftBot
User-agent: img2dataset
User-agent: ISSCyberRiskCrawler
User-agent: Kangaroo Bot
User-agent: Meta-ExternalAgent
User-agent: Meta-ExternalFetcher
User-agent: OAI-SearchBot
User-agent: omgili
User-agent: omgilibot
User-agent: PerplexityBot
User-agent: PetalBot
User-agent: Scrapy
User-agent: Sidetrade indexer bot
User-agent: Timpibot
User-agent: VelenPublicWebCrawler
User-agent: Webzio-Extended
User-agent: YouBot
User-agent: AhrefsBot
User-agent: BLEXBot
User-agent: SemrushBot
User-agent: dotbot
User-agent: GeedoProductSearch
User-agent: barkrowler
Disallow: /

User-agent: bingbot
Crawl-Delay: 604800
```

## Sitemap

- https://www.fibula.rs/sitemap.xml

## Renderovanje

**MIXED**

SSR je samo opisni deo: na /avionom/turska/antalijska-regija/kemer/kemer-dream-hotel--760873 dohvatio sam naslov 'Hotel Kemer Dream ★★★★ - Kemer, Turska', opis usluge 'All inclusive (sve ukljuceno)' i listu sadrzaja hotela - sve u HTML-u. Cene NISU u HTML-u ni na jednoj dohvacenoj strani. /search?productType=1&to=1393-region i /en/search?productType=1&to=1393-region&sortBy=0&page=1&checkIn=2026-07-23&isPackageFlex=false&departureAirportCode=BEG&nights=7 i /en/search?productType=2&to=MK-country vracaju nula kartica ponuda i samo tekst 'Searching the best hotels for you'. Na /hotel/kipar/juzni-kipar/aja-napa/nestor--94073 umesto cene stoji 'CENE I RASPOLOZIVOST SU NA UPIT!'. Na white.fibula.rs/sr/Hotel/trendy---lara--turska tabovi cenovnika postoje kao dugmad ali tabele sa brojevima nisu u HTML-u. Zakljucak: liste i sve cene se pune preko XHR-a posle hidracije.

## URL-ovi liste

- https://www.fibula.rs/search?productType=1&to=1393-region
- https://www.fibula.rs/en/search?productType=1&to=1393-region&sortBy=0&page=1&checkIn=2026-07-23&isPackageFlex=false&departureAirportCode=BEG&nights=7
- https://www.fibula.rs/en/search?productType=2&to=MK-country
- https://www.fibula.rs/en/search?productType=1&to=36044-City&nights=7%2C14
- https://www.fibula.rs/crna-gora-hoteli
- https://www.fibula.rs/turska-letovanje-avionom
- https://www.fibula.rs/programi-putovanja

## Šablon URL-a detalja

Dva paralelna prefiksa, oba sa istim oblikom: /avionom/<zemlja>/<regija>/<grad>/<hotel-slug>--<numerickiId> (paket sa avionom, odgovara productType=1) i /hotel/<zemlja>/<regija>/<grad>/<hotel-slug>--<numerickiId> (smestaj bez leta, odgovara productType=2). Separator izmedju sluga i ID-a su DVA minusa. Engleska verzija ima /en/ prefiks. Skraceni oblik /avionom/<numerickiId> takodje radi i kanonikalizuje se na puni slug - potvrdjeno: dohvatio sam https://www.fibula.rs/en/avionom/201595 i canonical na stranici je https://www.fibula.rs/en/avionom/turkey/marmara-region/istanbul/crowne-plaza-istanbul-old-city-by-ihg--201595. To je vazno: dovoljan je numericki ID da se dodje do stranice detalja, ne treba pogadjati slug. Stvarni primeri koje sam video: /avionom/turska/antalijska-regija/kemer/kemer-dream-hotel--760873, /avionom/turska/antalijska-regija/alanja/sunpark-garden-apart-hotel--887527, /avionom/grcka/krit/retimno-grad/melitti-hotel--1826486, /avionom/grcka/krf/agios-georgios-juzni/blue-sea-hotel--217557, /hotel/kipar/juzni-kipar/aja-napa/nissiana-hotel-and-bungalows--646258, /hotel/kipar/juzni-kipar/aja-napa/nestor--94073. Stariji engine white.fibula.rs koristi drugaciji oblik bez ID-a: /sr/Hotel/trendy---lara--turska, /sr/Hotel/fame-residence-lara.

## Query parametri

- productType=1 = paket sa avio prevozom (dokaz: uvek dolazi zajedno sa DepartureFlightKey, ReturnFlightKey i departureAirportCodeList=BEG, i stoji na /avionom/ stranicama; primer: /en/search?productType=1&to=1393-region&departureAirportCode=BEG&nights=7)
- productType=2 = smestaj bez leta / hotel-only (dokaz: stoji na /hotel/ stranicama i NEMA nijedan flight parametar niti departureAirportCode; primeri: /search?productType=2&to=MK-country, i vas poznati /search?productType=2&to=1962-Region&nights=5,6,7,8,9). Vrednosti 3/4 nisam nigde video - ne tvrdim da ne postoje.
- to = destinacija, tri oblika sufiksa, sufiks je case-insensitive jer sam video oba pisanja: to=<ISO2>-country za zemlju (primeri: to=TR-country, to=MK-country), to=<numerickiId>-region za regiju (primeri: to=1393-region, to=1765-region, to=1962-Region), to=<numerickiId>-city za grad (primeri: to=36173-city, to=36044-City). Dakle zemlje su ISO alpha-2 kod, a regije i gradovi su interni numericki ID-evi - NISU isti prostor ID-eva kao hotelski ID iz URL-a detalja.
- nights = duzina boravka, prihvata listu odvojenu zarezom (primeri: nights=7, nights=7,14, nights=5,6,7,8,9)
- checkIn = datum polaska/prijave u ISO formatu (primer: checkIn=2026-07-23)
- page = broj strane rezultata (primer: page=1)
- sortBy = redosled sortiranja, numericki (primer: sortBy=0; znacenje ostalih vrednosti nisam potvrdio)
- departureAirportCode = polazni aerodrom u pretrazi (primer: departureAirportCode=BEG)
- isPackageFlex = boolean flag za fleksibilni paket u pretrazi (primer: isPackageFlex=false); na strani detalja isti flag se zove isFlex (primer: isFlex=false)
- currency = valuta (primer: currency=EUR)
- correlationId = 32-cifreni hex identifikator sesije pretrage, obavezan na deep linku ka detalju (primer: correlationId=02df8fd013b59583914dd8fcb144d136). Verovatno kratkotrajan - deep linkovi sa njim najverovatnije isticu.
- durations = broj noci konkretne ponude na strani detalja (primeri: durations=5, durations=7, durations=11)
- departureDate i returnDate = ISO datumi konkretne ponude (primer: departureDate=2025-06-14&returnDate=2025-06-25)
- guests = ponavljajuci parametar, jedan po putniku, vrednost je DATUM RODJENJA a ne broj osoba (primeri: guests=1993-01-01&guests=1993-01-01, guests=1995-01-24&guests=1995-01-24). Ovo je kljucno za slot model: uzrast deteta se kodira datumom rodjenja.
- personAssignments = raspored putnika po sobama (primer: personAssignments=1,2 = obe osobe u istoj sobi)
- offerKey = kljuc ponude, url-enkodovan (primeri: offerKey=RoomKey%3D4 tj. RoomKey=4, offerKey=RoomKey%3D2)
- RoomKey i RoomOpCode = sifra tipa sobe kod provajdera (primeri: RoomKey=2 uz RoomOpCode=2416795; RoomKey=1 uz RoomOpCode=14025; RoomKey=4 uz RoomOpCode=1)
- BoardKey i BoardOpCode = sifra usluge ishrane kod provajdera (primeri: BoardKey=3&BoardOpCode=17, BoardKey=1&BoardOpCode=4, BoardKey=2&BoardOpCode=16, BoardKey=1&BoardOpCode=17)
- DepartureFlightKey i ReturnFlightKey = kompozitni kljuc leta. Video sam dva razlicita formata: DepartureFlightKey=20250614%7C7319%7CJU0520%7CYY%7C12:00:00*0520 (pipe-separated, JU = Air Serbia) i DepartureFlightKey=20250811PC374PC374PC374PC374TY16:50*374 (PC = Pegasus)
- providerType = izvor inventara (jedina vidjena vrednost: providerType=Peakwork)
- departureAirportCodeList = polazni aerodrom na strani detalja (primer: departureAirportCodeList=BEG)

## Paginacija

Postoji query parametar page (video sam page=1 u stvarnom URL-u pretrage), ali same kartice rezultata se nikad ne pojavljuju u HTML-u pa nisam mogao da vidim ni kontrole paginacije ni ukupan broj strana. Nije mi poznato da li je klasicna paginacija ili infinite scroll koji samo odrzava page u URL-u.

## Gde su podaci

NISAM video nijedan CSS selektor niti JSON putanju do cena - zato ih ovde namerno ne navodim. Evo sta sam stvarno video i gde: NASLOV I ZVEZDICE su u SSR HTML-u strane detalja, kao jedan string u obliku 'Hotel Kemer Dream ★★★★ - Kemer, Turska' odnosno 'Hotel Nestor ★★★★' - zvezdice su doslovni ★ karakteri u naslovu, treba ih brojati iz teksta, a lokacija je u istom stringu posle crtice. USLUGA ISHRANE je u SSR opisnom tekstu kao slobodan tekst, npr doslovno 'All inclusive (sve ukljuceno)' i 'Polupansion (dorucak i vecera)' i 'Nocenje sa dorucnom (kontinentalni, samoposluzivanje)' - dakle mora se parsirati iz proze, nije poseban strukturiran atribut. OZNAKE SOBA (1/2, 1/2+1, 1/4, A2/4) NISAM video nigde u HTML-u; sobe su u URL-u kodirane samo numericki preko RoomKey i RoomOpCode, sto znaci da mapiranje sifra -> ljudska oznaka sobe postoji samo u XHR odgovoru. CENE, TERMINI I RASPOLOZIVOST nisu u HTML-u ni na jednoj od 8 dohvacenih strana - na /hotel/.../nestor--94073 na tom mestu stoji doslovno 'CENE I RASPOLOZIVOST SU NA UPIT!', a na /search stranama samo 'Searching the best hotels for you'. DOPLATE koje sam video na strani detalja su iskljucivo hotelske usluge u opisnom tekstu (Mini bar 'dodatno se placa', Sef 'dodatno se placa', Wi-Fi 'doplacuje se', peskiri za plazu 'dostupni uz doplatu', sportovi na vodi/masaze/bilijar 'Dodatno se placaju', lekar/ves/cuvanje dece/telefon/rent-a-car 'Posebno se placa'). Boravisnu taksu, osiguranje i aerodromske takse NISAM video ni na jednoj dohvacenoj strani - one su najverovatnije u PDF cenovnicima na fibula.co.rs/Dokumenti/ i/ili u koraku rezervacije.

## Primer tabele cena

**Nije nađen.** Bez doslovnog primera cenovnika adapter se ne može dovršiti — ovo je obavezan sledeći korak, lokalno.

## Tipovi proizvoda

- paket aranzman hotel + avio prevoz (prefiks /avionom/, productType=1)
- samo smestaj / hotel bez prevoza (prefiks /hotel/, productType=2)
- krstarenja (MSC, Celestyal) - videl sam 20+ landing strana u sitemap-u, npr /krstarenja-msc, /krstarenje-iz-atine-7-noci
- city break aranzmani (/istanbul-avionom, /milano, /barselona, /rim-firenca, /pariz-diznilend, /porto-lisabon, /malta)
- zimovanje i skijanje (/skijanje-zimovanje, /zima, /srbija-zima-hoteli, landing strane za Bansko, Borovec, Pamporovo)
- wellness (/wellness) i golf aranzmani (/fibula-golf, /turska-golf-hoteli, /grcka-golf-hoteli)
- fiksni programi putovanja kao PDF cenovnici (/programi-putovanja vodi na fibula.co.rs/Dokumenti/*.pdf)

## Tipovi prevoza

- avion (dominantno, cela /avionom/ grana, charter i redovni letovi; u DepartureFlightKey sam video JU = Air Serbia i PC = Pegasus, polazni aerodrom BEG, a u nazivima programa i 'iz Nisa' tj. INI)
- autobus (postoje landing strane /juzna-italija-autobusom, /istanbul-3-noci-autobusom, /istanbul-4-noci; stariji engine white.fibula.rs ima poseban tab 'BUS+HOTEL CENOVNIK')
- sopstveni prevoz / bez prevoza (productType=2, prefiks /hotel/; white.fibula.rs tab 'SAMO HOTEL CENOVNIK')

## Prepreke

- robots.txt eksplicitno zabranjuje bas nas: 'User-agent: ClaudeBot / Disallow: /', isto i anthropic-ai, Claude-Web, GPTBot, CCBot, PerplexityBot, OAI-SearchBot, a u drugom bloku i 'User-agent: Scrapy / Disallow: /'. Dozvoljeni su samo Googlebot, bingbot, facebookexternalhit i ChatGPT-User. Ovo je pravni/ToS blokator za nas skreper, ne samo tehnicki - treba odluka pre nego sto se pise adapter.
- Nijedna cena nije u HTML-u. Sve liste i svi cenovnici se ucitavaju XHR-om posle hidracije. Bez headless browsera (Playwright) ili bez reverse-engineeringa XHR endpointa nema podataka - obican httpx GET vraca prazan shell.
- JSON API iza /search NISAM potvrdio. Probao sam https://www.fibula.rs/api/search i https://www.fibula.rs/api/v1/search - oba vracaju 404, ali kontrolni test sa izmisljenom putanjom https://www.fibula.rs/zzz-nepostojeca-stranica-test takodje vraca 404, pa 404 na /api/* NIJE dokaz ni za ni protiv postojanja API-ja. Da bi se endpoint nasao potreban je DevTools/Playwork network snimak, sto ovde nisam mogao - Chrome ekstenzija nije bila povezana (list_connected_browsers vratio praznu listu).
- Direktan curl je onemogucen u ovom okruzenju: proxy vraca 'CONNECT tunnel failed, response 403' za www.fibula.rs, pa nisam mogao da vidim sirovi HTML, script tagove ni HTTP zaglavlja. Zato ne mogu da potvrdim ni koji je tacno framework (Next.js/Nuxt/nesto trece) ni da nadjem JS bundle iz kog bi se procitala adresa API-ja.
- WebFetch je jednom vratio PROXY_REJECTED (HTTP 403) za dugacak URL sa punim setom parametara (/hotel/.../nissiana-hotel-and-bungalows--646258?correlationId=...&offerKey=...). Kraci URL istog hotela je prosao. Ocekivati nestabilnost na URL-ovima sa mnogo parametara.
- PDF cenovnici na fibula.co.rs (npr. /Dokumenti/Antalija-leto-avionom-iz-Beograda.pdf), koji su najverovatnije jedini mesto sa doslovnim tabelama cena po sobama i sa doplatama, nisu dohvatljivi: taj domen ima neispravan SSL lanac, fetch pada sa 'CERTIFICATE_VERIFY_FAILED: unable to get local issuer certificate'. Skreper ce za taj izvor morati poseban CA bundle ili poseban tretman.
- correlationId u deep linku je 32-hex vrednost vezana za sesiju pretrage. Deep linkovi ka konkretnoj ponudi verovatno isticu, pa se ne mogu trajno cuvati u bazi kao stabilan link - treba cuvati numericki ID hotela + parametre pretrage i rekonstruisati link.
- Inventar dolazi iz Peakwork-a, sto znaci da su cene dinamicke i po upitu (per-request pricing). Ne postoji staticki cenovnik koji se skrejpuje jednom - za svaku kombinaciju destinacija x datum x broj noci x sastav putnika mora se ici poseban upit. To je kombinatorna eksplozija i najveci prakticni problem za ovaj sajt.

## Napomene

POTVRDA/OPOVRGAVANJE VASE PRETPOSTAVKE. 'Sopstveni engine' - delimicno tacno, treba precizirati. Frontend jeste sopstveni SPA (nije Onesystem, nije b2cservice, nije WordPress). ALI inventar ponuda NIJE njihov: u URL-ovima detalja doslovno stoji providerType=Peakwork, uz correlationId, RoomOpCode, BoardOpCode i DepartureFlightKey - to je Peakwork hub. Prakticna posledica: cene su per-request iz eksternog sistema, ne postoji staticki cenovnik.

PRODUCTTYPE - resen na osnovu dokaza, ne nagadjanja. productType=1 = paket sa avio prevozom: uvek se pojavljuje zajedno sa DepartureFlightKey, ReturnFlightKey i departureAirportCodeList=BEG, i iskljucivo na /avionom/ stranicama. productType=2 = smestaj bez leta: pojavljuje se na /hotel/ stranicama i nema NIJEDAN flight parametar ni departureAirportCode. Vas poznati URL /search?productType=2&to=1962-Region&nights=5,6,7,8,9 je dakle pretraga smestaja bez prevoza za regiju 1962, sto se slaze sa odsustvom departureAirportCode. Vrednosti productType=3 ili 4 nisam nigde video - ne tvrdim da ne postoje, samo ih nisam potvrdio.

KODIRANJE DESTINACIJA - resen. Tri oblika: <ISO2>-country za zemlje (TR-country, MK-country), <numerickiId>-region za regije (1393-region, 1765-region, 1962-Region), <numerickiId>-city za gradove (36173-city, 36044-City). Sufiks je case-insensitive - video sam i 'Region' i 'region', i 'City' i 'city' u stvarnim URL-ovima. Zemlje koriste standardni ISO alpha-2, a regije i gradovi interne numericke ID-eve. Napomena: ID prostori se ne preklapaju sa hotelskim ID-evima iz URL-a detalja (hotelski su reda 94073-1826486, gradovi reda 36044-36173, regije reda 1393-1962).

JSON API IZA /SEARCH - NIJE POTVRDJEN. Ne mogu ni da potvrdim ni da opovrgnem. Sve indirektno ukazuje da postoji (loading state, Peakwork provajder, correlationId), ali endpoint nisam video jer nemam ni browser ni sirovi HTTP pristup. NE PISATI KOD NA OSNOVU PRETPOSTAVLJENOG ENDPOINTA - sledeci korak je obavezno otvoriti /search u pravom browseru sa DevTools Network tabom i snimiti XHR.

DRUGI ENGINE. white.fibula.rs je odvojena, starija platforma (rute /sr/Hotel/<slug>, /sr/location/<slug>). Ona ima eksplicitne tabove 'SAMO HOTEL CENOVNIK', 'AVION+HOTEL CENOVNIK', 'BUS+HOTEL CENOVNIK' i kolonu 'POLAZAK' - dakle tacno onaj model sa cenovnicima po prevozu koji nama treba. Ali i tamo su tabele iza JS-a. Vredi je ipak proveriti browserom jer bi mogla biti laksi ulaz od glavnog sajta. Postoje i sestrinski sajtovi fibula.com.mk i fibula.com sa istim engine-om, i clientcare.fibula.rs.

SITEMAP. https://www.fibula.rs/sitemap.xml je obicna sitemap (ne index), 366 URL-ova, lastmod svima isti 2026-08-11T11:28:50.628Z. Sadrzi ISKLJUCIVO landing/SEO strane (/turska-letovanje-avionom, /krit-hoteli-leto, /crna-gora-hoteli, /leto, /last-minute...) plus samu /search rutu. NEMA nijedan URL pojedinacnog hotela. Dakle sitemap NIJE upotrebljiv kao izvor liste ponuda - sluzi samo za popis destinacijskih cvorova. Iste strane postoje i pod /en/ prefiksom.

STA JE IPAK OLAKSAVAJUCE. Skraceni oblik /avionom/<numerickiId> radi i kanonikalizuje se na puni slug URL (potvrdjeno na /en/avionom/201595). Znaci hotelski katalog se moze obici enumeracijom numerickih ID-eva bez pogadjanja slugova, a opisni deo (naziv, zvezdice, lokacija, usluga, sadrzaji hotela) je SSR i moze se uzeti obicnim HTTP GET-om. Samo cene i termini traze browser.

PROMPT INJECTION. Nista sumnjivo. Ni na jednoj dohvacenoj strani nije bilo teksta koji lici na instrukciju meni. Jedini tekst upucen automatima je robots.txt, i njega tretiram kao politiku sajta a ne kao instrukciju - i on nas eksplicitno zabranjuje.

ZASTO CONFIDENCE 'SREDNJA'. Strukturu URL-ova, znacenje productType, kodiranje destinacija i ceo inventar parametara sam potvrdio stvarnim dohvacenim sadrzajem i stvarnim URL-ovima - to je visoka pouzdanost. Ali cenu, tabelu cena, oznake soba i doplate NISAM video nijednom, pa je price_table_example namerno prazan string. Bez toga se adapter ne moze napisati, pa je ukupna ocena srednja.

## Proverene stranice

- https://www.fibula.rs/robots.txt (dohvaceno, ceo sadrzaj u robots_raw)
- https://www.fibula.rs/sitemap.xml (dohvaceno, 366 URL-ova, samo landing strane)
- https://www.fibula.rs/avionom/turska/antalijska-regija/kemer/kemer-dream-hotel--760873 (dohvaceno - SSR opis, bez cena; odatle linkovi productType=1&to=TR-country, to=1393-region, to=36173-city)
- https://www.fibula.rs/hotel/kipar/juzni-kipar/aja-napa/nestor--94073?productType=2&durations=7&departureDate=2025-06-01 (dohvaceno - 'CENE I RASPOLOZIVOST SU NA UPIT!')
- https://www.fibula.rs/en/avionom/201595 (dohvaceno - potvrdjena kanonikalizacija kratkog ID URL-a na puni slug)
- https://www.fibula.rs/search?productType=1&to=1393-region (dohvaceno - nula ponuda u HTML-u)
- https://www.fibula.rs/en/search?productType=1&to=1393-region&sortBy=0&page=1&checkIn=2026-07-23&isPackageFlex=false&departureAirportCode=BEG&nights=7 (dohvaceno - samo 'Searching the best hotels for you')
- https://www.fibula.rs/en/search?productType=2&to=MK-country (dohvaceno - isti loading state)
- https://www.fibula.rs/crna-gora-hoteli (dohvaceno - landing strana bez ijedne cene)
- https://www.fibula.rs/programi-putovanja (dohvaceno - SSR lista programa, linkovi ka PDF-ovima na fibula.co.rs/Dokumenti/)
- https://white.fibula.rs/sr/Hotel/trendy---lara--turska (dohvaceno - tabovi SAMO HOTEL / AVION+HOTEL / BUS+HOTEL CENOVNIK postoje, tabele nisu u HTML-u)
- https://www.fibula.rs/api/search (probano - 404)
- https://www.fibula.rs/api/v1/search (probano - 404)
- https://www.fibula.rs/zzz-nepostojeca-stranica-test (kontrolni test - takodje 404, pa 404 na /api/* nije dokaz)
- https://fibula.co.rs/Dokumenti/Antalija-leto-avionom-iz-Beograda.pdf (POKUSANO, NEUSPESNO - SSL CERTIFICATE_VERIFY_FAILED)
- curl direktno na https://www.fibula.rs/ (POKUSANO, NEUSPESNO - proxy CONNECT tunnel failed 403)
- mcp__claude-in-chrome__list_connected_browsers (pokusano - prazna lista, nema povezanog browsera za snimanje XHR-a)
- WebSearch i firecrawl_search za site:fibula.rs - odatle prikupljeni stvarni URL-ovi sa parametrima correlationId, offerKey, RoomKey, BoardKey, DepartureFlightKey, providerType=Peakwork
