# CLAUDE.md — kontekst projekta "Kuda putujem"

> Ovaj fajl je jedini izvor istine o tome gde smo stali. Pročitaj ga u celini pre prve izmene.
> Ako nešto u kodu protivreči ovom fajlu, prvo pitaj — ne pretpostavljaj da je fajl zastareo.
> Kad doneseš novu odluku ili završiš veću stavku, **ažuriraj ovaj fajl u istom commit-u**.

Poslednje ažuriranje: 19.08.2026. (**ADR 0001 korak 2 GOTOV** — `postgres_data` volumen od
15.08 obrisan posle rezervne kopije i provere, baza sad postoji isključivo kroz `alembic upgrade
head`; jedan `.venv` u korenu za sva tri Python paketa; 164 testa prolaze, 0 preskočeno. Kotlin
API još postoji nepromenjen i i dalje je jedini radni backend — vidi §6. Sledeće: korak 3,
OccupancySolver, čeka korisnikov pregled C3 rezultata)
Repo: `https://github.com/S-pear-S/kudaputujem` · grana `main`

---

## 0. TL;DR za sledeću sesiju

Ako je ovo prvi put da vidiš ovaj repo u ovoj sesiji, evo najkraće moguće slike:

- Projekat je **prelazi sa Kotlin+Python hibrida na čisti Python backend**. Odluka i razlog su
  u `docs/decisions/0001pythononly.md` (ADR 0001) — **pročitaj taj fajl pre bilo koje izmene
  backend-a**, on je detaljniji od ovog rezimea.
- **Kotlin API (`apps/api`) i dalje postoji, radi i JE JEDINI backend koji stvarno odgovara na
  HTTP zahteve.** Nemoj ga brisati dok ADR 0001 koraci 2–5 ne budu gotovi (Python API mora prvo
  da dostigne paritet). Korak brisanja je eksplicitno korak 6, poslednji pre čišćenja repoa.
- Zajednički domenski kod (enumi, pydantic modeli, normalizacija) je premešten u
  `packages/travelcore`. `apps/scrapers/travelscrape` sada **samo uvozi** odatle, nema više
  duplikata. Ovo je § 4.2/4.8/§8 pravilo 17 ispod.
- **ADR 0001 korak 2 je GOTOV, u celini** (18–19.08.2026): mypy/ruff dug počišćen, `test_sql_parity.py`
  na `psycopg`, `alembic` skelet napravljen i dokazano veran (C1+C2), atomičnost sirovog kursora
  eksperimentalno dokazana, `postgres_data` volumen od 15.08 obrisan POSLE rezervne kopije i
  provere da nema podataka van geo seed-a, baza sad postoji **isključivo** kroz `alembic upgrade
  head`. Lozinka u `.env` je nasumična, ne `promeni_me` — pogledaj `.env` lokalno, **ne piši je
  u ovaj fajl**.
- **Jedan `.venv` u korenu repoa** (`D:\Kiki\kudaputujem\.venv`) za sva tri Python paketa —
  `packages/travelcore`, `apps/scrapers`, `apps/api`. Više NEMA `apps/scrapers/.venv` ni
  `apps/api/.venv` posebno. `pytest` iz korena (root `pytest.ini`) pokuplja i
  `apps/scrapers/tests` i `apps/api/tests`. Vidi §10.
- **Sledeći korak, kad korisnik da zeleno svetlo:** ADR 0001 korak 3 — `OccupancySolverTest.kt`
  → `tests/test_occupancy.py` PRVO (svi crveni, nepromenjeni brojevi), tek onda
  `pricing/occupancy.py`. Vidi §7. **Ne kreći sam — korisnik traži da javiš C3 rezultat i čekaš.**
- Radni obrazac sa korisnikom ide kroz `instrukcije/` (patch/md fajlovi) — vidi §2. Poruke
  `porukazaclaudecode1.md` do `7.md` su **već primenjene i zatvorene** u ovoj tački; ako stigne
  `porukazaclaudecode8.md` ili novi `.patch`, to je sledeći zadatak.
- Skreper adapteri: `soleazur.rs` i `oktopod.rs` gotovi i verifikovani. `grandtours.rs` je
  sledeći na redu, čeka fixture od korisnika (Chrome ekstenzija nema još dozvolu za taj domen).

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
- Kad instrukcija traži "jedan commit, ništa drugo u njemu" — drži se toga doslovno. Ako alat
  (npr. `ruff --fix`) uzgred popravi nešto nepovezano, to se ručno vraća pre commit-a. Nepovezano
  čišćenje ide u zaseban, kasniji commit, čak i kad je samo par linija.
- Kad instrukcija kaže "stani, ne kreći na sledeći korak dok ne pregledam" — to se poštuje.
  Ne nastavljaj na sledeći ADR korak sam od sebe.

### Radni obrazac: folder `instrukcije/`

Korisnik radi u pravom Chrome-u (DevTools, Ctrl+S za fixture) jer ova sesija nema izlaz ka
`.rs` sajtovima (§4.4, §7). Nalaze i zadatke šalje kroz `instrukcije/` u root-u repoa:
`git format-patch`-stil `.patch` fajlovi (primenjuju se sa `git apply <put>`, redosledom kojim ih
navede — ako `git apply` na `CLAUDE.md` konfliktuje jer se fajl u međuvremenu menjao, primeni
ostatak sa `--exclude=CLAUDE.md` i ručno pomiri CLAUDE.md izmene) i `.md` fajlovi sa uputstvima/
porukama za čitanje u celini. Ciklus: on mapira sajt/proverava tvoj kod u browseru → piše
patch + uputstvo → ja primenjujem, čitam, pokrećem pytest/ruff, pišem sledeći adapter → javljam
status i tražim sledeći fixture. Fajlovi u `instrukcije/` se ne brišu automatski — trenutno
sadrže istoriju dosadašnjih instrukcija, ne samo najnovije.

**Stanje `instrukcije/` na 18.08.2026:**

| Fajl | Sadržaj | Status |
|---|---|---|
| `uputstvozaclaudecode.md` | soleazur fixture verifikacija, oktopod zadatak, skidanje maestral/aquatravel sa liste, pravila 14/15 | ✓ primenjeno |
| `porukazaclaudecode1.md` | fix `parse_price_page`, oktopod valuta/AC doplata/`discover()` preko sitemap-a, Python 3.12 potvrda | ✓ primenjeno |
| `porukazaclaudecode2.md` | ADR 0001 korak 1: shim-first premeštanje u `packages/travelcore`, `travelcore` mora ostati čist (bez scraping zavisnosti), Python 3.12 svuda u konfiguraciji | ✓ primenjeno (1b) |
| `porukazaclaudecode3.md` | potvrda 1b, nalog za 1c (brisanje shim-ova), `import-linter` kontrakt kao "pravilo 16" (ovde upisano kao **pravilo 17**, vidi §8 zašto) | ✓ primenjeno (1c + import-linter), korisnik je tražio da se stane posle ovoga |
| `porukazaclaudecode4.md` | potvrda 1c, promena plana: NE ide se odmah na alembic. A) počisti mypy/ruff dug pre koraka 2 (razlog: crvena osnovna linija maskira nove greške iz ~1200 linija koje dolaze). B) digni Postgres, prepiši `test_sql_parity.py` na `psycopg`, pusti ga stvarno prvi put. C) tek onda alembic — **eksplicitno NE raditi dok korisnik ne pregleda rezultat parity testa**. D) podsetnik za `docker-compose.yml` u koraku 6 | ✓ primenjeno A+B+D (commit-i `daf7926`, `83596d2`, `7b47cb7`, `791d4aa`), **korisnik ponovo traži da se stane, C se ne radi dok ne pregleda 153/153 rezultat** |
| `porukazaclaudecode5.md` | A) testovi za oba bug fix-a iz poruke 4, vrati na commit pre ispravke i potvrdi da padaju. B) parity test (153/0) je bio nad bazom od 15.08, ne dokazuje da se slaže sa DANAŠNJIM SQL-om. C) alembic u tri dela — C1 (diff stare baze vs. danas), C2 (alembic vs. ref), C3 (baza iznova). Redosled: A → C1 → stani | ✓ primenjeno (commit `08704a1` — fetch.py test genuinski pada na starom kodu nakon ispravke sa `12345`→`1500000000`; soleazur/oktopod testovi NE padaju na starom kodu, prijavljeno umesto zataškano), C1 diff prazan (van `\restrict`/`flyway_schema_history`) |
| `porukazaclaudecode6.md` | potvrda C1. Odluka o `tree.root`: **opcija 1** — guard ostaje (ne `assert`/`type: ignore`, oba su gora od guarda), postaje pravilo 18 u §8, testovi za oba buga preimenovani u karakterizacione. Ispravka C2 kriterijuma: treba i PODACI, ne samo šema (`--schema-only` diff bi bio prazan i da `0002` uopšte ne izvrši). Redosled: pravilo 18 + testovi → C2 → stani i javi oba diff-a → C3 | ✓ primenjeno (commit-i `78159c8`, `2d07b3d`) |
| `porukazaclaudecode7.md` | potvrda C2. Tri provere pre C3: (1) sirovi kursor mora deliti alembic-ovu transakciju — dokazano eksperimentom, namerna greška na kraju revizije 0002 nad praznom bazom ostavlja **nula tabela**, uklj. iz 0001. (2) prebroj §8 — 18 pravila, neprekidan niz, pravilo 18 je ispravno (17 je import-linter). (3) jedan `.venv` u korenu umesto po paketu. Zatim C3 — korisnik dodatno tražio rezervnu kopiju PRE brisanja volumena (`docker volume rm` je prvo blokiran auto-mode klasifikatorom, korisnik eksplicitno potvrdio nastavak uz uslov rezervne kopije) | ✓ primenjeno u celini (commit `18d70cf` za venv; C3 izvršen: backup 129KB/2727 linija proveren van repoa, potvrđeno da nema podataka van geo seed-a, volumen obrisan, baza nastala isključivo kroz `alembic upgrade head`, **164 testa prolaze, 0 preskočeno**) |
| `0001soleazuradapterverifikovannadpravimfixtureomf.patch` | soleazur fixture iz pravog DOM-a, prepravke rowspan/redosled/PO OSOBI | ✓ primenjeno |
| `0001Odlukadevetblokiranihizvoratrajnovanopsegabez.patch` | devet trajno isključenih izvora (§8 pravilo 13) | ✓ primenjeno |

**ADR 0001 korak 2 je time u celini završen.** Ako sledeća sesija zatekne nov `.patch` ili
`porukazaclaudecode8.md`, to je sledeći zadatak — ne čekaj dalja uputstva van tog fajla. Ako
ništa novo ne stigne, sledeći korak je ADR 0001 korak 3 (§7) — ali čeka korisnikovo "kreni".

---

## 3. Tehnološke odluke (sve su donete sa korisnikom, ne menjaj ih sam)

**Governing dokument: `docs/decisions/0001pythononly.md` (ADR 0001, prihvaćen 17.08.2026).**
Zamenjuje deo tabele ispod koji se ticao API sloja. Pročitaj ga pre bilo koje izmene u
`apps/api` ili `packages/travelcore` — ima detaljan plan rizika i redosled izvođenja koji se
ne ponavlja ovde u celosti.

| Sloj | Izbor | Zašto baš to |
|---|---|---|
| **API (ciljno stanje, ADR 0001)** | **Python 3.12 + FastAPI + uvicorn** | pydantic je već u projektu (`travelcore`); validacija i OpenAPI izlaze iz istih modela koje koriste skreperi |
| **API (trenutno stanje, još radi)** | Kotlin 2.1 + Spring Boot 3.4, `JdbcClient` | **NIJE OBRISANO** — vidi §6. Zamenjuje se postepeno, brisanje je ADR 0001 korak 6 |
| Pristup bazi (ciljno) | **psycopg 3** + `psycopg_pool`, raw SQL | isti duh kao `JdbcClient`; `numeric` stiže kao `Decimal` |
| Deljeni domenski paket | **`packages/travelcore`** (enumi, pydantic modeli, normalizacija) | jedini izvor istine za pojmove koje dele skreperi i API — vidi §4.8 |
| Skreperi | **Python 3.12** (httpx + selectolax + Playwright kao rezerva) | scraping ekosistem na JVM-u nema ni blizu ovu zrelost, a skreperi su ~70% posla |
| Baza | **PostgreSQL 16** (`pg_trgm`, `unaccent`, `btree_gist`) | JSONB za sirov scrape, trigram za fuzzy poklapanje imena hotela |
| Keš | **Redis 7** (ciljno: `redis-py` async, trenutno: Spring cache + Lettuce) | keš pretrage i autocomplete-a |
| Web | **Next.js 15 + TypeScript + Tailwind** | SSR je obavezan, skoro sav saobraćaj agregatora dolazi sa Googla |
| Migracije (ciljno) | **alembic**, `.sql` fajlovi netaknuti unutar `op.execute()` | standardni Python alat |
| Migracije (trenutno, još radi) | **Flyway** za razvojnu bazu (volumen od 15.08); `alembic` skelet **postoji i verifikovan** (§6, C1+C2) ali još ne pravi stvarnu razvojnu bazu — to je korak C3 | `V1__init.sql`/`V2__seed_geo.sql` sad u `apps/api/migrations/sql/`, nepromenjeni |
| Lint / tipovi | **ruff + mypy strict** (već u oba Python paketa) | `.venv` u `apps/scrapers`, isti alati će pokrivati budući `apps/api` |
| Zavisnosti između paketa | **`import-linter`** (`.importlinter` u root-u) | mehanička provera da `travelcore` ostaje čist — vidi §4.8, §8 pravilo 17 |
| Editor (ciljno) | **VS Code** | jedan editor za Python i za Next.js, umesto IntelliJ+VS Code |
| Editor (trenutno) | IntelliJ IDEA Ultimate (za Kotlin deo) + VS Code | dok Kotlin postoji, IntelliJ je i dalje potreban za njega |
| Lokalno okruženje | **Docker Compose** (Postgres + Redis), API i web se pokreću iz IDE-a/terminala | |

`alembic` (kad dođe na red) povlači `SQLAlchemy` kao zavisnost. **SQLAlchemy se neće koristiti u
kodu aplikacije** — služi isključivo kao pogon alembica. Pristup bazi ostaje psycopg + raw SQL.

Odbačene alternative i razlog: JPA (previše magije za batch ingest), MongoDB (loše za cenovne
opsege i relacije), MySQL (nema `pg_trgm`), Meilisearch (odloženo dok Postgres ne postane usko grlo),
live fan-out pretraga (vidi §4.1), dva jezika za backend (vidi ADR 0001 — porez na svaku izmenu
modela i na okruženje, projekat vodi jedan student sam).

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

**Format na žici (JSON preko HTTP-a) ostaje identičan bez obzira na jezik API-ja** —
`sourceSlug`, `runId`, camelCase. Skreperov `IngestClient` (`core/ingest.py`) se ne menja kad
API pređe na Python.

Ugovor je definisan u **`packages/travelcore/src/travelcore/models.py`** (pydantic) — to je
sada **jedini** izvor istine za oblik podataka koji putuje preko HTTP-a. Dok Kotlin API postoji
paralelno, `apps/api/src/main/kotlin/rs/kudaputujem/api/ingest/IngestDto.kt` je i dalje tu, ali
je **zamrznut**: ne dobija nove izmene, ne prati promene u `travelcore.models` ručno. Kad
Python API (ADR 0001 korak 4) preuzme ingest endpoint, `IngestDto.kt` nestaje u koraku 6 zajedno
sa ostatkom Kotlina. Ako u međuvremenu treba promena ugovora, menja se **samo**
`travelcore.models` — Kotlin strana namerno zaostaje, to je prihvaćen rizik dok traje prelazak.

### 4.3 Tri sloja modela

```
RawOffer   sve stringovi, ništa nije garantovano       ← adapter proizvodi
OfferIn    pydantic, enumi, Decimal, date              ← ide preko HTTP-a
baza       kanonski oblik, FK-ovi razrešeni            ← API upisuje
```

`RawOffer` i `OfferIn` (i ostali `*In` modeli) žive u `travelcore.models`, uvoze ih i skreperi i
(kad bude gotov) Python API. Pre ADR 0001 su postojali duplirano u Kotlinu; taj duplikat se gasi.

### 4.4 Grupisanje izvora po PLATFORMI, ne po agenciji

Najvažniji nalaz recona. Srpsko tržište nema 200 različitih sajtova nego **nekoliko rezervacionih
platformi** koje agencije kupuju gotove. Jedan adapter po platformi pokriva 5–15 agencija.

| Platforma | Prepoznaje se po | Potvrđene agencije |
|---|---|---|
| **Onesystem** (Joy Group, Beograd) | `onesystem-powered.png` u footeru, WP tema `onesystem_wp_theme`, sitemap na `admin-ajax.php?action=os_sitemap`, DB prefiks `onesystem_`; parametri `countrytermid`, `citytermid`, `departurefromid`, `departuredate`, `duration`, `adlcount`, `chdcount`, `chdage1..4` | 1A Travel — potvrđeno, treći talas (cena je funkcija popunjenosti, nema tabelu) |
| ~~TourVisio B2C~~ (SAN Tourism Software Group) | `Disallow: /*.asmx` i `/*.ashx`, rute `/sr/search-router/`, neizrenderovan template `{{offer.price.amount}}` u HTML-u | Big Blue, Kon Tiki, Filip Travel, Odeon Travel — **sve četiri ISKLJUČENE**, blokiraju baš putanje sa podacima |
| ~~Fibula~~ | SPA + inventar iz **Peakwork** huba, cene dinamičke po upitu | Fibula Air Travel — **ISKLJUČENA**, robots.txt blokira skrepere uključujući Scrapy |
| **cloudhosting.rs multi-tenant** | `vs<broj>.cloudhosting.rs/<Destinacija>?prevoz=autobus&sort=1&page=N` | Oktopod Travel |
| **WordPress + ručne HTML tabele cena** | `wp-content`, tabela sa datumima polaska u zaglavlju i `1/2`, `1/3`, `1/4` redovima | Feniks Tours, Plana Travel, Euroturs, Viva Travel |
| Sopstveni CMS | — | Travelland, Aqua Travel, Felix Travel, Tim Travel, Sabra, Grand Tours, Deus Travel, Lider, Belvi, Olympic, Sole Azur, Amos, Hedonic, Magic, Maestral, Rapsody, Online Travel, Time Travel |

Recon od 33 sajta je **opovrgao** originalnu pretpostavku "prvo velike platforme" kao glavnu
strategiju. Velike agencije jesu na zajedničkim platformama, ali su te platforme zatvorene:
TourVisio grupa (4 agencije) blokira `.asmx`/`.ashx` i `/sr/search-router/`, Fibula blokira
Scrapy, Onesystem nema cenovnik u HTML-u.

Prava prilika su **mali sajtovi sa ručnim HTML cenovnicima i otvorenim robots.txt**. Detaljni
izveštaj po svakom od 33 sajta (platforma, robots.txt, URL šeme, primer cenovnika gde je nađen)
je u `docs/recon/`, rangiranje i metod u `docs/recon/README.md`.

**Redosled adaptera** (ažurirano 17.08.2026, posle mapiranja kroz pravi browser — vidi §6):
- Gotovo: `soleazur.rs` ✓, `oktopod.rs` ✓
- Sledeći na redu: `grandtours.rs`, `euroturs.rs`, `belvi.rs`, `planatravel.rs`
- Čekaju fixture: `travelland.rs`, `felixtravel.rs`, `timtravel.rs`, `onlinetravel.rs`, `magictravel.rs`, `amostravel.rs`, `rapsodytravel.rs`, `lidertravel.rs`, `hedonictravel.rs`, `sabra.rs`
- Skinuto sa liste (ne objavljuju cenovnik, potvrđeno u browseru): `maestral.co.rs`, `aquatravel.rs`
- Talas 3 (teško): `1atravel.rs` (Onesystem), `kontiki.rs`, `olympic.rs`, `timetravel.rs`
- Isključeni trajno (9, robots.txt blokira skrepere — §8 pravilo 13): `bigblue.rs`, `fibula.rs`, `filiptravel.rs`, `odeontravel.rs`, `deustravel.rs`, `feniks-tours.rs`, `vivatravel.rs`, `balkanviator.com`, `lasta.rs`

**Za adaptere talasa 1 i 2 — obavezan redosled:**
1. Otvori stranicu hotela u Chrome-u, sačuvaj HTML (`Ctrl+S → Webpage, HTML Only`)
2. Stavi u `apps/scrapers/tests/fixtures/<slug>/`
3. Tek onda pišemo adapter — bez fixture-a selektori su nagađanje

Pun katalog izvora sa statusom je u `docs/SOURCES.md`.

### 4.4b Cena po rasporedu sobe često NE POSTOJI kao tabela

Nalaz recona, menja pretpostavku pod kojom je pisan `OccupancySolver`.

Na delu izvora (potvrđeno na 1A Travel-u i Fibuli) agencija ne objavljuje matricu
`1/2`, `1/2+1`, `1/4`. Cena je **funkcija popunjenosti** i dobija se tek parametrizovanom
pretragom sa `adlcount`, `chdcount`, `chdage1..4`. 1A Travel to piše doslovno na sajtu.

Posledice:

- Za takve izvore adapter radi **N upita po ponudi** (termin × sastav putnika), ne jedan skrep
  cenovnika. Ograničiti na tipične rasporede: 2 odrasla, 2+1 dete, 2+2 dece, 3 odrasla,
  4 odrasla; i tipične dužine 7 i 10 noći.
- `price_option.room_code` se u tim slučajevima **izvodi** iz zatraženog sastava putnika
  (`adlcount=2, chdcount=1` → `1/2+1`), a ne čita sa sajta. Upisati u `notes` da je izveden.
- `OccupancySolver` i dalje radi neizmenjen — samo dobija manje redova nego kod izvora sa
  pravim cenovnikom.

Izvori sa pravim HTML tabelama cena (talas 1/2) ostaju kakvi jesu i tamo se `room_code` čita
doslovno. Ovo pravilo se aktivira tek za talas 3 (`1atravel.rs`, `kontiki.rs`, `olympic.rs`,
`timetravel.rs`), ako se ikad odluči da se za njih piše adapter.

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

### 4.8 `packages/travelcore` je čist domenski sloj (ADR 0001, novo 17.08.2026)

Enumi, pydantic modeli i normalizacija teksta/datuma/novca/soba/prevoza/usluge više ne postoje
duplirano u Kotlinu i Pythonu. Žive na **jednom mestu**:

```
packages/travelcore/src/travelcore/
    enums.py            ← AccommodationKind, BoardType, PriceSlot, SurchargeUnit, ...
    models.py            ← RawOffer, OfferIn, DepartureIn, PriceIn, SurchargeIn, IngestBatch, ...
    normalize/
        text.py           ← normalize(), slugify(), from_cyrillic(), canonical_accommodation_name()
        dates.py          ← parse_date(), parse_date_range(), parse_duration()
        money.py          ← parse_amount(), parse_price(), detect_currency()
        rooms.py          ← parse_room_code(), parse_child_ages()
        board.py          ← parse_board()
        transport.py      ← parse_transport(), parse_transport_options()
```

`apps/scrapers/src/travelscrape` uvozi **direktno** odatle (`from travelcore.enums import ...`,
`from travelcore.normalize.text import ...`) — nema više re-eksport shim-ova, oni su obrisani u
koraku 1c (vidi §6, §13).

**Granica je tvrda i proverena alatom, ne samo dogovorom.** `travelcore` sme da zavisi samo od
`pydantic` (i `python-dateutil`/`rapidfuzz` ako zatreba — trenutno ih ne koristi, proveri pre
dodavanja). **Ne sme** da uvozi `httpx`, `selectolax`, `typer`, `structlog`, `tenacity`,
`playwright`, `rich`, niti da zna za `travelscrape`. Ono što ostaje u `travelscrape` i ne seli
se: `core/settings.py`, `core/adapter.py`, `core/fetch.py`, `core/ingest.py`, `core/pipeline.py`,
`core/registry.py`, `adapters/`.

Provera je `import-linter` (`.importlinter` u root-u, dva kontrakta) — vidi §8 pravilo 17.
Kad Python API (ADR 0001 korak 4) bude postojao, dobija treći kontrakt: `travelapi` ne sme da
uvozi `travelscrape` (isti princip, treći ugao trougla).

Instalacija u `.venv`-u (redosled je bitan, `travelcore` prvo):
```
pip install -e packages/travelcore
pip install -e apps/scrapers
```

---

## 5. Model podataka

19 tabela. Kanonski SQL je od 18.08.2026 u `apps/api/migrations/sql/{V1__init.sql,V2__seed_geo.sql}`
(premešteno iz `src/main/resources/db/migration/`, čist rename, sadržaj bit-za-bit nepromenjen —
provereno `sha256`). Primenjuje se preko `alembic` revizija `0001`/`0002` (§6, §10), koje rade
`op.get_bind().connection.cursor().execute(sql)` nad tim fajlovima doslovno. **Postojeća baza
(Postgres volumen od 15.08.2026, koristi se za razvoj do ADR 0001 koraka C3) je i dalje Flyway-om
migrirana** — `alembic` je za sada samo verifikovan alat, još ne i stvarni izvor šeme za tu bazu.

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
- `norm_text()` je SQL funkcija koja mora da daje **identičan** rezultat kao Python
  `travelcore.normalize.text.normalize()`. Dok Kotlin postoji, i `Text.kt` mora da se slaže, ali
  se (kao i `IngestDto.kt`) više ne ažurira ručno u paru — vidi §4.2, §8 pravilo 2.

Geografija: 38 zemalja, 323 destinacije, 541 alias. Izvor istine je
`apps/api/src/main/resources/db/seed/geo.yaml`, iz kojeg `apps/api/scripts/gen_geo_seed.py`
generiše migraciju `V2__seed_geo.sql`. **Novi alias se dodaje u YAML, ne ručno u bazu.**

---

## 6. Status implementacije

### Gotovo i PROVERENO (nezavisno od ADR 0001 prelaska)

| Šta | Kako je provereno |
|---|---|
| Šema baze, 19 tabela | migracije puštene na pravom PostgreSQL 16, prolaze čisto |
| Geo seed (323 destinacije) | učitan, hijerarhija Sitonija→Halkidiki→Grčka radi |
| Python normalizatori + soleazur + oktopod adapteri | **140 testova prolazi** (`pytest`, Python 3.12 `.venv`): 99 normalize, 19 soleazur, 22 oktopod. Plus 13 `test_sql_parity.py` koji se preskaču bez `DATABASE_URL` |
| Parity `normalize()` ↔ `norm_text()` | test `test_sql_parity.py` sa pravom bazom (sad uvozi iz `travelcore.normalize.text`) |
| Sav SQL iz Kotlin koda | ~20 naredbi ručno puštenih na pravom Postgresu, sve prolaze |
| Logika `OccupancySolver`-a | verifikovana nezavisnim Python prototipom na 11 slučajeva pre pisanja Kotlina, **17 JUnit testova** u `OccupancySolverTest.kt`. Prevod u `pytest` je ADR 0001 korak 3, još nije urađen |

### ADR 0001 — prelazak na čisti Python backend: STATUS PO KORACIMA

Redosled je definisan u `docs/decisions/0001pythononly.md`. Svaki korak je zaseban commit,
svaki se završava zelenim `pytest`-om, Kotlin se briše poslednji.

| Korak | Šta | Status |
|---|---|---|
| **1a** | `packages/travelcore` — izdvajanje enuma/modela/normalizacije | ✓ urađeno (deo 1b commit-a, telo je odmah stiglo u `travelcore`) |
| **1b** | Shim: `travelscrape` re-eksportuje iz `travelcore`, testovi se ne diraju | ✓ **commit `8a70043`** — 140 prolazi, 13 preskočeno, nula izmena u testovima |
| **1c** | Shim-ovi obrisani kao fajlovi, importi u `travelscrape` (izvor + testovi) idu direktno na `travelcore.*` | ✓ **commit `1c4a1b5`** — nema stale referenci, test diff samo import linije, isti brojevi testova |
| **Pravilo 17** | `import-linter` sa dva kontrakta (`travelcore` čist, smer zavisnosti) | ✓ **commit `08584f2`** — `lint-imports`: 2 kept, 0 broken |
| **Mypy/ruff dug** | 14 pred-postojećih mypy grešaka i 11 ruff nalaza pre koraka 2 (razlog: od koraka 3 pišemo ~1200 novih linija, crvena osnovna linija maskira nove greške) | ✓ **commit-i `daf7926`, `83596d2`, `7b47cb7`** — vidi tabelu ispod, oba alata sad daju nulu |
| **`test_sql_parity.py` sa pravom bazom** | 13 testova koji porede Python `normalize()` i SQL `norm_text()` nikad nisu bili pokrenuti na ovoj mašini (test tražio `psql` na PATH-u, Postgres je u Dockeru) | ✓ **commit `791d4aa`** — prepisano na `psycopg` sa vezanim parametrom, Postgres podignut, **153 prolazi, 0 preskočeno**, obe strane se slažu za svih 13 slučajeva |
| **Pravilo 18** | Kad tip strane biblioteke kaže `Optional`, obrađujemo granu, ne `assert`/`# type: ignore`. Testovi koji je fiksiraju su karakterizacioni, ne regresioni | ✓ **commit `78159c8`** — `tree.root: Node \| None` u soleazur/oktopod, vidi §9 |
| **2, C1** | Provera da postojeća baza (volumen od 15.08) nije razvijena protiv zastarele šeme | ✓ — `diff` `pg_dump --schema-only` prazan (van nasumičnog `\restrict` tokena i `flyway_schema_history`, oboje objašnjeno), `pg_get_functiondef(norm_text)` identičan |
| **2, C2** | `alembic` skelet, revizije `0001`/`0002`, provera ŠEME **i** PODATAKA između `ref` (sirov SQL) i `mig` (`alembic upgrade head`) | ✓ **commit `2d07b3d`** — oba `diff`-a prazna, vidi §9 za detalje i objašnjenje `created_at`/`updated_at` razlike |
| **Atomičnost sirovog kursora** | Dokaz da `migrations/_raw_sql.py` deli alembic-ovu transakciju, ne otvara novu konekciju | ✓ — namerna greška na kraju revizije 0002 nad praznom bazom ostavlja **nula tabela** posle pada, uklj. sve iz 0001. Privremena izmena vraćena, `git diff` prazan |
| **Broj pravila u §8** | Provera da nema rupe/duplikata posle više sesija dodavanja pravila | ✓ — 18 pravila, neprekidan niz 1–18. Pravilo 18 je ispravno (17 je import-linter, pomeren sa "16" u poruci 3) |
| **Jedan `.venv` u korenu** | `apps/scrapers/.venv` i `apps/api/.venv` spojeni u `D:\Kiki\kudaputujem\.venv`, sva tri paketa (`travelcore`, `travelscrape`, `travelapi`) instalirana `-e` u njega | ✓ **commit `18d70cf`** — `pytest.ini` u korenu, `pytest`/`ruff`/`mypy`/`lint-imports` isti rezultati kao pre premeštanja |
| **2, C3** | `postgres_data` volumen od 15.08 se briše, prava baza se pravi iznova ISKLJUČIVO kroz `alembic`, prava lozinka u `.env` | ✓ **GOTOVO 19.08.2026** — korisnik tražio rezervnu kopiju PRE brisanja (`docker volume rm` prvo blokiran auto-mode klasifikatorom kao destruktivna radnja, korisnik eksplicitno potvrdio). Backup 129KB/2727 linija (van repoa), potvrđeno da nema podataka van geo seed-a (samo `destination`=323, `destination_alias`=541, svih ostalih 17 tabela = 0). Volumen obrisan, baza nastala isključivo kroz `alembic upgrade head`. **164 testa prolaze, 0 preskočeno** (153 + `test_fetch.py` + prošireni karakterizacioni testovi od poruke 5/6). `ref`/`mig` baze nestale zajedno sa obrisanim volumenom (živele su u istom Postgres instance-u) — ništa dodatno za čišćenje |
| **3** | `OccupancySolverTest.kt` → `tests/test_occupancy.py` (svi crveni), pa `pricing/occupancy.py` dok ne pozelene | ⏳ **SLEDEĆI KORAK** — čeka korisnikovo "kreni" |
| **4** | Ostatak API-ja modul po modulu: `errors` → `db` → `geo` → `accommodation` → `ingest` → `pricing/price_index` → `search`, sa testovima uz svaki. Tu ide i treći `import-linter` kontrakt: `travelapi` ne sme da uvozi `travelscrape` | ne početo — `apps/api/src/travelapi/__init__.py` postoji, prazan placeholder |
| **5** | E2E provera: `soleazur` skreper → `POST /internal/ingest` → baza → `GET /search` vraća tu ponudu, bez izmene `IngestClient`-a | ne početo |
| **6** | Brisanje `apps/api/src/main/kotlin`, `src/test/kotlin`, `build.gradle.kts`, `settings.gradle.kts`, `gradle/`, `gradlew*`, JVM `Dockerfile`, čišćenje `docker-compose.yml` | **ne dirati pre koraka 5** |
| **7** | VS Code config (`.vscode/`), uklanjanje pominjanja IntelliJ/Gradle iz `README.md`/`CLAUDE.md` | ne početo |
| **8** | Prepisivanje ovog fajla §2/§4/§8/§9/§10, unos u §12 | u toku — ovaj rewrite pokriva deo toga unapred, dovršava se kad se Kotlin stvarno obriše |

**Mypy/ruff nad `packages/travelcore` + `apps/scrapers/src/travelscrape`, stanje 17.08.2026 posle poruke 4:**

| Alat | Bilo | Sad | Šta je urađeno |
|---|---|---|---|
| `mypy --strict` | 14 grešaka | **0** | 12 od 14 su bile tipske sitnice bez promene ponašanja (`dict` bez tip-argumenata, `resp.json()` netipiziran, shadowing lokalne `parser` promenljive u `_RobotsCache.is_allowed`, mypy-evo ne-suzavanje tipa u `oktopod.py` comprehension-u — rešeno walrus operatorom, isti ishod). **2 su bile stvarni, makar retki, propusti u ponašanju** — izdvojene u sopstvene commit-e, vidi §9 |
| `ruff check .` | 11 nalaza | **0** | nekorišćeni importi u `cli.py`, `typing.AsyncGenerator`→`collections.abc` (UP035), razdvojeni `from .settings import X, Y` (I001), spojen ugnježden `if` u `fetch.py` (SIM102) — sve bez promene ponašanja |

**Dva nalaza koja SU promenila ponašanje** (namerno izdvojena iz čistke, po instrukciji "ne zakopavaj ispravku ponašanja u commit koji se zove čišćenje"):

1. **`core/fetch.py`, SSRF provera** (commit `83596d2`, test `08704a1`) — `socket.getaddrinfo()` tipski može vratiti `tuple[int, bytes]` za egzotične adresne familije, pa bi `_is_forbidden_ip()` dobio `int` koji `ipaddress.ip_address()` **prihvata** kao celobrojnu IP adresu umesto da baci `ValueError` (fail-closed grana se ne bi ni pozvala). U praksi nedostižno za ovaj poziv (nema `family`/`type` filtera, ulaz je DNS ime ili IP), ali je SSRF zaštita pa je dodata eksplicitna `isinstance` provera koja odbija sve što nije `str`. **`test_fetch.py`** (regresija, `monkeypatch` na `socket.getaddrinfo`) genuinski pada na kodu pre popravke — prvi pokušaj sa `12345` je slučajno pogodio adresu koju `ipaddress` i dalje flaguje kao privatnu (`0.0.48.57` je u `0.0.0.0/8`), pa je lažno prolazio na oba koda; ispravna vrednost `1500000000` → `89.104.47.0` stvarno demonstrira propust.
2. **`adapters/soleazur.py`, `parse_price_page`** (commit `7b47cb7`) — `HTMLParser.root` je tipiziran `Node | None`; funkcija je zvala `.traverse()` na njemu bez provere, što bi bacilo `AttributeError` na prazan/nevalidan HTML umesto da se ponaša kao ostatak adaptera (vraća `[]`). Dodata provera, isti obrazac kao u `oktopod.py` kad `title_node` nedostaje. **Nalaz pri pisanju testa** (§8 pravilo 18): `selectolax` kroz javni API ove verzije **nikad** ne vraća `None` za `.root`, ni za `""`, `"<html></html>"`, `"   "`, `"\x00"` — HTML5 auto-repair uvek napravi bar `<html>`. `HTMLParser.root` je i read-only property na immutable C extension klasi, ne da se mock-uje ni na instanci ni na klasi. Test za ovu granu je zato **karakterizacioni, ne regresioni** (ne pada na kodu pre `7b47cb7` — genuinski smo to proverili, ne pretpostavili). Guard ostaje jer tip strane biblioteke kaže `Optional` i mi ne kontrolišemo tu biblioteku (pravilo 18), ne zato što je bag demonstriran.

### ADR 0001 korak 2 — alembic skelet i verifikacija (C1, C2), 18.08.2026

Novi paket `apps/api` (Python, `travelapi`, sopstveni `.venv`) — koegzistira sa Kotlinom, koji
nije dirnut. `apps/api/migrations/{env.py,versions/0001_init.py,versions/0002_seed_geo.py,
sql/{V1__init.sql,V2__seed_geo.sql}}`. Revizije rade `op.get_bind().connection.cursor().execute(sql)`
(pomoćnik `migrations/_raw_sql.py`), **ne** `op.execute()`/`exec_driver_sql()` — vidi §9,
psycopg 3 puca na bukvalnom `%` u SQL komentaru kad SQLAlchemy prosledi prazne parametre.
`downgrade()` na obe revizije diže `NotImplementedError`, provereno da stvarno ne dira bazu.

**C1 (baza od 15.08 nije razvijena protiv zastarele šeme):** `pg_dump --schema-only` nad
postojećom bazom vs. `ref` (napravljena iz današnjih `V1`+`V2` fajlova) — diff nakon filtriranja
nasumičnog `\restrict`/`\unrestrict` tokena (potvrđeno: dva uzastopna dump-a iste nepromenjene
baze daju različit token, nije signal) i `flyway_schema_history` (Flyway-ova sopstvena tabela,
nije u `V1`/`V2` sadržaju) — **prazan**. `pg_get_functiondef(norm_text)` — **identičan**.

**C2 (alembic daje identičnu šemu I podatke kao sirov SQL):** `mig` baza napravljena isključivo
kroz `alembic upgrade head`. Schema diff (`ref` vs `mig`, filtrirano `\restrict`) — **prazan**.
Data diff prvim pokušajem (`pg_dump --data-only`) **nije bio prazan** — ali ne zbog redosleda
redova (kako je originalno pretpostavljeno) nego zbog `created_at`/`updated_at DEFAULT now()`:
svaki od dva odvojena učitavanja hvata stvarno vreme umetanja, pa se te dve kolone **uvek**
razlikuju između bilo koje dve nezavisne primene, bez obzira na alat. Rešenje: `md5(string_agg(...
order by id))` po tabeli, eksplicitno isključujući `created_at`/`updated_at` — `destination` (323
reda) i `destination_alias` (541 red) daju **identičan heš** između `ref` i `mig`; ostalih 17
tabela je prazno u obe (samo geo seed ima podatke pre nego što počne ingest).

`ref` i `mig` baze su namerno zadržane (ne obrisane) — trebaju za C3, koji čeka korisnikov
pregled ova dva nalaza.

### Kotlin — I DALJE POSTOJI, KOMPAJLIRA I STARTUJE, JEDINI JE RADNI BACKEND ✓

**Ništa u ovom odeljku nije menjano ADR 0001 koracima 1–1c.** `apps/api` je netaknut. Ovo je i
dalje jedini API koji stvarno odgovara na HTTP zahteve — Python API ne postoji dok se ne urade
koraci 2–4.

`./gradlew build` prolazi čisto **ako `JAVA_HOME` pokazuje na JDK ≤21** (vidi §9 — sistemski
`JAVA_HOME` je JDK 25 i to ruši Kotlin 2.1.0 kompajler). `./gradlew bootRun` starta API na
`:8080`. Flyway automatski primenjuje V1 i V2 pri startu. Swagger UI na `/swagger-ui.html`.

Popravke koje su bile potrebne pri prvom buildu:
- Kotlin 2.1.0 parser bug: `/**` unutar KDoc bloka (`/internal/**`) zbuni parser; zamenjeno `//` komentarima
- `inline fun forEachChildCombination` imao lokalnu funkciju `recurse` — nije dozvoljeno u Kotlinu; `inline` uklonjen

Napisano: `ApiApplication`, config (ApiProperties, ApiKeyFilter, Web, Jackson, OpenApi),
common (Errors, PageResponse, Text), `domain/Enums.kt`, `OccupancySolver` + 17 testova,
`PriceIndexBuilder`, `ExchangeRateService`, `DestinationResolver`, `AccommodationResolver`,
`CrawlRunService`, ingest (DTO, Service, Controller, OfferWriter),
search (SearchRequest, SearchResult, SearchService, SearchController).

**`Enums.kt`, `IngestDto.kt`, `Text.kt` su od 17.08.2026 zamrznuti** (§4.2) — ne ažuriraj ih
ručno da prate `travelcore`, ionako nestaju u koraku 6.

**Stvarni endpoint-i** (`build.gradle.kts` koristi `spring-boot-starter-jdbc`, **NE** JPA —
`docs/ARCHITECTURE.md` i root `README.md` još pominju JPA, to je zastarelo, vidi §9):

| Metod + putanja | Fajl | Autentikacija |
|---|---|---|
| `GET /api/search` | `SearchController` | javno |
| `POST /internal/runs` | `IngestController` | `X-API-Key` = `INGEST_API_KEY` |
| `POST /internal/ingest/offers` | `IngestController` | isto |
| `POST /internal/runs/{runId}/finish` | `IngestController` | isto |
| `GET /swagger-ui.html`, `/actuator/{health,info,metrics}` | Spring Boot / springdoc | javno (dev) |

Konfiguracioni parametri iz `application.yml` (bitno za dalji rad, nigde drugde upisano —
**ovi brojevi moraju preći u FastAPI config u koraku 4, ne izmišljati nove**):
- pretraga: `default-page-size=20`, `max-page-size=100`, keš TTL 300s, `max-staleness-hours=96`
- ingest: `suspect-ratio=0.5`, `history-window=5` (isto što i §4.6), `max-offers-per-batch=500`
- lead (za kasnije, endpoint još ne postoji): `max-per-hour-per-ip=5`, `max-per-hour-per-email=3`,
  `retention-days=365`, `consent-text-version="2026-08-01"`
- CORS dozvoljen samo za `http://localhost:3000`

### Python API (FastAPI) — NE POSTOJI JOŠ

ADR 0001 koraci 2–4 nisu počeli. Nema `apps/api` Python varijante, nema FastAPI aplikacije, nema
`alembic` skeleta. Kad se ovo pokrene, ide u modul-po-modul redosledu iz tabele iznad.

### Adapteri — STANJE

| Adapter | Fajl | Status |
|---|---|---|
| soleazur.rs | `adapters/soleazur.py` | ✓ Gotov i **VERIFIKOVAN**. Fixture snimljen iz pravog DOM-a 16.08.2026, 19 testova nad njim. Prepravljen: rowspan, `h6` ime objekta, redosled dokumenta, jedan offer po prevozu, cena PO OSOBI |
| oktopod.rs | `adapters/oktopod.py` | ✓ Gotov, 22 testa. `table.CSSTableGenerator`, dve tabele = dve dužine boravka (ne dva prevoza), kapacitet iz "Broj plativih osoba", `room_code` uključuje sufiks (STD/RENOV) da se izbegne kolizija. `discover()` čita `sitemap.xml` (1093 `/sr/putovanje/` unosa, potvrđeno). Doplata za AC (6€/dan) se traži po tekstu stranice — nema fixture sa tim delom DOM-a, samo sintetički test |
| grandtours.rs | — | Nema fixture, ali struktura potvrđena: 3× `table.tablepress`. Čeka Chrome dozvolu za domen |
| euroturs.rs | — | Nema fixture, struktura potvrđena: `table.main-table` |
| planatravel.rs | — | Cenovnik traži query string `?checkinDate=…&nights=7&adults[0]=2`, pun page reload |
| onlinetravel.rs | — | `table.tablepress-id-<n>`, ali primer je izlet a ne letovanje |
| maestral.co.rs | — | **NEMA cenovnik na sajtu**, samo forma za upit. Ne čekati fixture |
| aquatravel.rs | — | Cene tek posle AJAX poziva iz forme. Ne čekati fixture |
| ostali talas 2 | — | Čekaju fixtere |

### `apps/web` — POSTOJI, nije prazan

Next.js App Router, stvarni fajlovi: `app/{layout,page}.tsx`, `app/pretraga/{page,loading}.tsx`,
`app/api/lead/route.ts` (placeholder), `components/{SearchForm,OfferCard,PaxSelector,LeadModal}.tsx`,
`lib/{api,types,utils}.ts`. `npm run build` prolazi (§7). `.env.local.example` postoji.
Nije dirano ADR 0001 koracima, gađa isti `/api/search` ugovor bez obzira ko ga servira.

### NE POSTOJI

- Python/FastAPI API sloj u celini (ADR 0001 koraci 2–4)
- `alembic` migracije (i dalje Flyway)
- `GET /api/offers/{id}`, `GET /api/destinations` (autocomplete), lead API, admin API — nijedan
  od ovih endpoint-a još ne postoji ni u Kotlin `IngestController`/`SearchController` niti bilo gde drugde
- Offer detail stranica (`/ponuda/[slug]`) u `apps/web`
- Facet sidebar (filter po ceni, zvezdama, usluzi)
- CI (GitHub Actions)
- Politika privatnosti, uslovi korišćenja
- `docs/DATA_MODEL.md` — pominje ga `docs/ARCHITECTURE.md` ali fajl ne postoji

---

## 7. TODO, po redosledu

### Backend migracija (ADR 0001) — glavni prioritet trenutno

1. ~~**Korak 1: `packages/travelcore`**~~ ✓ 1a+1b+1c gotovi 17.08.2026 (commit-i `8a70043`,
   `1c4a1b5`, `08584f2` za import-linter). Vidi §6 tabelu za detalje.
2. ~~**Korak 2: `alembic` skelet.**~~ ✓ Gotov u celini 19.08.2026. `V1__init.sql`/`V2__seed_geo.sql`
   u `apps/api/migrations/sql/`, revizije `0001`/`0002`, `postgres_data` volumen od 15.08 obrisan
   i baza nastala isključivo kroz `alembic upgrade head`. Vidi §6 tabelu, commit-i
   `daf7926`…`18d70cf`.
3. **Korak 3: `OccupancySolver` u Python.**
   - **3a** ✓ commit `ad8bc2d` — `OccupancySolverTest.kt` → `apps/api/tests/test_occupancy.py`,
     svih 17 testova, nepromenjeni očekivani brojevi. Komitovano dok crveno
     (`ModuleNotFoundError`, implementacija još ne postoji) — dokaz da je specifikacija zapisana
     pre implementacije.
   - **3b** ✓ commit `2cc2926` — `apps/api/src/travelapi/pricing/occupancy.py`. **Svih 17
     testova prošlo iz prve.** `ruff`/`mypy --strict` čisti (mypy zahteva
     `packages/travelcore/src/travelcore` u istom pozivu, isti obrazac kao za `apps/scrapers`).
     Sedam zamki iz Kotlina prenete doslovno (ne popravljene) — vidi §9 za pun spisak i
     obrazloženje svake. **Nalaz o `BigDecimal ==`: NULA mesta.** Sva poređenja u
     `OccupancySolver.kt` idu preko `<`/`<=`/`>`/`>=` (compareTo u Kotlinu), nijedno preko `==`.
     Python `Decimal`-ova prirodna `==` se za te operatore ponaša identično Kotlinovom
     `compareTo`-u (za razliku od `BigDecimal.equals()`, koji jeste osetljiv na skalu) — nikakav
     `quantize`/tuple obilazak nije bio potreban nigde u `occupancy.py`.
     Usput otkriven i rešen nepovezan problem: `apps/scrapers/tests/__init__.py` i
     `apps/api/tests/__init__.py` su oba pravila paket po imenu `tests`, kolizija pri `pytest`
     kolekciji iz korena (`ModuleNotFoundError` na drugom paketu). Oba `__init__.py` obrisana —
     `pytest.ini` već koristi rootless "prepend" import mode, nisu ni trebala.
   - **3c** — proširenje pokrivenosti (5 novih testova: `PER_PERSON_PER_NIGHT`, `PriceSlot.INFANT`,
     više dece različitog uzrasta, `capacity_total` koji se ne slaže sa
     `capacity_adults + capacity_extra`, memoizacija sa zadatim `rooms`), zaseban commit. **Čeka
     korisnikov pregled 3b pre početka.**
   - **3d** — merenje najgoreg slučaja (8 odraslih, 4 dece, 6 soba), broj u §9. Posle 3c.
   - Detalji zamki: `instrukcije/porukazaclaudecode8.md`. Poznati, namerno neispravljen bug u
     rangiranju dece (zamka 4) — popravka ide u ZASEBAN commit POSLE 3c, ne sad.
4. **Korak 4: Ostatak API-ja**, modul po modul: `errors` → `db` → `geo` → `accommodation` →
   `ingest` → `pricing/price_index` → `search`. Svaki modul nosi svoje testove. `numeric` iz
   Postgresa mora stizati kao `Decimal` (psycopg 3), nikad `float`.
   - **Format na žici (ADR 0002, docs/decisions/0002-format-na-zici.md):** `/internal/*` prima
     **snake_case** (isto što skreper šalje danas — `core/ingest.py` se NE dira), `/api/*` vraća
     **camelCase** (frontend `lib/types.ts` već tako čita).
   - **Obavezan ugovorni test, deo ovog koraka, ne opciono:** pravi `OfferIn` sa punim sadržajem
     mora proći kroz pravi `POST /internal/ingest/offers` i stići u bazu nepromenjen. Ne mock,
     ne poređenje šema — pravi HTTP zahtev, prava baza. Dosad ovaj lanac **nikad nije proveren
     od kraja do kraja** (vidi ADR 0002 — `start_run` je radio slučajno, ostatak ugovora nije).
   - **Enumi koji nedostaju u `travelcore.enums`, popisano 18.08.2026, ne raditi pre koraka 4:**
     `SourceHealth`, `LeadStatus`, `AliasStatus` (kolone u bazi → idu u `travelcore`, kao i
     ostali enumi). `SortBy`, `SortDirection` su stvar API-ja → idu u `travelapi`, ne u
     `travelcore`. `BoardType` u Kotlinu ima i `labelSr` i `rank`, u Pythonu trenutno nema —
     proveriti da li ta dva polja stvarno trebaju pre nego što se dodaju.
5. **Korak 5: E2E provera.** `soleazur` skreper → `POST /internal/ingest` (Python API sad) →
   baza → `GET /search` vraća tu ponudu. `IngestClient` u skreperu se ne menja.
6. **Korak 6: Brisanje Kotlina.** Tek posle koraka 5, zaseban commit — `apps/api/src/main/kotlin`,
   `src/test/kotlin`, `build.gradle.kts`, `settings.gradle.kts`, `gradle/`, `gradlew*`, JVM Dockerfile.
   **Podsetnik (ne zaboraviti u ovom koraku):** `docker-compose.yml` još ima komentar
   `# API se u razvoju pokreće iz IntelliJ-a (./gradlew bootRun), ne odavde.` iznad `api` servisa
   i prosleđuje `DATABASE_URL_JDBC` tom servisu. Oboje umire zajedno sa Kotlinom — zameniti
   komentar i env promenljivu da odgovaraju Python/FastAPI pokretanju. Ne dirati pre koraka 6.
7. **Korak 7: VS Code.** `.vscode/{settings,extensions,launch}.json`, ukloniti IntelliJ/Gradle
   pominjanja iz `README.md`.
8. **Korak 8: Ovaj fajl, finalni prolaz.** §2/§4/§8/§9/§10 posle brisanja Kotlina (delimično
   već urađeno u ovom rewrite-u unapred).

### Skreperi / adapteri

9. ~~**Skreper framework**~~ ✓ `core/{settings,fetch,adapter,registry,ingest,pipeline}.py`
   + `cli.py` + `adapters/__init__.py`. CLI: `travelscrape run/snapshot/recon/sources`.
10. ~~**Recon CLI**~~ ✓ `travelscrape recon <slug> <url>` — detektuje platformu, robots.txt,
    sitemap, JS/SPA, API endpointe. Piše `docs/recon/<slug>.md`.
11. ~~**Adapter soleazur.rs**~~ ✓ Urađeno i VERIFIKOVANO 16.08.2026.
12. ~~**Adapter oktopod.rs**~~ ✓ Urađeno 17.08.2026.
13. **Adapter grandtours.rs** — sledeći na redu, čeka fixture (Chrome ekstenzija nema dozvolu
    za domen još).
14. **Ostali adapteri talasa 1/2** — `euroturs.rs`, `planatravel.rs`, `onlinetravel.rs`,
    `travelland.rs`, `felixtravel.rs`, `timtravel.rs`, `magictravel.rs`, `amostravel.rs`,
    `rapsodytravel.rs`, `belvi.rs`, `lidertravel.rs`, `hedonictravel.rs`, `sabra.rs` — svi
    čekaju fixture.

### Frontend / ostalo

15. ~~**Next.js frontend**~~ ✓ Urađeno 16.08.2026.
16. Lead API sa rate limitom i `delete_after` job-om (piše se u okviru koraka 4, kao FastAPI ruta).
17. Admin panel za `PENDING` aliase.
18. NBS sinhronizacija kursa (`exchange_rate`).
19. CI: `pytest` (oba paketa) + `ruff` + `mypy --strict` + `lint-imports`. `gradlew test` ispada
    iz CI-ja čim se izvrši korak 6.
20. Politika privatnosti i uslovi korišćenja **pre** nego što lead forma primi prvi upit.

---

## 8. Tvrda pravila — NE MENJATI bez izričite saglasnosti korisnika

1. **Enum vrednosti se menjaju na dva mesta odjednom**: `packages/travelcore/src/travelcore/enums.py`,
   CHECK ograničenja u migraciji. (Dok Kotlin `Enums.kt` postoji fizički u repou, on je
   **zamrznut** — §4.2, §6 — i namerno se NE ubraja u ovo pravilo dok traje ADR 0001 prelazak;
   posle koraka 6 pravilo ponovo važi doslovno na dva mesta jer trećeg više neće ni biti.)
2. **`travelcore.normalize.text.normalize()` u Pythonu i `norm_text()` u SQL-u moraju da vraćaju
   identičan rezultat.** Ako se raziđu, alias tabele prestaju da pogađaju i sistem tiho pravi
   duplikate. Specifičnost: `đ → dj` (ne `d`, kako bi dao goli `unaccent`), ćirilica se prvo
   prevodi u latinicu. Test `test_sql_parity.py` ovo čuva — ne isključuj ga. Kotlin `Text.kt` je
   zamrznut (§4.2) — ne mora da prati izmene dok traje prelazak.
3. **Novac je uvek `Decimal` (Python) / `BigDecimal` (Kotlin dok postoji), nikad `float`.**
4. **Primenjena Flyway migracija se ne menja**, piše se nova. (Isto važi za alembic migracije
   posle koraka 2.)
5. **Nema ručnog `ALTER TABLE`** ni u lokalnoj bazi.
6. **Obrasci parsiranja idu u `travelcore/normalize/`, ne u adapter.** Pravilo o domenu ("PP znači
   polupansion") je deljeno; pravilo o sajtu ("cena je u `data-price`") je adapterovo.
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
9. **`OccupancySolver` pravila cena su namerno konzervativna** (vidi KDoc u Kotlin fajlu, uskoro i
   docstring u `pricing/occupancy.py`). Dete u osnovnom ležaju plaća kao odrasla osoba jer dečja
   cena na srpskim cenovnicima važi za **pomoćni** ležaj. Radije precenimo nego da prikažemo nižu
   cenu od stvarne. Ne "popravljaj" ovo bez razgovora — i ne menjaj brojeve u testovima kad se
   prevodi u koraku 3, oni su specifikacija.
10. **Rezultat solver-a je procena za poređenje, ne rezervacija.** Ne znamo koliko jedinica je
    slobodno. Frontend to mora jasno da kaže.
11. **Nema plaćanja ni rezervacije na našem sajtu.** Samo lead forma i redirect.
12. **Lični podaci**: saglasnost nije unapred štiklirana, `consent_text_version` se čuva, IP se
    čuva **hešovan sa solju**, `delete_after` se postavlja pri kreiranju leada.
13. **Devet izvora je TRAJNO van opsega. Odluka doneta 16.08.2026, ne otvara se ponovo.**
    `bigblue.rs`, `fibula.rs`, `filiptravel.rs`, `odeontravel.rs`, `deustravel.rs`,
    `feniks-tours.rs`, `vivatravel.rs`, `balkanviator.com`, `lasta.rs`.

    Njihov `robots.txt` nabraja skrepere sa `Disallow: /`. Naš bot `KudaPutujemBot` nije
    na tim spiskovima, pa nas slovo protokola formalno ne pokriva — ali projekat je
    svesno postavljen kao pravno čist, pa se namera poštuje isto kao slovo.

    Šta to konkretno znači:
    - **Ne pišu se adapteri za njih.**
    - **Ne šalju im se mejlovi** za dozvolu ni za feed. Ne kontaktiramo ih uopšte.
    - **Ne traže se zaobilazni putevi** — ni drugi poddomen, ni partnerski sajt koji
      preprodaje istu ponudu, ni preimenovanje bota.

    Princip: koristimo samo ono do čega se dolazi **brzo i jednostavno, sa sajta same
    agencije, uz njen pristanak izražen kroz `robots.txt`.** Sve ostalo se preskače.

    Ovo nije konačno za sva vremena — kad sajt poraste i bude imao šta da ponudi
    agencijama, pregovori se mogu otvoriti. Do tada se lista ne dira.

    Ista provera važi za **svaki novi izvor**: `docs/recon/<slug>.md`, polje „Blokira nas".
    Ako blokira, izvor se ne uključuje i ne kontaktira.

14. **`selectolax` `css("a, b")` NE vraća redosled dokumenta** nego prvo sve `a` pa sve `b`.
    Kad kontekst zavisi od redosleda (naslov važi za tabelu ispod njega), koristi
    `tree.root.traverse(include_text=False)`. Ovo je tiho pogrešan rezultat, ne greška.
15. **HTML tabele sa `rowspan` se ne čitaju po fiksnom indeksu ćelije.** Red nastavka ima
    manje ćelija. Računaj pomak iz `len(cells)` u odnosu na očekivani broj kolona.
16. **Tajne nikad u repo.** `INGEST_API_KEY` i `ADMIN_API_KEY` su namerno odvojeni — skreper koji
    procuri ne sme da može da briše agencije.
17. **`travelcore` je čist domenski sloj, provereno alatom — ADR 0001, 17.08.2026.** Sme da
    zavisi samo od `pydantic` (`python-dateutil`/`rapidfuzz` samo ako normalizacija stvarno
    uvozi — trenutno ne uvozi). **Ne sme** da uvozi `httpx`, `selectolax`, `typer`, `structlog`,
    `tenacity`, `playwright`, `rich`, niti da zna za `travelscrape`. Provereno automatski:
    `.importlinter` u root-u (dva kontrakta), pokreni sa `lint-imports` posle svake izmene u
    `packages/travelcore` ili u tome ko šta uvozi. Ako neki modul iz `travelcore` mora nešto sa
    zabranjene liste, taj modul ne pripada `travelcore`-u — seli se u `travelscrape`. Vidi §4.8.
18. **Kad tip strane biblioteke kaže `Optional`, a ne možemo to opovrgnuti kroz njen javni API,
    granu obrađujemo. Ne pišemo `assert` ni `# type: ignore` da bismo tvrdili da znamo bolje od
    tipa.** (17.08.2026, `selectolax`-ov `HTMLParser.root: Node | None`.) Razlog: „ne validiraj
    scenario koji ne može da se desi" važi za **poslovna pravila nad ulazom koje mi kontrolišemo**
    — ovo je strana biblioteka čiji tip kaže da vrednost sme biti `None`, mi ne kontrolišemo tu
    verziju i sutra se ponašanje može promeniti. `assert` bi na tom ulazu pucao (`AssertionError`
    umesto `[]`), `# type: ignore` trajno laže proveraču tipova na mestu koje niko više neće
    pogledati. Guard koji vraća prazno je jeftiniji od oba. Ako grana nije dostižna kroz javni API
    biblioteke (proveri pre nego što pretpostaviš — vidi `soleazur.py`/`oktopod.py` primer),
    test za nju je **karakterizacioni, ne regresioni**: tvrdi „ovako se ponašamo danas", ne
    „ovo je nekad bilo pokvareno". Regresioni test koji ne pada na starom kodu ne dokazuje ništa
    — proveri to eksplicitno pre nego što ga upišeš kao regresiju.

---

## 9. Poznati problemi i rizici

| Problem | Ozbiljnost | Napomena |
|---|---|---|
| Kotlin kompajlira i startuje, ali samo sa JDK ≤21 | ⚠ zavisi od `JAVA_HOME`, **privremeno — nestaje u koraku 6 ADR 0001** | Toolchain u `build.gradle.kts` traži 21. Sistemski `JAVA_HOME` je JDK 25 (`C:\Program Files\Java\jdk-25`); Kotlin 2.1.0 kompajlerov parser verzije puca na stringu `"25.0.1"` (`IllegalArgumentException` u `JavaVersion.parse`) i `./gradlew` ne radi UOPŠTE dok se to ne pokrene sa JDK 21 eksplicitno. Ne trošiti vreme na trajni fix — Kotlin se briše čim Python API dostigne paritet (korak 5). |
| ~~`mypy --strict`/`ruff` pred-postojeći dug~~ | ✓ rešeno 17.08.2026 | Bilo 14 mypy + 11 ruff nalaza, sad 0/0. Commit-i `daf7926` (tipske sitnice), `83596d2` i `7b47cb7` (dva stvarna, izdvojena ispravka ponašanja — vidi §6). Urađeno namerno PRE koraka 2, da crvena osnovna linija ne sakrije prve nove greške iz ~1200 linija koje dolaze u koracima 3–4. |
| SSRF provera u `fetch.py` je do 17.08.2026 propuštala teorijsku (nedostižnu u praksi) `int` adresu iz `getaddrinfo()` bez greške | ✓ rešeno | Commit `83596d2`. Vidi §6 za detalje — `_is_forbidden_ip` sad eksplicitno odbija sve što nije `str`. |
| `soleazur.py parse_price_page` je pucao na praznom/nevalidnom HTML-u umesto da vrati `[]` | ✓ rešeno | Commit `7b47cb7`. `HTMLParser.root` je `Node \| None` po selectolax stub-u, adapter sad to proverava pre `.traverse()`. |
| `AccommodationResolver.fuzzyHit` čita `stars` kao `BigDecimal` cast-om | srednja, Kotlin, nestaje u koraku 6 | proveriti da PostgreSQL driver vraća `BigDecimal` za `NUMERIC(2,1)`; ako ne, puca u runtime-u. Kad se prevede u Python (korak 4), postaje `Decimal` iz psycopg 3, problem nestaje sam po sebi |
| `PriceIndexBuilder.loadDepartures` koristi `Triple` sa ugnježdenim parom | niska, Kotlin, nestaje u koraku 6 | radi, ali je nečitko; pri prevodu u korak 4 pisati kao dataclass/namedtuple umesto tuple-a, ne prevoditi doslovno |
| Kursna lista ima hardkodovane rezervne vrednosti | srednja | EUR≈117.20 RSD; treba NBS sinhronizacija (§7 stavka 18) |
| Solver pretpostavlja neograničen broj jedinica svakog tipa | prihvaćeno | dokumentovano, mora se reći korisniku u UI-ju. Preneti napomenu u `pricing/occupancy.py` docstring kad se prevede (korak 3) |
| `raw_document` će brzo rasti | srednja | brisati starije od 30 dana, particionisati po mesecu preko 50 GB |
| Nema CI | srednja | testovi se za sada pokreću ručno; CI plan je §7 stavka 19, čeka da se Kotlin sklone iz matrice |
| Fixture je skraćen na 2 od 10 sekcija (soleazur) | niska | pokriva sve strukturne slučajeve; puna stranica ima 84 reda |
| `docs/ARCHITECTURE.md` i root `README.md` su ZASTARELI na više mesta | **visoka**, raste sa ADR 0001 | Oba pominju "Spring Data JPA + JdbcTemplate" iz pre-JdbcClient ere, i sad dodatno ne pominju Python API plan uopšte. Ne veruj tim fajlovima za tehnološke odluke — **ovaj fajl (CLAUDE.md) je jedini izvor istine**. Prepisati oba tek u ADR 0001 koraku 7/8, ne pre — nema smisla ih menjati dvaput. |
| `docs/recon/*.md` imaju "Pouzdanost: low/medium" na skoro svakom sajtu iz prve (skuplje) recon runde | niska | Nalazi za te sajtove su i dalje najbolja dostupna informacija dok se ne potvrde lokalno u browseru (kao što je urađeno za soleazur i oktopod); ne tretiraj "low" kao "netačno", tretiraj kao "neverifikovano" |
| `psycopg` 3 puca na bukvalnom `%` u SQL-u kad se izvršava kroz SQLAlchemy | **visoka za korak 4** | Otkriveno u alembic reviziji 0001 — `V1__init.sql` ima komentar `"-20%"`. `op.execute()`/`Connection.exec_driver_sql()` idu kroz SQLAlchemy-ev `cursor.execute(statement, parameters)` čak i sa praznim `parameters`, a psycopg 3 tada PARSIRA string tražeći `%s`/`%b`/`%t` placeholdere i puca na svakom drugom `%`. Rešenje ovde: sirovi DBAPI kursor (`connection.connection.cursor().execute(sql)`, tačno JEDAN argument) — `migrations/_raw_sql.py`. **Isto pravilo važi za FastAPI u koraku 4**: svaki raw SQL sa mogućim bukvalnim `%` (LIKE obrasci, komentari, JSON operatori `?`/`@>`) mora ili kroz vezane parametre (`cursor.execute(sql, params)`, gde se `%s` STVARNO koristi kao placeholder), ili kroz sirovi kursor bez drugog argumenta — nikad `op.execute(plain_string)` stila bez razmišljanja o ovome. |
| `gen_geo_seed.py` ima 6 pred-postojećih ruff nalaza | niska | Prvi put linted 18.08.2026 (novi `apps/api/pyproject.toml` prvi put uključuje `scripts/`). `E501`×2, `UP020`×2 (`io.open` → `open`), `SIM115`×2 (context manager). Nisu uvedeni ADR 0001 korakom 2 — samo `OUT` putanja je menjana u tom fajlu (§6). Ne diraj ih uz migracioni posao, zaseban commit ako se radi. |
| ~~`test_sql_parity.py` nikad nije pokrenut na ovoj mašini~~ | ✓ rešeno 17.08.2026 | Tražio `psql` na PATH-u, kojeg nema jer je Postgres u Dockeru — test se preskakao **zauvek**, tiho, bez upozorenja. Commit `791d4aa`: prepisan na `psycopg`. Sad prvi put stvarno pokrenut: **153/153 prolazi**, Python i SQL normalizacija se slažu. Ne pretpostavljaj da je nešto provereno samo zato što test postoji — proveri da li se stvarno IZVRŠAVA. |
| ~~Postojeći `postgres_data` Docker volume imao lozinku iz 15.08, ne iz `.env.example`~~ | ✓ rešeno 19.08.2026 | Volume od 15.08 je obrisan u ADR 0001 koraku C3 (§6), posle rezervne kopije i provere da nema podataka van geo seed-a. Nova baza je nastala isključivo kroz `alembic upgrade head`, sa nasumičnom lozinkom u `.env`. I dalje opšte pravilo za budućnost: pre nego što izmisliš lozinku za `.env`, proveri `docker volume ls` — ako `kudaputujem_postgres_data` već postoji, lozinka mora da odgovara onoj sa kojom je volume prvi put pokrenut, inače `FATAL: password authentication failed` sa host mašine (`docker compose exec` i dalje radi jer container-interni `pg_hba.conf` trust-uje loopback unutar kontejnera bez obzira na lozinku — ne daj se zavarati time). |
| Dva odvojena `.venv` (`apps/scrapers/.venv`, `apps/api/.venv`) | ✓ rešeno 19.08.2026 | Spojeni u jedan `.venv` u korenu (§6, §10) — korak 5 (E2E) treba isto okruženje za skreper i API, korak 4 dodaje `travelapi` kao treći `.importlinter` `root_package`. |
| ~~Dva `tests/__init__.py` (scrapers, api) kolizija imena paketa~~ | ✓ rešeno 19.08.2026 | Oba se zvala paket `tests`, `pytest` iz korena je uzeo prvi u sys.modules i pukao na drugom (`ModuleNotFoundError`) — otkriveno pri dodavanju `apps/api/tests/test_occupancy.py`. Oba `__init__.py` obrisana (commit `2cc2926`), `pytest.ini` već koristi rootless "prepend" import mode pa nisu ni bila potrebna. |
| **Poznat, NAMERNO neispravljen bug u `OccupancySolver`: rangiranje dece za pomoćni ležaj ne prati stvarnu naplatu** | srednja, dokumentovan, **ne popravljati bez razgovora** | Preneto doslovno iz `OccupancySolver.kt` u `occupancy.py` (`_room_cost`, komentar uz `_child_key`). Deca se biraju za pomoćni ležaj po `child_price` (ili `adult_price` kao rezervi ako nema dečje cene), ali se naplaćuju po `extra_bed_price`. Kad je `extra_bed_price < adult_price`, pohlepan izbor po `child_price` nije nužno optimalan po stvarnoj naplati — moguće je da bi drugačiji raspored dece dao nižu ukupnu cenu. Nijedan od 17 postojećih testova ovo ne pokriva (svi imaju `extra_bed_price >= adult_price` u fixture-ima). Popravka je planirana za **poseban commit posle koraka 3c** (ADR 0001 korak 3, `porukazaclaudecode8.md`), namerno odvojena od porta jer bi promenila očekivane brojeve. |
| Sedam zamki iz Kotlina, prenete doslovno u `occupancy.py` — pregled | informativno | (1) `UNSOLVABLE` sentinela `Decimal("999999999")` sa `>=`, ne `None`/`math.inf`. (2) **Nula** mesta sa `BigDecimal ==` u `OccupancySolver.kt` (sva poređenja su `<`/`<=`/`>`/`>=`) — Python `Decimal` prirodno odgovara Kotlinovom `compareTo`, nikakav `quantize`/tuple obilazak nije trebao. (3) Dvostruko zaokruživanje: po sobi odmah (`quantize` u `_best`), ukupno tek na kraju u `solve()` — zbir cena po sobama zato ne mora biti jednak ukupnoj ceni, komentarisano u kodu. (4) Bug u rangiranju dece — vidi red iznad, NIJE popravljen. (5) `Party.__post_init__` baca `ValueError`, `minimum_for_adults` ga hvata (`except ValueError`). (6) `child_price` uzima minimum po svim poklapajućim opsezima, opseg bez granica podrazumevano `0..11`, ne "bez ograničenja". (7) Memo ključ `(adults, counts, rooms_used)` namerno NE sadrži `required_rooms` — ispravno samo dok je `required_rooms` konstantan kroz jedan `solve()` poziv (i jeste, svež `memo` dict po pozivu), komentarisano u kodu da se ta pretpostavka ne naruši slučajno. |

---

## 10. Okruženje i komande

Korisnik radi na **Windows**, projekat u `D:\Kiki\kudaputujem`. IntelliJ IDEA Ultimate za Kotlin
deo (dok postoji), VS Code je ciljni editor za Python + Next.js (ADR 0001 korak 7).

**Jedan `.venv` u korenu repoa** (`D:\Kiki\kudaputujem\.venv`, Python 3.12) za sva tri Python
paketa — `packages/travelcore`, `apps/scrapers`, `apps/api`. Od 19.08.2026 NEMA više posebnih
venv-ova po paketu (§6, §9).

```bash
# baza i keš — .env VEĆ POSTOJI, ima nasumičnu lozinku (proveri lokalno, ne piši je u CLAUDE.md).
# Ako ga praviš iznova: copy .env.example .env, PRE toga proveri "docker volume ls" (§9) da
# ne pogodiš postojeći volumen sa drugom lozinkom.
docker compose up -d postgres redis
docker compose ps        # oba "healthy"

# jedan venv za sve — pravi se JEDNOM, redosled zavisnosti je bitan
python -m venv .venv
.venv\Scripts\activate
pip install -e packages/travelcore
pip install -e "apps/scrapers[dev]"
pip install -e "apps/api[dev]"

# pytest iz korena — pokuplja apps/scrapers/tests I apps/api/tests (pytest.ini u korenu)
pytest                        # bez DATABASE_URL: 151 prolazi, 13 preskočeno (test_sql_parity.py)
set DATABASE_URL=postgresql://kudaputujem:<lozinka-iz-.env>@localhost:5432/kudaputujem
pytest                        # sa bazom: 164 testa, 0 preskočeno (stanje 19.08.2026, raste sa svakim korakom)

# lint/tipovi — i dalje per-paket (svaki ima svoj ruff/mypy config u svom pyproject.toml)
(cd apps/scrapers && ruff check .)                                          # očekivano: čisto
(cd apps/api && ruff check migrations src/travelapi)                        # očekivano: čisto (gen_geo_seed.py ima 6 pred-postojecih nalaza, §9, ne diraj uz migracioni posao)
python -m mypy --strict packages/travelcore/src/travelcore apps/scrapers/src/travelscrape   # očekivano: čisto
python -m mypy --strict apps/api/migrations apps/api/src/travelapi                          # očekivano: čisto

# provera granice travelcore/travelscrape (pravilo 17)
lint-imports    # pokreni iz root-a repoa, čita .importlinter; očekivano "2 kept, 0 broken"

# alembic — jedina staza do razvojne baze od 19.08.2026, Flyway se više NE koristi za nju
cd apps/api
set DATABASE_URL=postgresql://kudaputujem:<lozinka-iz-.env>@localhost:5432/kudaputujem
alembic upgrade head          # primenjuje 0001 (V1) pa 0002 (V2), jedna transakcija za oba
alembic downgrade -1          # namerno diže NotImplementedError, ne dira bazu (pravilo o jednosmernim migracijama)
cd ..

# regeneracija geo migracije posle izmene geo.yaml (izlaz je apps/api/migrations/sql/V2__seed_geo.sql)
python apps/api/scripts/gen_geo_seed.py

# API (Kotlin, JOŠ RADI, koegzistira sa gornjim) — gradlew VEĆ POSTOJI (apps/api/gradlew).
# Ako je sistemski JAVA_HOME JDK 25, gradlew ne radi (vidi §9); postaviti privremeno na JDK <=21:
set JAVA_HOME=C:\Users\korisnik\.jdks\ms-21.0.8
cd apps/api
./gradlew build
./gradlew bootRun       # http://localhost:8080, Swagger na /swagger-ui.html
cd ../..

# web frontend
cd apps/web
npm install
npm run dev              # http://localhost:3000, --turbopack
npm run build             # prod build, prolazi čisto
```

`.env` (u root-u) se pravi kopiranjem root `.env.example`. `apps/web/.env.local.example` je
poseban fajl samo za `apps/web` (`NEXT_PUBLIC_API_BASE_URL`).

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
5. ~~Koliko agencija u prvoj javnoj verziji — 5, 10 ili 20?~~ **Odgovoreno 18.08.2026: svih 22
   upotrebljiva izvora.** Vidi §13, "Pun obim, bez skraćivanja" — vlasnik projekta je eksplicitno
   odbio raniji predlog da se prva verzija skrati na 6–8 agencija, jednu zemlju, bez lead forme.
6. **Kontakt mejl** za `User-Agent` skrepera i za lead formu. (Više ne blokira dopisivanje
   sa agencijama — po odluci od 16.08.2026. agencije se ne kontaktiraju.)
7. ~~Da li da se krene na ADR 0001 korak C3?~~ **Odgovoreno i urađeno 19.08.2026** (§6, §13).
   **Da li da se krene na ADR 0001 korak 3 (OccupancySolver)** je sad ekvivalentno pitanje —
   ovaj obrazac se ponovio već ČETIRI puta (posle 1c, posle mypy/ruff čistke i parity testa,
   posle C1, posle C2) i korisnik svaki put tražio pauzu pre nastavka. **Ne pretpostavljaj da
   je pauza gotova dok korisnik eksplicitno ne kaže "kreni na korak 3" ili ekvivalentno.**

---

## 13. Kratka istorija odluka

| Datum | Odluka |
|---|---|
| 15.08.2026 | Kotlin + Spring Boot za API, Python za skrepere (hibrid, ne jedan jezik) — **napušteno 17.08.2026, vidi ADR 0001** |
| 15.08.2026 | Next.js umesto React+Vite — SEO je presudan za agregator |
| 15.08.2026 | PostgreSQL + Redis; Meilisearch odložen |
| 15.08.2026 | Sva tri tipa proizvoda u MVP-ju, ne samo aranžmani |
| 15.08.2026 | Pre-crawl indeks umesto live fan-out pretrage |
| 15.08.2026 | Lead forma umesto pukog redirecta ili pune rezervacije |
| 15.08.2026 | Scraping uz pristojna pravila; bez kontaktiranja platformi za feed za sada |
| 15.08.2026 | JdbcClient umesto JPA (princip "raw SQL, bez ORM-a" se prenosi i u ADR 0001, psycopg 3 umesto SQLAlchemy) |
| 15.08.2026 | Ime projekta: "Kuda putujem", paket `rs.kudaputujem` |
| 15.08.2026 | Grupisanje izvora po platformi umesto po agenciji (nalaz recona) |
| 16.08.2026 | Recon 33 sajta završen — TourVisio i Fibula isključeni, Onesystem u treći talas; mali agenti sa HTML tabelama su pravi target |
| 16.08.2026 | Adapter soleazur.rs gotov — `adapters/soleazur.py`, jedna PHP stranica sa svim LM cenama, 24 testa |
| 16.08.2026 | `StrEnum` compatibility shim dodat u `core/enums.py` (Python 3.8 nema `StrEnum`, dodat je u 3.11) |
| 16.08.2026 | Recon izveštaji (33 fajla) integrisani u `docs/recon/`, `docs/SOURCES.md` i §4.4/§4.4b usklađeni |
| 16.08.2026 | Chrome povezan; 22 sajta mapirana kroz pravi browser, selektori potvrđeni umesto pretpostavljeni |
| 16.08.2026 | soleazur cena je PO OSOBI (`CENA ARANŽMANA PO OSOBI` na `/hoteli/<slug>`), ne po jedinici — ranija pretpostavka ispravljena |
| 16.08.2026 | soleazur adapter prepravljen: rowspan, redosled dokumenta, jedan offer po prevozu zbog UNIQUE indeksa na `departure` |
| 16.08.2026 | **Devet blokiranih izvora trajno van opsega, bez kontaktiranja.** Projekat ide isključivo na ono što je javno dostupno sa sajta agencije uz `robots.txt` pristanak. Bez mejlova, bez zaobilaznih putanja, bez pregovora u ovoj fazi |
| 16.08.2026 | `putovanja.bigblue.rs` ima sopstveni `robots.txt` koji dozvoljava sve osim `.asmx`/`.ashx`; `.aspx` nije zabranjen. Ipak se ne koristi — vidi pravilo 13, poslednja alineja |
| 17.08.2026 | Lokalno okruženje prebačeno na Python 3.12 + `.venv` u `apps/scrapers`; Python 3.8 workaround više ne treba |
| 17.08.2026 | Adapter oktopod.rs gotov — `adapters/oktopod.py`, 22 testa. `discover()` preko `sitemap.xml` (potvrđeno 1093 `/sr/putovanje/` unosa), ne generičkim linkovima sa listing stranica |
| 17.08.2026 | `SurchargeUnit.PER_UNIT_PER_NIGHT` dodat (Python `core/enums.py` + Kotlin `Enums.kt`, dok su još oba živa) — nedostajala je granularnost "po jedinici po noći" za doplate tipa parking/klima. Nema CHECK ograničenje u V1 migraciji za ovo polje (nikad nije ni postojalo) |
| 17.08.2026 | Nalaz: sistemski `JAVA_HOME` je JDK 25, Kotlin 2.1.0 kompajler puca na tom stringu verzije — okidač za ADR 0001, vidi sledeći red |
| **17.08.2026** | **ADR 0001 prihvaćen: ceo backend prelazi na Python, Kotlin/Spring se briše.** Dokument: `docs/decisions/0001pythononly.md`. Razlog: enum promena je tražila izmenu na dva mesta u dva jezika bez ikakve mehaničke provere (ništa ne bi prijavilo da je jedno zaboravljeno), plus `JAVA_HOME`/JDK 25 problem je porez na okruženje. Ciljni stack: FastAPI, psycopg 3, alembic, redis-py async — sve u §3 |
| 17.08.2026 | ADR 0001 korak 1b — `packages/travelcore` napravljen, `travelscrape` re-eksportuje (shim). Commit `8a70043`. 140 testova prolazi, nula izmena u testovima — dokaz da je premeštanje verno |
| 17.08.2026 | ADR 0001 korak 1c — shim-ovi obrisani kao fajlovi, `travelscrape` uvozi direktno iz `travelcore`. Commit `1c4a1b5`. Test diff samo import linije, isti brojevi testova, mypy/ruff pred-postojeći nalazi nepromenjeni |
| 17.08.2026 | Pravilo 17 (pominjano u instrukcijama kao "pravilo 16", prenumerisano jer je 16 već zauzeto tajnama) — `import-linter` sa `.importlinter` u root-u, dva kontrakta. Commit `08584f2`. `lint-imports`: 2 kept, 0 broken |
| 17.08.2026 | Odluka: mypy/ruff pred-postojeći dug se čisti PRE ADR 0001 koraka 2, ne posle. Razlog: koraci 3–4 pišu ~1200 novih linija; crvena osnovna linija bi sakrila prvu novu grešku u toj gomili — "crvena osnovna linija je isto što i pokvaren detektor dima" |
| 17.08.2026 | mypy --strict 14→0, ruff 11→0 u `packages/travelcore`+`apps/scrapers/src/travelscrape`. Commit `daf7926` (12 tipskih sitnica bez promene ponašanja). Dva nalaza NISU bile sitnice — izdvojene u zaseban commit po eksplicitnom zahtevu da se ispravke ponašanja ne zakopavaju u "čišćenje" |
| 17.08.2026 | `fetch.py` SSRF provera: `_is_forbidden_ip` sad eksplicitno odbija ne-`str` adresu umesto da je tiho propusti kroz `ipaddress.ip_address()` (koji int prihvata kao IP). Commit `83596d2`. Nedostižno u praksi za ovaj poziv, ali SSRF zaštita ne sme da ima teorijsku rupu |
| 17.08.2026 | `soleazur.py parse_price_page` ne puca više na praznom/nevalidnom HTML-u (`tree.root` je `Node \| None`), vraća `[]` kao ostatak adaptera. Commit `7b47cb7` |
| 17.08.2026 | `test_sql_parity.py` prepisan sa `psql`/`subprocess` na `psycopg` sa vezanim parametrom (commit `791d4aa`) — stari test je tražio `psql` na PATH-u koji na ovoj Windows mašini ne postoji (Postgres je u Dockeru), pa se **preskakao zauvek, tiho**, bez ijednog upozorenja. Prvi stvarni pokretanje nad pravom bazom: **153/153 prolazi** — Python `normalize()` i SQL `norm_text()` se slažu za svih 13 slučajeva, nema razilaženja |
| 17.08.2026 | Otkriveno pri podizanju baze: `postgres_data` Docker volume je postojao od 15.08.2026 sa lozinkom `promeni_me` (default), ne sa novom lozinkom koju je ova sesija prvo generisala. `.env` usklađen sa stvarnim stanjem volumena, ne obrnuto — menjanje `POSTGRES_PASSWORD` u `.env` ne menja lozinku već inicijalizovane baze |
| 18.08.2026 | Test za `fetch.py` SSRF popravku (commit `08704a1`) genuinski pada na starom kodu — ali tek posle ispravke: prvi pokušaj (`12345`) je slučajno pao u `0.0.0.0/8` koji `ipaddress` i dalje flaguje kao privatnu adresu, pa je lažno prolazio na oba koda. Ispravna vrednost `1500000000` → `89.104.47.0` (nije privatna) stvarno demonstrira propust |
| 18.08.2026 | Testovi za `soleazur.py`/`oktopod.py` prazan-HTML granu NE padaju na kodu pre `7b47cb7` — provereno eksplicitno (privremeno vraćen stari fajl). `selectolax` kroz javni API ove verzije nikad ne vraća `None` za `.root` ni za jedan probani string ulaz (HTML5 auto-repair). Prijavljeno korisniku umesto tiho zataškano |
| **18.08.2026** | **Pravilo 18: kad tip strane biblioteke kaže `Optional`, a ne možemo to opovrgnuti kroz njen javni API, obrađujemo granu — ne `assert` (puca umesto da vrati `[]`), ne `# type: ignore` (trajno laže proveravač). "Ne validiraj scenario koji ne može da se desi" važi za poslovna pravila nad ulazom koji kontrolišemo, ne za tip strane biblioteke čiju verziju ne kontrolišemo.** Testovi za `soleazur.py`/`oktopod.py` prazan-HTML granu preimenovani u karakterizacione (tvrde "ovako se ponašamo danas", ne "ovo je bio bag"). Commit `78159c8` |
| 18.08.2026 | ADR 0001 korak 2: `apps/api` dobija Python `.venv` (paket `travelapi`) i `alembic` skelet, koegzistira sa Kotlinom bez sukoba. `V1__init.sql`/`V2__seed_geo.sql` premešteni čist rename (sha256 potvrđen) u `apps/api/migrations/sql/`. Revizije `0001`/`0002` rade preko sirovog DBAPI kursora — `op.execute()`/`exec_driver_sql()` idu kroz SQLAlchemy-ev prazan-parametar poziv koji navodi psycopg 3 da parsira bukvalni `%` u SQL komentaru (`"-20%"`) kao placeholder i puca. Commit `2d07b3d` |
| 18.08.2026 | C1: `pg_dump --schema-only` diff između baze od 15.08 i `ref` (današnji SQL) — prazan van nasumičnog `\restrict`/`\unrestrict` tokena (potvrđeno različit na dva uzastopna dump-a iste nepromenjene baze) i `flyway_schema_history` (Flyway-ova tabela, nije u V1/V2 sadržaju). `pg_get_functiondef(norm_text)` identičan. Baza od 15.08 NIJE zastarela |
| 18.08.2026 | C2 kriterijum ispravljen: `--schema-only` diff sam po sebi ne dokazuje da su PODACI ubačeni — da revizija `0002` uopšte ne izvrši, diff bi i dalje bio prazan. Dodata provera podataka |
| 18.08.2026 | C2: `pg_dump --data-only` diff između `ref` i `mig` (alembic) NIJE bio prazan prvim pokušajem — ne zbog redosleda redova (očekivano u instrukciji) nego zbog `created_at`/`updated_at DEFAULT now()`, koje hvataju stvarno vreme svakog od dva odvojena učitavanja i uvek će se razlikovati nezavisno od alata. Rešenje: `md5(string_agg(... order by id))` po tabeli, isključujući te dve kolone — `destination` i `destination_alias` daju identičan heš, ostalih 17 tabela prazno=prazno. Šema I podaci potvrđeno identični |
| **18.08.2026** | **Pun obim, bez skraćivanja — odluka vlasnika projekta.** Svih 22 upotrebljiva izvora dobijaju adapter. Lead forma ostaje. Admin panel ostaje. Sve tri vrste proizvoda ostaju: paket, samo prevoz, samo smeštaj. Rok nije ograničenje. Kvalitet i širina imaju prednost nad brzinom lansiranja. Nijedna funkcionalnost se ne izbacuje radi ranijeg puštanja. Raniji predlog (skraćivanje na 6–8 agencija, jednu zemlju, bez lead forme) je **odbijen i ne važi** |
| **18.08.2026** | **ADR 0002: format na žici, ispravka greške iz ADR 0001.** ADR 0001 je tvrdio da format ostaje nepromenjen (camelCase svuda) na osnovu neprovere pretpostavke. Stvarno stanje: `IngestClient.send_batch` šalje `model_dump(mode="json")` (**snake_case**), `IngestDto.kt`/`JacksonConfig.kt` očekuju camelCase bez naming strategije — lanac skreper→API nikad nije prošao od kraja do kraja, radio je samo `start_run` jer tamo ručno piše `{"sourceSlug": ...}`. Odluka: `/internal/*` ostaje **snake_case** (Python priča sa Pythonom, skreper se ne dira), `/api/*` je **camelCase** (frontend `lib/types.ts` već tako čita). Dokument: `docs/decisions/0002-format-na-zici.md`. Obavezan ugovorni test u koraku 4 — pravi `OfferIn` kroz pravi `/internal/ingest/offers`, ne mock (§7) |
| 19.08.2026 | Dokaz atomičnosti sirovog kursora u `migrations/_raw_sql.py`: privremena namerna greška na kraju revizije 0002, pušteno `alembic upgrade head` nad praznom bazom — posle pada **nula tabela**, uključujući sve iz 0001. Kursor deli alembic-ovu transakciju (`op.get_bind().connection`), ne otvara novu. Izmena vraćena, `git diff` prazan pre commit-a |
| 19.08.2026 | Prebrojano §8: 18 pravila, neprekidan niz 1–18, bez rupe i duplikata. Pravilo 18 (Optional iz strane biblioteke) je ispravan broj — 17 je već zauzet import-linter pravilom (pomerenim sa "16" u poruci 3 jer je 16 zauzeto tajnama). Korisnikova sumnja "dogovorili smo se za 17" je bila zasnovana na nepotpunoj slici numeracije, ne na stvarnoj grešci |
| **19.08.2026** | **Jedan `.venv` u korenu umesto po paketu.** `apps/scrapers/.venv` i `apps/api/.venv` obrisani, sve tri paketa (`travelcore`, `travelscrape`, `travelapi`) instalirani u `D:\Kiki\kudaputujem\.venv`. Razlog: korak 5 (E2E) treba isto okruženje za skreper i API; korak 4 dodaje `travelapi` kao treći `.importlinter` `root_package`; VS Code bira jedan interpreter po prozoru. `pytest.ini` u korenu. Commit `18d70cf` |
| **19.08.2026** | **ADR 0001 korak 2 GOTOV — `postgres_data` volumen od 15.08 obrisan, baza nastala isključivo kroz `alembic upgrade head`.** Pre brisanja: korisnik tražio rezervnu kopiju i proveru sadržaja — `docker volume rm` je i sam sistem prvo blokirao kao destruktivnu radnju (auto-mode klasifikator), korisnik eksplicitno potvrdio nastavak preko `AskUserQuestion`. Backup 129KB/2727 linija (van repoa, `/tmp`), potvrđeno preko `count(*)` po tabeli da nema ničeg van geo seed-a (`destination`=323, `destination_alias`=541, ostalih 17 tabela=0). Nova baza, nasumična lozinka u `.env`. **164 testa prolaze, 0 preskočeno** (153 iz poruke 4 + `test_fetch.py` + prošireni karakterizacioni testovi iz poruka 5/6) |
| 18.08.2026 | Odluka vlasnika: **pun obim, bez skraćivanja.** Svih 22 izvora, lead forma, admin panel, sve tri vrste proizvoda ostaju; rok nije ograničenje. Raniji predlog (6–8 agencija, jedna zemlja, bez lead forme) odbijen i ne važi. §12 pitanje 5 zatvoreno |
| 18.08.2026 | ADR 0002: format na žici. Ispravka pretpostavke iz ADR 0001 (da format ostaje nepromenjen) — `IngestClient` šalje snake_case, Kotlin `IngestDto`/`JacksonConfig` očekuju camelCase bez naming strategije, lanac skreper→API nikad nije prošao end-to-end (samo `start_run` je radio, slučajno). Odluka: `/internal/*` snake_case, `/api/*` camelCase. `docs/decisions/0002-format-na-zici.md`. Ugovorni test kroz pravi zahtev postaje obavezan deo koraka 4 |
| 19.08.2026 | ADR 0001 korak 3a: `OccupancySolverTest.kt` → `apps/api/tests/test_occupancy.py`, svih 17 testova, komitovano dok crveno (`ModuleNotFoundError`) kao dokaz da je specifikacija zapisana pre implementacije. Commit `ad8bc2d` |
| **19.08.2026** | **ADR 0001 korak 3b: `occupancy.py`, svih 17 testova prošlo iz prve.** Commit `2cc2926`. Nula mesta sa `BigDecimal ==` u `OccupancySolver.kt` (sva poređenja `<`/`<=`/`>`/`>=`) — Python `Decimal` se za te operatore ponaša identično Kotlinovom `compareTo`, nikakav obilazak nije trebao. Sedam zamki prenete doslovno, uklj. namerno neispravljen bug u rangiranju dece za pomoćni ležaj (§9) — popravka čeka poseban commit posle 3c |
| 19.08.2026 | Usput otkriveno i rešeno: `apps/scrapers/tests/__init__.py` i `apps/api/tests/__init__.py` su oba pravila paket `tests`, kolizija pri `pytest` kolekciji iz korena. Oba obrisana — nisu ni trebala uz `pytest.ini` rootless import mode |
