# Big Blue (Big Blue Group, Beograd) — bigblue.rs

Recon: 15.08.2026. · Pouzdanost: **srednja** · Težina: **5/5** · Dohvaćeno: **da**

> Generisano automatski iz recon izveštaja. Prijavljeno je samo ono što je agent stvarno
> video u dohvaćenom sadržaju. Prazno polje znači da nije provereno, **ne** da ne postoji.

## Platforma

**TourVisio B2C (vendor: Tourism Software Group) — ASP.NET backend + AngularJS frontend; NIJE WordPress i nije Onesystem**

1) robots.txt zabranjuje /*.asmx i /*.ashx — ASP.NET Web Services, tj. XHR sloj. 2) Na /sr/glavna/ u dohvacenom sadrzaju stoji referenca na 'Tourism Software Group' (vendor) i verzija '1.0.14.0'. 3) Sve strane su pune AngularJS izraza tipa {{hotel.name}}, {{priceSearchCriteria.night}}, {{offer.rooms[0].boardName}}. 4) Postoji online.bigblue.rs koji se u pretrazi prikazuje kao 'Login | TourVisio B2B'. 5) Isti engine potvrdjen na drugim agencijama: kontiki.rs/sr/hotel/turska/kusadasi/beks-premium-resort---spa/ i filiptravel.rs/sr/hotel/turska/alanja/sirius-deluxe/ — identicna putanja /sr/hotel/{drzava}/{mesto}/{slug}/. Hipoteza 'deli engine sa kontiki.rs' je POTVRDJENA.

## Pravni status

robots.txt dohvaćen: **da**
Blokira nas: **DA**

```
User-agent: *
Allow:*
Disallow: /*.asmx
Disallow: /*.ashx


Sitemap: http://b2c.bigblue.rs/Sitemap.xml
```

## Sitemap

- https://bigblue.rs/sitemap.xml

## Renderovanje

**XHR**

Ni na jednoj dohvacenoj strani (lista /sr/packages/srbija~beograd~turska~side/, /sr/location/kusadasi/, detalj /sr/hotel/turska/alanja/lonicera-world-hotel/, /sr/hotel/amerika/majami/1-south-beach/) nije bilo NIJEDNE konkretne cene u HTML-u — samo neizrenderovani Angular placeholderi: 'Cene od {{roomCount}}', {{hotel.offers[0].rooms[0].roomName}}, {{hotel.offers[0].checkIn | firmDate}}, {{pagingdata.productCount}}. Glavna navigacija na /sr/glavna/ koristi javascript:void(0). Zakljucak: SSR ne postoji za cene, sve dolazi iz XHR-a posle boot-a Angular aplikacije.

## URL-ovi liste

- https://bigblue.rs/sr/packages/srbija~beograd~turska~side/
- https://bigblue.rs/sr/packages/srbija~beograd~grcka~skopelos/
- https://bigblue.rs/sr/packages/srbija~beograd~kiparska-republika~protaras/
- https://bigblue.rs/sr/packages/srbija~beograd~kiparska-republika~pafos/
- https://bigblue.rs/sr/packages/srbija~beograd~turska~fetije/
- https://bigblue.rs/sr/location/kusadasi/
- https://bigblue.rs/sr/location/turska/
- https://bigblue.rs/sr/location/grcka/
- https://bigblue.rs/sr/location/krf/
- https://bigblue.rs/sr/location/kemer/
- https://bigblue.rs/sr/location/bodrum/
- https://bigblue.rs/sr/location/egipat/
- https://bigblue.rs/sr/location/kosta-brava---kosta-maresme/

## Šablon URL-a detalja

https://bigblue.rs/sr/hotel/{drzava-slug}/{mesto-slug}/{hotel-slug}/  — potvrdjeni primeri: /sr/hotel/turska/alanja/lonicera-world-hotel/, /sr/hotel/turska/alanja/incekum-su-hotel/, /sr/hotel/turska/kusadasi/double-tree-by-hilton-kusadasi/, /sr/hotel/amerika/majami/1-south-beach/. Postoji i varijanta bez mesta: /sr/hotel/rotator/{slug}/ (npr. /sr/hotel/rotator/solun/) koja je kuratorska/rotator lista. Deep-link na konkretnu ponudu ide preko ?PL= — video sam u divljini ?PL=25516-93-1533-4615336 i ?PL=... na /sr/hotel/turska/side/barut-b-suites i /sr/hotel/turska/fetije/letoonia-club---hotel-hv-1

## Query parametri

- SearchType=tip pretrage (paket/hotel); /sr/search-router/ vraca HTTP 500 na moje kombinacije, dakle ruta POSTOJI ali trazi drugacije parametre (404 bi znacilo da rute nema)
- PL=deep-link na konkretnu ponudu/cenovnik, cetvorodelni ID (primer: PL=25516-93-1533-4615336)
- CheckIn=datum prijave (probano 2026-09-01)
- Night=broj noci (na sajtu vidjeno 7, 10, 11 kao tipicne vrednosti)
- R1Adult=broj odraslih u sobi 1 (R{n}Adult sugerise vise soba)
- HpCode=nije potvrdjen — nisam ga video ni u jednom dohvacenom URL-u
- Criteria=nije potvrdjen — nisam ga video ni u jednom dohvacenom URL-u

## Paginacija

Nije vidjena klasicna numerisana paginacija u HTML-u. Lista renderuje broj rezultata kroz {{pagingdata.productCount}}, sto ukazuje na klijentski 'pagingdata' objekat koji se puni iz XHR-a (verovatno infinite scroll ili 'prikazi jos'). Bez izvrsavanja JS-a paginacija se ne moze utvrditi.

## Gde su podaci

NEMAM CSS selektore jer stranice stizu kao neizrenderovan Angular template. Ali sam video doslovne Angular bind-putanje, koje su de-facto model podataka JSON odgovora:
- lista: hotel.name, hotel.hotelCategory.name (zvezdice), hotel.offers[0].rooms[0].roomName, hotel.offers[0].rooms[0].boardName (usluga), hotel.offers[0].checkIn (filter 'firmDate'), hotel.offers[0].night, GetDiscountRate(hotel.offers[0]), pagingdata.productCount, destination.count (fasete)
- detalj: room.roomName, offer.rooms[0].boardName, offer.flightClassName (klasa leta), offer.checkIn, data.rooms[0].boardName, data.flightClassName, getRoomCount(), getAdultCount(), getChildCount()
- kriterijum pretrage: priceSearchCriteria.night, priceSearceCriteria.adult, priceSearchCriteria.childAges (niz uzrasta dece!), priceSearchCriteria.departureLocations[0].name
- otkazne skale: condition.dueDate, condition.beginDate, condition.price.percent
- valuta: findSelectedCurrency().code
Sortiranje na listi (tekst dugmadi): 'Cena rastuće', 'Cena opadajuća', 'Ime', 'Star Ascending', 'Star Descending'.

## Primer tabele cena

```
NAPOMENA O POREKLU: ovaj isecak NIJE sa bigblue.rs HTML-a (tamo cena nema bez JS-a), nego iz PDF-a 'Cena detaljno' koji generise isti engine i koji u zaglavlju linkuje na www.bigblue.rs/sr/hotel/turska/alanja/kleopatra-life-hotel (hostovan na travelingo.rs). Doslovno:

"Cenovnik broj: 30598 - 30972 - 30961"
"noći | Prijava | Odjava | Status"
"STANDARDNA SOBA | ALL INCLUSIVE
 Dvokrevetna po osobi: 703 | 1006 | 703"
"STANDARD SIDE-LATERAL SEA VIEW | ALL INCLUSIVE
 Dvokrevetna po osobi: 712 | 1025 | 712"
"Prvo dete 2.00-9.99: 339"
"CENE SU IZRAŽENE U EVRIMA PO OSOBI"
```

## Tipovi proizvoda

- letovanje (Grcka, Turska, Kipar, Egipat, Tunis, Spanija, Emirati, Crna Gora, Hrvatska)
- evropske metropole
- kruzne ture (npr. 'Andaluzijska tura', 'Krit i Santorini')
- krstarenja ('Krstarenje Dunavom')
- wellness & spa
- domace destinacije / zimovanje (Kopaonik, Zlatibor, Vrnjacka Banja, Bajina Basta — vidjeno u sitemap.xml)

## Tipovi prevoza

- avio (direktan / carter let — 'Direktan čarter let', 'uz avio prevoz', 'sa uključenom avio kartom, prtljagom do 20kg')
- sopstveni prevoz (postoji zasebna sekcija /sr/grcka-sopstveni-prevoz/)

## Prepreke

- Cene NE postoje u HTML-u. Bez headless browsera (Playwright) adapter ce tiho vracati 0 cena — klasican tihi kvar. HTTP-only pristup sa httpx je ISKLJUCEN za cene.
- robots.txt eksplicitno zabranjuje /*.asmx i /*.ashx, a to je upravo XHR/JSON sloj iz kog cene dolaze. Direktno gadjanje tog API-ja krsi robots. WebFetch mi je bas zbog toga odbio .asmx URL. Preporuka: renderovati javne HTML strane headless browserom (one su 'Allow'), a NE pozivati .asmx direktno — ili traziti pismenu dozvolu agencije.
- Nisam uspeo da uhvatim stvarni XHR endpoint ni payload: egress proxy u ovom okruzenju vraca 403 na CONNECT za bigblue.rs (curl nemoguc), WebFetch strip-uje <script> tagove pa nisam video JS bundle, a claude-in-chrome zahteva interaktivan izbor browsera koji ovde nije dostupan. Ime endpointa i oblik JSON-a su NEPOZNATI.
- Sitemap iz robots.txt (b2c.bigblue.rs) je mrtav (404). Radni https://bigblue.rs/sitemap.xml sadrzi samo CMS/destinacijske strane — NIJEDAN /sr/hotel/ URL. Znaci ne postoji sitemap za otkrivanje hotela; listu hotela treba graditi obilaskom /sr/location/ i /sr/packages/ strana posle renderovanja.
- /sr/search-router/ vraca 500 na moje parametre — tacan potpis parametara nije utvrdjen.
- Doplate (boravisna taksa, osiguranje) nisam potvrdio kao zasebne stavke. Na strani detalja video sam samo otkazne skale ({{condition.price.percent}}, 'Nije podležno refundaciji') i opsti tekst da se dodatno placaju masaza, lekar, frizer, vodeni sportovi, pranje vesa. Da li se taksa/osiguranje prikazuju tek u koraku rezervacije — NEPROVERENO.

## Napomene

POTVRDJENO iz hipoteze: /sr/hotel/ postoji; deljeni engine sa kontiki.rs postoji (a i sa filiptravel.rs); poddomen postoji ali se zove b2c.bigblue.rs (iz robots.txt) i putovanja.bigblue.rs (mirror), plus online.bigblue.rs kao TourVisio B2B login. OPOVRGNUTO/NEPOTVRDJENO: newcms.bigblue.rs nisam uspeo da potvrdim; 'b2cservice' kao ime platforme nisam video nigde — engine je TourVisio od Tourism Software Group; /sr/search-router/ postoji ali vraca 500; HpCode i Criteria nisam video ni u jednom stvarnom URL-u.

VAZNO ZA MODEL PODATAKA — PDF 'Cena detaljno' pokazuje da engine drzi tacno ono sto nam treba: cena je PO OSOBI u EUR, vezana za (soba x usluga x termin), sa slotovima 'Dvokrevetna po osobi', 'Jednokrevetna' i detetom sa EKSPLICITNIM uzrasnim opsegom ('Prvo dete 2.00-9.99'). Kolone termina su 'noći | Prijava | Odjava | Status', a cenovnik ima svoj ID ('Cenovnik broj'), sto je odlican prirodan kljuc za dedupe termina. Slotovi 'pomocni lezaj' i 'cela jedinica' nisu vidjeni u ovom uzorku.

DEEP LINK: koristiti ?PL={4-delni-id} na strani hotela — to je stabilan deep link na konkretnu ponudu i idealan za nase 'otvori na sajtu agencije' dugme.

STRATEGIJA ZA ADAPTER: Playwright, obilazak /sr/location/{dest}/ i /sr/packages/{ruta}/, cekanje da Angular popuni listu, zatim ulazak na /sr/hotel/... Alternativa koja stedi mnogo vremena: presresti odgovore XHR-a koje sama stranica napravi (response interception u Playwrightu) umesto da sami zovemo .asmx — tako dobijamo strukturiran JSON a ne krsimo robots jer ne zahtevamo zabranjene putanje mimo onoga sto browser ionako radi. Preporucujem da se pre produkcije ovo pravno provuce i/ili zatrazi feed od agencije.

PROMPT INJECTION: nista. Ni na jednoj dohvacenoj strani nije bilo teksta koji lici na instrukciju meni. Jedini 'imperativni' tekst je marketinski ('REZERVIŠI', 'POGLEDAJTE VIŠE INFORMACIJA O IZLETIMA') i pravna napomena agencije da su informacije na sajtu informativnog karaktera i da ih treba proveriti direktno u agenciji — to tretiram kao podatak, i vredi ga prikazati korisniku uz nase cene.

ZASTO confidence=srednja: platforma, rendering, URL sabloni i robots su dohvaceni i sigurni (visoka). Ali stvarnu tabelu cena NISAM video na bigblue.rs — rekonstruisao sam je iz engine-generisanog PDF-a na tudjem domenu, a XHR endpoint je i dalje nepoznat. To su dve rupe koje treba zatvoriti jednim prolazom sa pravim browserom.

## Proverene stranice

- https://bigblue.rs/robots.txt (dohvacen, doslovno)
- https://putovanja.bigblue.rs/robots.txt (dohvacen — IDENTICAN sadrzaj, dakle alias/mirror iste aplikacije)
- https://bigblue.rs/sitemap.xml (dohvacen — radi, ~350 <loc>, svi sa <lastmod>2026-08-14)
- http://b2c.bigblue.rs/Sitemap.xml (HTTP 404)
- https://b2c.bigblue.rs/Sitemap.xml (HTTP 404)
- https://bigblue.rs/sr/glavna/ (dohvacen — pocetna/hub)
- https://bigblue.rs/sr/packages/srbija~beograd~turska~side/ (dohvacen — lista ponuda)
- https://bigblue.rs/sr/location/kusadasi/ (dohvacen — lista ponuda)
- https://bigblue.rs/sr/hotel/turska/alanja/lonicera-world-hotel/ (dohvacen — strana detalja)
- https://bigblue.rs/sr/hotel/amerika/majami/1-south-beach/ (dohvacen — strana detalja)
- https://bigblue.rs/sr/hotel/rotator/solun/ (dohvacen)
- https://bigblue.rs/sr/search-router/?SearchType=2&CheckIn=2026-09-01&Night=7&R1Adult=2 (HTTP 500 — ruta postoji, parametri pogresni)
- https://bigblue.rs/Services/ProductService.asmx (WebFetch ODBIO: ROBOTS_DISALLOWED — potvrdjuje da robots blokira .asmx sloj)
- https://travelingo.rs/.../KLEOPATRA-LIFE-HOTEL-...pdf (dohvacen — engine-generisani 'Cena detaljno' PDF, izvor price_table_example)
- WebSearch + firecrawl_search: site:bigblue.rs upiti, potvrda kontiki.rs i filiptravel.rs identicne /sr/hotel/ strukture, online.bigblue.rs = 'Login | TourVisio B2B'
