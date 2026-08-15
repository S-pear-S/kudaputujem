# CLAUDE.md — kontekst projekta "Kuda putujem"

> Ovaj fajl je jedini izvor istine o tome gde smo stali. Pročitaj ga u celini pre prve izmene.
> Ako nešto u kodu protivreči ovom fajlu, prvo pitaj — ne pretpostavljaj da je fajl zastareo.
> Kad doneseš novu odluku ili završiš veću stavku, **ažuriraj ovaj fajl u istom commit-u**.

Poslednje ažuriranje: 15.08.2026. (build fix)
Repo: `https://github.com/S-pear-S/kudaputujem` · grana `main`

---

## 1. Šta gradimo

Metapretraživač ponuda **srpskih turističkih agencija**. Korisnik unese destinaciju, datume,
broj putnika i raspored po sobama, a mi mu pokažemo ponude svih agencija na jednom mestu i
pošaljemo ga dalje.

Tri tipa proizvoda od početka:

| Tip | Šta je | Primer |
|---|---|---|
| `PACKAGE` | aranžman: smeštaj + prevoz, ili smeštaj sa opcijom sopstvenog prevoza | Hotel na Sitoniji + bus iz Beograda |
| `TRANSPORT` | samo prevoz | autobuska karta Beograd–Budva |
| `ACCOMMODATION` | samo smeštaj | apartman u Paraliji bez prevoza |

Tržište: **samo Srbija** u prvoj fazi. Model podataka ima `market`, `currency` i `locale` kolone
da se kasnije doda region bez migracije šeme.

### Šta NAS RAZLIKUJE od konkurencije

Postoje `travelist.rs` i `putujsigurno.rs`, ali oni su **direktorijumi agencija** — spisak firmi
i članci. Niko u Srbiji ne radi pretragu **preko svih agencija po datumu, broju putnika i
rasporedu po sobama**. To je slobodan prostor i to je ceo poduhvat.

### Poslovni model

Metapretraživač + **lead forma**. Korisnik ostavlja kontakt kod nas, mi prosleđujemo agenciji.
Nema plaćanja i nema rezervacije na našem sajtu — to bi tražilo licencu organizatora putovanja
i garancije putovanja po Zakonu o turizmu.

---

## 2. Kako komunicirati sa korisnikom

Korisnik: **kruska** (GitHub `S-pear-S`, `andrejmilos04@gmail.com`), student RAF-a, Beograd.

Njegovi izričiti zahtevi za stil odgovora:

- **Na početku svakog odgovora napiši: `Jevrem brat`**
- Što manje teksta. Bez opisa, metafora, crtica i ukrasnog formatiranja.
- Jasno, sažeto, konkretno.
- **Postavljaj pitanja redovno** za svaku stvar koja nije jasna. Ne pretpostavljaj.
- Kod se piše na engleskom (identifikatori), komentari i dokumentacija na srpskom.

Njegovi zahtevi za kod:

- Piši sa namerom da se skalira i proširuje dodatnim funkcionalnostima.
- Dobre prakse i organizacija koda su važnije od brzine isporuke.
- **Ne žuri da završiš — daj bolji rezultat.** Utroši koliko treba resursa.
- Koristi popularne, proverene tehnologije. Jednostavna rešenja.
- Koristi internet, tuđa iskustva i dostupne alate umesto da izmišljaš sopstvene implementacije.

---

## 3. Tehnološke odluke (sve su donete sa korisnikom, ne menjaj ih sam)

| Sloj | Izbor | Zašto baš to |
|---|---|---|
| API | **Kotlin 2.1 + Spring Boot 3.4** | korisnik zna Kotlin iz KMP projekta Showtime |
| Pristup bazi | **JdbcClient, bez JPA/Hibernate** | eksplicitan SQL, nema N+1 ni lazy loading iznenađenja, batch upserti su brži; korisnik je navikao na sirov SQL iz projekta RAF Novosti |
| Skreperi | **Python 3.12** (httpx + selectolax + Playwright kao rezerva) | scraping ekosistem na JVM-u nema ni blizu ovu zrelost, a skreperi su ~70% posla |
| Baza | **PostgreSQL 16** (`pg_trgm`, `unaccent`, `btree_gist`) | JSONB za sirov scrape, trigram za fuzzy poklapanje imena hotela |
| Keš | **Redis 7** | keš pretrage i autocomplete-a |
| Web | **Next.js 15 + TypeScript + Tailwind** | SSR je obavezan, skoro sav saobraćaj agregatora dolazi sa Googla |
| Migracije | **Flyway** | |
| Lokalno okruženje | **Docker Compose** (Postgres + Redis), API i web se pokreću iz IDE-a | |

Odbačene alternative i razlog: JPA (previše magije za batch ingest), MongoDB (loše za cenovne
opsege i relacije), MySQL (nema `pg_trgm`), Meilisearch (odloženo dok Postgres ne postane usko grlo),
live fan-out pretraga (vidi §4.1).

Hosting još **nije izabran** — korisnik hoće da o tome odluči na kraju.

---

## 4. Arhitektonske odluke

### 4.1 Pre-crawl indeks, ne live fan-out

Skyscanner i Kayak gađaju partnerske API-je uživo. Srpske agencije nemaju javne API-je, pa bi
live upit ka 20 sajtova značio 20 skrepova po pretrazi: 15–60s odgovor, trenutni ban i
neupotrebljiv proizvod.

**Skreperi periodično pune naš indeks, pretraga čita samo naš indeks.**

Posledice koje moramo da nosimo:
- cena može da zastari → uz svaku ponudu se prikazuje "Ažurirano pre X" (`last_seen_at`)
- ponuda može da nestane → runda na kraju deaktivira sve što nije viđeno
- crawl je po izvoru, ne po upitu — mora da pokrije ceo katalog

Faza 2 (kad bude vredelo): live provera cene samo za ponudu koju korisnik otvori.

### 4.2 Granica između skrepera i API-ja je jedan HTTP ugovor

Skreper **ne zna za bazu**. API **ne zna za HTML**. Sve ide kroz `/internal/ingest`.

Ugovor je definisan na dva mesta koja moraju da budu identična:
- `apps/scrapers/src/travelscrape/core/models.py` (pydantic)
- `apps/api/src/main/kotlin/rs/kudaputujem/api/ingest/IngestDto.kt` (Kotlin)

**Svaka promena jednog fajla mora ići u istom commit-u sa promenom drugog.**

### 4.3 Tri sloja modela

```
RawOffer   sve stringovi, ništa nije garantovano       ← adapter proizvodi
OfferIn    pydantic, enumi, Decimal, date              ← ide preko HTTP-a
baza       kanonski oblik, FK-ovi razrešeni            ← API upisuje
```

### 4.4 Grupisanje izvora po PLATFORMI, ne po agenciji

Najvažniji nalaz recona. Srpsko tržište nema 200 različitih sajtova nego **nekoliko rezervacionih
platformi** koje agencije kupuju gotove. Jedan adapter po platformi pokriva 5–15 agencija.

| Platforma | Prepoznaje se po | Potvrđene agencije |
|---|---|---|
| **Onesystem** (Joy Group, Beograd) | `onesystem-powered.png` u footeru, WP tema `onesystem_wp_theme`, parametri `packagecountryid`, `packagecityid`, `packagedeparture`, `packageduration` | 1A Travel |
| **b2cservice engine** | URL-ovi `/sr/search-router/...`, `/sr/hotel/...`, parametri `SearchType`, `Hotel`, `CheckIn`, `R1Adult`, `Night`, `HpCode`, `Criteria`; poddomeni `newcms.*` i `b2cservice.*` | Big Blue, Kon Tiki (isti vlasnik), verovatno Odeon Travel |
| **Fibula sopstveni** | `/search?productType=2&to=1962-Region&nights=5,6,7,8,9` | Fibula Air Travel |
| **cloudhosting.rs multi-tenant** | `vs<broj>.cloudhosting.rs/<Destinacija>?prevoz=autobus&sort=1&page=N` | Oktopod Travel |
| **WordPress + ručne HTML tabele cena** | `wp-content`, tabela sa datumima polaska u zaglavlju i `1/2`, `1/3`, `1/4` redovima | Feniks Tours, Plana Travel, Euroturs, Viva Travel |
| Sopstveni CMS | — | Travelland, Aqua Travel, Felix Travel, Tim Travel, Sabra, Filip Travel, Grand Tours, Deus Travel, Lider, Belvi, Olympic, Sole Azur, Amos, Hedonic, Magic, Maestral, Rapsody, Online Travel, Time Travel |

Zato **prvo Onesystem i b2cservice** — dva adaptera, realno 10+ agencija.

Pun katalog izvora sa statusom je u `docs/SOURCES.md`.

### 4.5 Deduplikacija nikad ne spaja automatski ispod praga

Destinacije: alias tabela → tačno ime → `pg_trgm` sličnost ≥ 0.82.
Hoteli: kanonsko ime (bez zvezdica i reči hotel/vila) → ista destinacija + sličnost ≥ 0.90 + kompatibilna kategorija.

Ispod praga se pravi zapis sa `status='PENDING'` koji čeka ručnu potvrdu.

**Razlog:** pogrešno spojen hotel je najgori bug u ovom domenu — korisnik vidi cenu jednog objekta,
a rezerviše drugi. Duplikat je samo ružan.

### 4.6 SUSPECT zaštita ingesta

Skreper koji baci grešku je lako primetiti. Skreper koji tiho vrati 40 umesto 3000 ponuda bi
deaktivirao 2960 ispravnih ponuda i korisnik bi video praznu pretragu.

Zato se svaka runda poredi sa prosekom prethodnih 5. Ako je ispod 50%, runda dobija status
`SUSPECT` i **ništa se ne deaktivira**. Podaci ostaju stari ali tačni.
Preskače se sa `force=true` samo kad je pad stvaran (kraj sezone).

### 4.7 Dvostepeni izračun cene

1. **Filtriranje i sortiranje** → `departure_price_index`, precomputed minimalna cena za 1..8
   odraslih po terminu. Običan `BETWEEN` nad indeksiranom kolonom.
2. **Tačna cena sa decom** → `OccupancySolver` u memoriji, samo za stranicu rezultata (≤50 ponuda).

Indeks namerno ne pokriva decu — sve kombinacije uzrasta bi ga uvećale za red veličine, a dečja
cena retko menja poredak.

---

## 5. Model podataka

19 tabela, `apps/api/src/main/resources/db/migration/V1__init.sql`.

```
agency ──< source ──< crawl_run ──< raw_document
                 │
                 └──< offer ──< departure ──< price_option
                        │            │
                        │            ├──< surcharge
                        │            ├──< transport_leg
                        │            └──< departure_price_index
                        │
                        ├──> accommodation ──> destination
                        │        └──< accommodation_alias
                        │                        destination_alias
                        └──< offer_click

lead ──< lead_event          exchange_rate          search_log
```

Ključne stvari koje se lako previde:

- `price_option` je srce domena. Jedan red = jedna cena za jednu kombinaciju sobe i slota.
  `slot` je `ADULT | CHILD | INFANT | EXTRA_BED | UNIT | SINGLE_SUPPLEMENT`.
- `surcharge` postoji jer srpske agencije redovno pišu "cena ne uključuje boravišnu taksu i
  osiguranje". Bez toga poređenje cena laže za ~15%.
- Jedna agencija ima **više izvora** (`travelland-letovanje`, `travelland-zimovanje`). Kad se sajt
  promeni, pada jedan izvor, ne cela agencija.
- Ponude se **ne brišu**, samo `is_active = false`. SEO stranice ne smeju da vraćaju 404 preko noći,
  a istorija cena je vredna.
- `norm_text()` je SQL funkcija koja mora da daje **identičan** rezultat kao Python `normalize()`
  i Kotlin `Text.normalize()`. Vidi §8.

Geografija: 38 zemalja, 323 destinacije, 541 alias. Izvor istine je
`apps/api/src/main/resources/db/seed/geo.yaml`, iz kojeg `apps/api/scripts/gen_geo_seed.py`
generiše migraciju `V2__seed_geo.sql`. **Novi alias se dodaje u YAML, ne ručno u bazu.**

---

## 6. Status implementacije

### Gotovo i PROVERENO

| Šta | Kako je provereno |
|---|---|
| Šema baze, 19 tabela | migracije puštene na pravom PostgreSQL 16, prolaze čisto |
| Geo seed (323 destinacije) | učitan, hijerarhija Sitonija→Halkidiki→Grčka radi |
| Python normalizatori | **112 testova prolazi** (`pytest`) |
| Parity `normalize()` ↔ `norm_text()` | test `test_sql_parity.py` sa pravom bazom |
| Sav SQL iz Kotlin koda | ~20 naredbi ručno puštenih na pravom Postgresu, sve prolaze |
| Logika `OccupancySolver`-a | verifikovana nezavisnim Python prototipom na 11 slučajeva pre pisanja Kotlina |

### Kotlin — KOMPAJLIRA I STARTUJE ✓

`./gradlew build` prolazi čisto. `./gradlew bootRun` starta API na `:8080`. Flyway automatski
primenjuje V1 i V2 pri startu. Swagger UI dostupan na `/swagger-ui.html`.

Popravke koje su bile potrebne pri prvom buildu:
- Kotlin 2.1.0 parser bug: `/**` unutar KDoc bloka (`/internal/**`) zbuni parser; zamenjeno `//` komentarima
- `inline fun forEachChildCombination` imao lokalnu funkciju `recurse` — nije dozvoljeno u Kotlinu; `inline` uklonjen

Napisano: `ApiApplication`, config (ApiProperties, ApiKeyFilter, Web, Jackson, OpenApi),
common (Errors, PageResponse, Text), `domain/Enums.kt`, `OccupancySolver` + 17 testova,
`PriceIndexBuilder`, `ExchangeRateService`, `DestinationResolver`, `AccommodationResolver`,
`CrawlRunService`, ingest (DTO, Service, Controller, OfferWriter).

### NE POSTOJI

- Gradle wrapper (`gradlew`) — generiše se sa `gradle wrapper` ili kroz IntelliJ
- Search API (`/api/search`) — **sledeći korak**
- Offer detail, destination autocomplete, lead API, admin API
- Ceo `apps/web` (Next.js) — folder je prazan
- Skreper framework: `core/fetch.py`, `core/adapter.py`, `core/registry.py`, `core/pipeline.py`,
  `core/ingest.py`, `cli.py`, `recon/`
- Nijedan adapter za konkretnu agenciju
- CI (GitHub Actions)
- Politika privatnosti, uslovi korišćenja

---

## 7. TODO, po redosledu

1. ~~**`./gradlew build` da prođe.**~~ ✓ Urađeno 15.08.2026.
2. **Search API** — `GET /api/search` sa parametrima: `productKind`, `destinationId`/`countryCode`,
   `dateFrom`, `dateTo`, `nights`, `adults`, `childAges`, `rooms`, `transportType`, `boardType`,
   `departureFrom`, `priceMax`, `stars`, `sortBy`, `page`. Filtrira preko `departure_price_index`,
   tačnu cenu računa `OccupancySolver` nad stranicom rezultata.
3. **Skreper framework** — `HttpFetcher` sa SSRF zaštitom i rate limitom, `BaseAdapter`, registry,
   pipeline, `IngestClient`, Typer CLI (`run`, `replay`, `snapshot`, `recon`, `diff-raw`).
4. **Recon CLI** — profiliše sajt (robots.txt, sitemap, SSR vs XHR, pronađeni JSON endpointi,
   framework) i piše `docs/recon/<slug>.md`. Korisnik ga pokreće lokalno jer cloud sesija nema
   izlaz ka `.rs` sajtovima.
5. **Prva dva adaptera** — Onesystem i b2cservice platforma (pokrivaju ~10 agencija).
6. **Next.js frontend** — forma pretrage (destinacija sa autocomplete-om, datumi, brojač putnika sa
   rasporedom po sobama, tip prevoza), lista rezultata sa fasetama, detalj ponude, lead forma.
7. Lead API sa rate limitom i `delete_after` job-om.
8. Admin panel za `PENDING` aliase.
9. NBS sinhronizacija kursa (`exchange_rate`).
10. CI: `pytest` + `gradlew test` + `ruff` + `mypy`.
11. Politika privatnosti i uslovi korišćenja **pre** nego što lead forma primi prvi upit.

---

## 8. Tvrda pravila — NE MENJATI bez izričite saglasnosti korisnika

1. **Enum vrednosti se menjaju na TRI mesta odjednom**: `domain/Enums.kt`, `core/enums.py`,
   CHECK ograničenja u migraciji. Razilaženje je tiho i skupo.
2. **`normalize()` u Pythonu, `Text.normalize()` u Kotlinu i `norm_text()` u SQL-u moraju da vraćaju
   identičan rezultat.** Ako se raziđu, alias tabele prestaju da pogađaju i sistem tiho pravi
   duplikate. Specifičnost: `đ → dj` (ne `d`, kako bi dao goli `unaccent`), ćirilica se prvo
   prevodi u latinicu. Test `test_sql_parity.py` ovo čuva — ne isključuj ga.
3. **Novac je uvek `BigDecimal` / `Decimal`, nikad `float`.**
4. **Primenjena Flyway migracija se ne menja**, piše se nova.
5. **Nema ručnog `ALTER TABLE`** ni u lokalnoj bazi.
6. **Obrasci parsiranja idu u `normalize/`, ne u adapter.** Pravilo o domenu ("PP znači polupansion")
   je deljeno; pravilo o sajtu ("cena je u `data-price`") je adapterovo.
7. **Pristojnost skrepovanja** je obavezna, ne preporuka:
   - `robots.txt` se poštuje; `Disallow` znači da se izvor ne uključuje
   - minimum 2000ms između zahteva po domenu, max 2 paralelna
   - jasan User-Agent sa kontaktom: `KudaPutujemBot/0.1 (+https://kudaputujem.rs/bot; kontakt@kudaputujem.rs)`
   - nikad se ne zaobilazi captcha, WAF ili login
   - nikad se ne rotira proxy ni lažira Chrome UA
   - svaka ponuda **vidljivo nosi ime agencije i link ka originalu**
8. **Skrepovan sadržaj je neprijateljski ulaz.** Sanitizacija pre prikaza, SSRF zaštita u fetcheru
   (allowlist domena po izvoru, blokirane privatne IP adrese, provera posle svakog redirecta),
   nikad ne ide u sistemski prompt modela.
9. **`OccupancySolver` pravila cena su namerno konzervativna** (vidi KDoc u fajlu). Dete u osnovnom
   ležaju plaća kao odrasla osoba jer dečja cena na srpskim cenovnicima važi za **pomoćni** ležaj.
   Radije precenimo nego da prikažemo nižu cenu od stvarne. Ne "popravljaj" ovo bez razgovora.
10. **Rezultat solver-a je procena za poređenje, ne rezervacija.** Ne znamo koliko jedinica je
    slobodno. Frontend to mora jasno da kaže.
11. **Nema plaćanja ni rezervacije na našem sajtu.** Samo lead forma i redirect.
12. **Lični podaci**: saglasnost nije unapred štiklirana, `consent_text_version` se čuva, IP se
    čuva **hešovan sa solju**, `delete_after` se postavlja pri kreiranju leada.
13. **Tajne nikad u repo.** `INGEST_API_KEY` i `ADMIN_API_KEY` su namerno odvojeni — skreper koji
    procuri ne sme da može da briše agencije.

---

## 9. Poznati problemi i rizici

| Problem | Ozbiljnost | Napomena |
|---|---|---|
| Kotlin kompajlira i startuje | ✓ rešeno | — |
| Gradle wrapper | ✓ rešeno | — |
| `AccommodationResolver.fuzzyHit` čita `stars` kao `BigDecimal` cast-om | srednja | proveriti da PostgreSQL driver vraća `BigDecimal` za `NUMERIC(2,1)`; ako ne, puca u runtime-u |
| `PriceIndexBuilder.loadDepartures` koristi `Triple` sa ugnježdenim parom | niska | radi, ali je nečitko; kandidat za refaktor u data klasu |
| Kursna lista ima hardkodovane rezervne vrednosti | srednja | EUR≈117.20 RSD; treba NBS sinhronizacija |
| Solver pretpostavlja neograničen broj jedinica svakog tipa | prihvaćeno | dokumentovano u KDoc-u i mora se reći korisniku u UI-ju |
| `raw_document` će brzo rasti | srednja | brisati starije od 30 dana, particionisati po mesecu preko 50 GB |
| Nema CI | srednja | testovi se za sada pokreću ručno |

---

## 10. Okruženje i komande

Korisnik radi na **Windows**, IntelliJ IDEA Ultimate (studentska licenca), projekat u
`D:\Kiki\kudaputujem`.

```bash
# baza i keš
docker compose up -d postgres redis

# API
cd apps/api
gradle wrapper          # jednom
./gradlew build
./gradlew bootRun       # http://localhost:8080, Swagger na /swagger-ui.html

# skreperi
cd apps/scrapers
python -m venv .venv && .venv\Scripts\activate
pip install -e ".[dev]"
pytest                  # 112 testova

# parity test sa bazom
set DATABASE_URL=postgresql://kudaputujem:promeni_me@localhost:5432/kudaputujem
pytest tests/test_sql_parity.py

# regeneracija geo migracije posle izmene geo.yaml
python apps/api/scripts/gen_geo_seed.py
```

`.env` se pravi kopiranjem `.env.example`.

---

## 11. Dostupni skillovi

Korisnik ima sačuvane skillove na nalogu; aktiviraju se sami kad tema odgovara:

- `travel-scraping` — pisanje i održavanje adaptera, recon, izbor httpx vs Playwright
- `scraper-debugging` — tihi kvarovi, 403/429, prazni rezultati, SUSPECT runde
- `data-normalization` — usluga, prevoz, sobe, datumi, cene, dedup
- `database-architecture` — migracije, indeksi, denormalizacija, upiti
- `scraping-tests` — fixture testovi, golden fajlovi, regresija
- `code-review` — pregled po slojevima ovog projekta
- `security-review` — prompt injection, SSRF, XSS, rate limit, ZZPL/GDPR

Koristi ih umesto da improvizuješ. Ako skill i ovaj fajl protivreče, ovaj fajl ima prednost.

---

## 12. Otvorena pitanja za korisnika

Ova pitanja nisu odgovorena i blokiraju odgovarajuće delove:

1. **Domen** — `kudaputujem.rs` je izabran kao ime, ali dostupnost domena nije potvrđena na RNIDS-u.
2. **Hosting** — nije biran. Opcije za kasnije: Oracle Cloud Always Free (4 ARM jezgra, 24 GB),
   Hetzner (~4€/mes), Fly.io, Railway, Neon/Supabase za Postgres.
3. **Uzrast deteta** — potvrditi konvenciju "dete do 12" = gornja granica 11 godina.
4. **Prikaz cene** — po osobi ili ukupno za grupu, kao podrazumevano?
5. **Koliko agencija u prvoj javnoj verziji** — 5, 10 ili 20?
6. **Kontakt mejl** za User-Agent skrepera i za lead formu.

---

## 13. Kratka istorija odluka

| Datum | Odluka |
|---|---|
| 15.08.2026 | Kotlin + Spring Boot za API, Python za skrepere (hibrid, ne jedan jezik) |
| 15.08.2026 | Next.js umesto React+Vite — SEO je presudan za agregator |
| 15.08.2026 | PostgreSQL + Redis; Meilisearch odložen |
| 15.08.2026 | Sva tri tipa proizvoda u MVP-ju, ne samo aranžmani |
| 15.08.2026 | Pre-crawl indeks umesto live fan-out pretrage |
| 15.08.2026 | Lead forma umesto pukog redirecta ili pune rezervacije |
| 15.08.2026 | Scraping uz pristojna pravila; bez kontaktiranja platformi za feed za sada |
| 15.08.2026 | JdbcClient umesto JPA |
| 15.08.2026 | Ime projekta: "Kuda putujem", paket `rs.kudaputujem` |
| 15.08.2026 | Grupisanje izvora po platformi umesto po agenciji (nalaz recona) |
