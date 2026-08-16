# 1 A Travel — 1atravel.rs

Recon: 15.08.2026. · Pouzdanost: **srednja** · Težina: **4/5** · Dohvaćeno: **da**

> Generisano automatski iz recon izveštaja. Prijavljeno je samo ono što je agent stvarno
> video u dohvaćenom sadržaju. Prazno polje znači da nije provereno, **ne** da ne postoji.

## Platforma

**Onesystem**

POTVRDJENO, cetiri nezavisna dokaza: (1) na /kontakt/ vidljiva putanja slike u footeru 'https://1atravel.rs/wp-content/themes/onesystem_wp_theme/core/includes/onesystem-powered.png' - dakle i onesystem_wp_theme i onesystem-powered.png tacno kako je hipoteza tvrdila; (2) footer link 'https://onesystem.online/' sa alt tekstom 'Powered by Onesystem'; (3) robots.txt Sitemap pokazuje na 'https://1atravel.rs/wp-admin/admin-ajax.php?action=os_sitemap' - os_ prefiks je Onesystem WP action namespace; (4) na /aranzmana/antalija-turska-2026/ u HTML-u je iscureo doslovan SQL string: 'select distinct pr.packageid,p.post_titlew packagename from onesystem_tourlocation pr' - DB prefiks tabela je onesystem_. Dodatno, nasao sam drugi tenant iste platforme sa identicnom URL semom (/destinacija/, /putovanje/): wwwtest.onesystem.online (Ponte Travel), sto potvrdjuje da jedan adapter pokriva vise agencija.

## Pravni status

robots.txt dohvaćen: **da**
Blokira nas: **ne**

```
User-agent: *
Disallow: /wp-admin/
Allow: /wp-admin/admin-ajax.php
Sitemap: https://1atravel.rs/wp-admin/admin-ajax.php?action=os_sitemap
```

## Sitemap

- https://1atravel.rs/wp-admin/admin-ajax.php?action=os_sitemap

## Renderovanje

**MIXED**

Homepage i /promocije-first-last-minute/ serviraju kartice ponuda vec u HTML-u (cena, destinacija, datum, trajanje). Nasuprot tome /destinacija/turska/ i /aranzmana/antalija-turska-2026/ NE sadrze nijednu karticu ponude - samo formu za pretragu; dohvaceni sadrzaj je imao iskljucivo dropdownove (Zemlja, Destinacija, Polazak iz, Polazak, Trajanje aranzmana, Putnici). Stranica detalja /putovanje/<slug>/ je uredan SSR tekst (opis hotela, polasci, takse) ali BEZ ijedne cene i BEZ tabele cena. Prava lista rezultata je /pretraga-aranzmana/ koju nisam uspeo da dohvatim (500 bez parametara, 403 sa parametrima kroz nas proxy), pa nisam mogao da posmatram ni njen markup ni XHR pozive.

## URL-ovi liste

- https://1atravel.rs/
- https://1atravel.rs/promocije-first-last-minute/
- https://1atravel.rs/destinacija/turska/
- https://1atravel.rs/aranzmana/antalija-turska-2026/
- https://1atravel.rs/pretraga-aranzmana/

## Šablon URL-a detalja

https://1atravel.rs/putovanje/<slug>/ - POTVRDJENO na desetinama stvarnih URL-ova (npr. /putovanje/calimera-yati-beach/, /putovanje/derici-hotel/, /putovanje/hotel-torre-normanna/, /putovanje/president-hotel-palermo/). Postoje i /destinacija/<slug>/ (destinacija, ~728 komada u sitemapu) i /aranzmana/<slug>/ (kategorija/kampanja, npr. antalija-turska-2026, krstarenje-2026, malta-2026). Postoje i jezicke varijante /en/ i /hr/ (npr. /en/destinacija/alanja/) i subdomen subagent.1atravel.rs.

## Query parametri

- departurefromid=polazna tacka, kompozitni Onesystem ID (primer: 40.CTY.20022016.1132.140.1022216014150220841813564)
- countrytermid=zemlja, numericki term ID (primeri: 260, 276)
- citytermid=destinacija/grad, numericki term ID (primeri: 275, 277)
- departuredate=datum polaska u formatu DD/MM/YYYY, URL-enkodovan (primer: 15%2F06%2F2024)
- duration=raspon trajanja u nocima (primeri: 7-7, 6-7)
- hotelduration=trajanje hotelskog dela u nocima (primeri: 7, 6)
- tourduration=trajanje ture u danima (primer: 7)
- adlcount=broj odraslih (primer: 2)
- chdcount=broj dece (primer: 0)
- chdage1=uzrast prvog deteta (primer: 0)
- chdage2=uzrast drugog deteta (primer: 0)
- chdage3=uzrast treceg deteta (primer: 0)
- chdage4=uzrast cetvrtog deteta (primer: 0)

## Paginacija

Nije primecena. Ni homepage ni /promocije-first-last-minute/ nemaju paginaciju niti 'Ucitaj jos' kontrolu u dohvacenom sadrzaju. Paginaciju stranice rezultata /pretraga-aranzmana/ nisam mogao da proverim jer je stranica bila nedohvatljiva. Sitemap nema paginaciju (jedan fajl, bez sitemap indeksa).

## Gde su podaci

VAZNO: nisam video nijedan CSS selektor niti ijedno name= atribut forme, jer je egress politika blokirala direktan curl (403 na CONNECT), a WebFetch vraca konvertovan markdown u kome se atributi gube. Zato dajem samo opisne lokacije, bez izmisljenih selektora.

1) Kartice ponuda (homepage, /promocije-first-last-minute/): svaka kartica nosi naziv hotela, destinaciju velikim slovima, opcioni bedz popusta ('Popust 20%'), istaknutu cenu oblika 'od 757.50 EUR' odnosno 'OD 902 EUR', opcione tagove tipa 'Porodicni Hoteli', 'Hotel gradskog tipa', 'Idealan za mlade', 'Samo odrasli', 'Medeni mesec', link 'Detaljnije' na /putovanje/<slug>/. Na promocijama uz karticu ide i termin: doslovno '19/08/2026    7 noci-8 dana' i '22/08/2026    11 noci-12 dana'.

2) Stranica detalja /putovanje/<slug>/: SSR tekst sa opisom hotela, tipovima soba u proznom tekstu (npr. doslovno 'U oba dela dostupne su standard sobe i standard sea view sobe.'), rasponom polazaka ('18.06. do 24.09.', 'Polasci: cetvrtkom', 'Polasci - sredom'), uslugom ('Ultra All Inclusive', 'polupansion(HB) ili Soft Inclusive (FB)'), i blokom doplata. NEMA cene i NEMA tabele cena na stranici detalja.

3) Cene po sobama NE POSTOJE kao tabela nigde na sajtu. Sajt to i sam pise, doslovan citat sa vise stranica: 'Cena po programu je prikazana kao jedinstvena cena aranzmana koja se pretragom na web sajtu organizatora putovanja dobija nakon unosenja svih trazenih parametara'. Cena je dakle funkcija popunjenosti (adlcount/chdcount/chdage), a ne matrica 1/2, 1/2+1, 1/4, A2/4. Raspored sobe se mora IZVODITI iz kombinacije adlcount+chdcount+chdage, a ne citati sa sajta.

4) ID: na /putovanje/derici-hotel/ u putanjama slika video sam numericki ID hotela 431 (obrazac '431.picture.29042025.1633...'). To je kandidat za stabilan external_id, ali sam ga video samo na jednom hotelu - proveriti na jos nekoliko pre nego sto se oslonimo. Bezbednija varijanta je slug iz /putovanje/<slug>/.

5) Doplate su u slobodnom tekstu na stranici detalja, razlicito formatirane po hotelu - parsiranje regexom po kljucnim recima 'taksa', 'osiguranje', 'viza', 'YQ', 'doplata'.

## Primer tabele cena

**Nije nađen.** Bez doslovnog primera cenovnika adapter se ne može dovršiti — ovo je obavezan sledeći korak, lokalno.

## Tipovi proizvoda

- paket aranzman - letovanje (carter)
- krstarenje

## Tipovi prevoza

- avion

## Prepreke

- Sitemap NE sadrzi nijedan /putovanje/ URL. Dohvatio sam ga i proverio: sve stavke su iskljucivo /destinacija/<slug>/, oko 728 unosa, svaki oblika <url><loc>...</loc><changefreq>daily</changefreq><priority>0.9</priority></url>, bez <lastmod> i bez sitemap indeksa. Znaci discover() se NE moze osloniti na sitemap za ponude.
- Stranica rezultata /pretraga-aranzmana/ nije dohvatljiva iz ovog okruzenja: bez parametara vraca HTTP 500, a sa punim setom parametara nas fetch proxy vraca 403. Zato NISAM video ni markup rezultata, ni XHR endpoint, ni format cene u rezultatima. To je najveca rupa u reconu i mora se zatvoriti pregledom DevTools Network na pravom browseru.
- Ne postoji tabela cena po rasporedu sobe (1/2, 1/2+1, 1/4, A2/4) nigde na sajtu. Cena se dobija samo parametrizovanom pretragom po popunjenosti, kao jedna ukupna cena aranzmana. Da bismo popunili nas model 'cene po rasporedu sobe', moramo izvrsiti N upita po ponudi (termin x popunjenost), sto je kombinatorno skupo i mora se ograniciti na tipicne rasporede.
- Nisam mogao da procitam sirovi HTML (curl blokiran egress politikom, WebFetch daje markdown), pa nemam nijedan CSS selektor ni name= atribut forme. Sve selektore treba izvuci tek nad sacuvanim HTML fixture fajlom.
- Parametri iz hipoteze packagecountryid, packagecityid, packagedeparture, packageduration NISU POTVRDJENI. Vise o tome u notes - ne graditi kod na njima.

## Napomene

OPOVRGAVAM DEO HIPOTEZE O PARAMETRIMA. Hipoteza je navodila packagecountryid, packagecityid, packagedeparture, packageduration. Nisam nasao nijedan dokaz za njih. Sta se desilo, transparentno: u prvom upitu nad homepage-om sam u promptu naveo bas ta cetiri imena kao primer, i ekstraktor mi ih je vratio nazad kao da ih je video, uz izmisljen primer URL-a 'pretraga-aranzmana/?packagecountryid=1749&packagecityid=2382...'. Kada sam taj URL stvarno dohvatio, vratio je HTTP 500. Kada sam zatim postavio isto pitanje NEVODJENO nad /destinacija/egipat/, model je posteno odgovorio 'SAMO LABELE VIDLJIVE' i dao samo srpske labele (Zemlja, Destinacija, Polazak iz, Polazak, Trajanje aranzmana, Putnici), jer se name= atributi gube u markdown konverziji. Pretraga weba za 'packagecountryid' / 'packagecityid' / 'packagedeparture' nije vratila nijedan pogodak nigde na internetu. Zakljucak: ta cetiri imena tretirati kao NEPOTVRDJENA i verovatno netacna.

Sta jeste potvrdjeno: imena parametara u polju query_params poticu iz dva STVARNA URL-a koje je Google indeksirao (naslovi 'Pretraga aranzmana - 1 A Travel turisticka agencija' i 'Pretraga Aranzmana | Letovanje 2026 |'), dakle nezavisno od WebFetch konverzije. Ta dva URL-a se medjusobno slazu u svih 13 imena, i adlcount/chdcount/chdage1-4 se poklapaju i sa labelama forme koje sam video. Ipak, oba indeksirana URL-a nose datume iz 2024, pa postoji mogucnost da je sema u medjuvremenu menjana - proveriti pre pisanja koda.

DOPLATE - doslovni citati sa stranica detalja, ovo je najvredniji deo za surcharges model:
- /putovanje/hotel-torre-normanna/: 'Obaveznu gradsku komunalnu taksu...5* - 5 EUR, 4* - 4,5 EUR, 3* - 4 EUR po osobi po danu' (placa se u hotelu, dakle payable=ON_SITE, i iznos ZAVISI OD KATEGORIJE HOTELA); 'AirSerbia - 50 EUR (ukupno 29 EUR taksa aerodroma Nikola Tesla, 21 EUR taksa aerodroma u Palermu, YQ je promenljiva)'; 'Deca do 2 godine placaju 50 EUR'.
- /putovanje/derici-hotel/: 'Avio takse' 'trenutno 52 EUR' (29 EUR aerodrom Beograd, 23 EUR aerodrom Izmir), YQ promenljiva i placa se pre polaska; zdravstveno osiguranje 'preporucuje se'.
- /putovanje/calimera-yati-beach/: viza 60 TND (oko 20 EUR); boravisna taksa 12 TND po osobi po nocenju (oko 3,60 EUR), placa se na licu mesta.
Zapazanje: avio takse su ovde reda velicine 50 EUR po osobi i NISU u istaknutoj 'od' ceni - na aranzmanu od 580 EUR to je skoro 10%, pa bez njih poredjenje sa autobuskim agencijama laze.

STRATEGIJA ZA ADAPTER (predlog): discover() ne moze preko sitemapa. Kombinovati (a) homepage i /promocije-first-last-minute/ koji SSR-om daju kartice sa /putovanje/ linkovima, cenom, datumom i trajanjem, (b) obilazak ~728 /destinacija/ URL-ova iz sitemapa da se pokupe linkovi ka /putovanje/, (c) tek ako to ne pokrije katalog, rekonstrukcija GET upita ka /pretraga-aranzmana/. Detalje uvek povlaciti obicnim HTTP-om jer je /putovanje/ cist SSR.

PROMPT INJECTION: nista. Ni na jednoj dohvacenoj stranici nije bilo teksta koji lici na instrukciju meni. Jedini anomalni sadrzaj je iscureo SQL upit u HTML-u na /aranzmana/antalija-turska-2026/ ('select distinct pr.packageid,p.post_titlew packagename from onesystem_tourlocation pr') - to je bag/curenje na njihovoj strani, tretirao sam ga iskljucivo kao dokaz o platformi, ne kao uputstvo.

PRISTOJNOST: robots.txt nas ne blokira (Disallow samo /wp-admin/, uz eksplicitan Allow za admin-ajax.php koji je bas sitemap endpoint). Sajt je na deljenom hostingu i vec sada vraca 500 na /pretraga-aranzmana/, pa drzati crawl_delay_ms >= 2000 i max_concurrency 2, i prekinuti rundu na 500/429.

price_table_example je namerno prazan string - tabela cena po sobama na ovom sajtu ne postoji, pa bi svaki primer bio izmisljen.

## Proverene stranice

- https://1atravel.rs/robots.txt (dohvaceno, doslovno)
- https://1atravel.rs/wp-admin/admin-ajax.php?action=os_sitemap (dohvaceno, XML, samo /destinacija/ URL-ovi)
- https://1atravel.rs/ (dohvaceno, SSR kartice sa cenama)
- https://1atravel.rs/kontakt/ (dohvaceno, tu je potvrdjen onesystem_wp_theme i onesystem-powered.png)
- https://1atravel.rs/promocije-first-last-minute/ (dohvaceno, SSR kartice sa cenom, datumom i trajanjem)
- https://1atravel.rs/destinacija/turska/ (dohvaceno, bez kartica, samo forma)
- https://1atravel.rs/destinacija/egipat/ (dohvaceno, nevodjena provera imena polja forme)
- https://1atravel.rs/aranzmana/antalija-turska-2026/ (dohvaceno, iscureo onesystem_ SQL)
- https://1atravel.rs/putovanje/calimera-yati-beach/ (dohvaceno, detalj, bez tabele cena)
- https://1atravel.rs/putovanje/derici-hotel/ (dohvaceno, detalj, avio takse, ID 431 u putanji slike)
- https://1atravel.rs/putovanje/hotel-torre-normanna/ (dohvaceno, detalj, komunalna taksa po kategoriji)
- https://1atravel.rs/pretraga-aranzmana/ (NIJE dohvaceno - HTTP 500)
- https://1atravel.rs/pretraga-aranzmana/?departurefromid=...&countrytermid=276&citytermid=277&departuredate=28%2F12%2F2024&duration=6-7... (NIJE dohvaceno - proxy 403; ali sam URL je stvaran, iz Google indeksa, i iz njega su izvedena imena parametara)
- https://1atravel.rs/kako-napraviti-online-rezervaciju/ (NIJE dohvaceno - HTTP 404 i sa www i bez www)
- WebSearch: site:1atravel.rs letovanje 2026 cene
- WebSearch: "pretraga-aranzmana" packagecountryid packagedeparture packageduration (otkrilo dva stvarna indeksirana search URL-a)
- WebSearch: "packagecountryid" OR "packagecityid" OR "packagedeparture" travel (nula pogodaka - osnov za opovrgavanje hipoteze)
- WebSearch: "onesystem.online" powered turisticka agencija (otkrilo drugi tenant wwwtest.onesystem.online / Ponte Travel)
- firecrawl_search: 1atravel.rs putovanje hotel cenovnik letovanje
- curl direktno na 1atravel.rs (BLOKIRANO egress politikom, CONNECT 403 - zato nema sirovog HTML-a ni selektora)
