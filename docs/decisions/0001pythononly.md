# ADR 0001: Ceo backend je Python, Kotlin/Spring se uklanja

Status: **prihvaćeno**, 17.08.2026.
Zamenjuje: odluku iz `CLAUDE.md` §2 o Kotlin 2.1 + Spring Boot 3.4 API-ju.

## Kontekst

Backend je bio podeljen na dva jezika:

- `apps/scrapers` — Python 3.12, pydantic modeli, normalizacija
- `apps/api` — Kotlin 2.1 + Spring Boot 3.4, JdbcClient, Flyway

Granica između njih je HTTP (`POST /internal/ingest`). Zbog toga isti pojmovi
postoje **dva puta**, ručno održavani u paru:

| Pojam | Python | Kotlin |
|---|---|---|
| enumi | `core/enums.py` | `domain/Enums.kt` (170 linija) |
| model ponude | `core/models.py` | `ingest/IngestDto.kt` (209 linija) |
| normalizacija teksta | `normalize/text.py` | `common/Text.kt` (53 linije) |

Uz to, `norm_text()` u `V1__init.sql` je **treća** implementacija istog pravila.

### Šta je odluku pokrenulo

16.08.2026, u jednoj jedinoj izmeni:

1. Dodavanje jedne enum vrednosti (`SurchargeUnit.PER_UNIT_PER_NIGHT`) zahtevalo je
   izmenu na dva mesta u dva jezika. Ništa u alatima ne bi prijavilo da je jedno
   od ta dva zaboravljeno — greška bi se pojavila tek kao odbijeni ingest u produkciji.
2. `./gradlew compileKotlin` je pukao jer je sistemski `JAVA_HOME` postao JDK 25,
   a Kotlin 2.1.0 ne parsira taj version string. Rešenje je ručno postavljanje
   `JAVA_HOME` na JDK 21 pre svake komande.

Prvo je trajni porez na svaku izmenu modela. Drugo je porez na okruženje.
Projekat vodi jedan student, sam, uz fakultet.

## Odluka

**Ceo backend prelazi na Python 3.12.** Kotlin i Gradle se uklanjaju iz repoa.

Deljeni pojmovi se izdvajaju u zaseban paket od koga zavise i API i skreperi:

```
packages/travelcore/src/travelcore/
    enums.py            ← jedini izvor istine, briše se Enums.kt
    models.py           ← jedini izvor istine, briše se IngestDto.kt
    normalize/          ← jedini izvor istine, briše se Text.kt
```

Broj implementacija istog pravila pada sa tri na dve: Python i SQL.
Test parnosti `norm_text()` ostaje i dalje obavezan.

### Šta se NE menja

- **HTTP granica ostaje.** Skreperi i dalje šalju `POST /internal/ingest`.
  API je i dalje jedini proces koji piše u bazu. Skreperi ne dobijaju kredencijale baze.
- **Format na žici ostaje identičan** (`sourceSlug`, `runId`, camelCase).
  `IngestClient` u skreperima se ne dira. Ni `apps/web` se ne dira.
- **SQL migracije ostaju doslovno iste.** `V1__init.sql` i `V2__seed_geo.sql`
  su verifikovani nad pravim Postgresom i prelaze nepromenjeni.
- **Bez ORM-a.** Odluka „raw SQL, ne JPA" je bila ispravna i prenosi se.
- Next.js 15 frontend, PostgreSQL 16, Redis 7 — nepromenjeni.

## Ciljni stack

| Uloga | Bilo | Sada | Zašto baš to |
|---|---|---|---|
| Web framework | Spring Boot Web | **FastAPI** | pydantic je već u projektu; validacija i OpenAPI izlaze iz istih modela |
| Server | Tomcat | **uvicorn** | standard za ASGI |
| Pristup bazi | JdbcClient | **psycopg 3** + `psycopg_pool` | raw SQL, isti duh kao JdbcClient; `numeric` stiže kao `Decimal` |
| Migracije | Flyway | **alembic** | standardni Python alat; `.sql` fajlovi ostaju netaknuti unutar `op.execute()` |
| Keš | spring-cache + Lettuce | **redis-py** (async) | eksplicitni pozivi, jer se invalidacija vezuje za kraj crawl runde |
| Serijalizacija | Jackson | **pydantic v2** | već u projektu |
| Testovi | JUnit + Kotest + MockK | **pytest** | već u projektu, 130+ testova radi |
| Test baza | Testcontainers (JVM) | **testcontainers-python** | isti projekat, Python izdanje |
| Lint / tipovi | ktlint + `-Xjsr305=strict` | **ruff + mypy strict** | već konfigurisani |
| Editor | IntelliJ IDEA | **VS Code** | jedan editor za Python i za Next.js |

`alembic` povlači `SQLAlchemy` kao zavisnost. **SQLAlchemy se ne koristi u kodu
aplikacije** — služi isključivo kao pogon alembica. Pristup bazi je psycopg + SQL.

## Cena prelaska

3164 linije Kotlina, od čega:

| Deo | Linija | Sudbina |
|---|---|---|
| `Enums.kt`, `IngestDto.kt`, `Text.kt` | 432 | **nestaju** — čisti duplikat |
| `config/*`, `Errors.kt`, `PageResponse.kt` | 296 | svode se na ~80 linija FastAPI koda |
| `SearchService`, `OfferWriter`, `PriceIndexBuilder`, resolveri, `CrawlRunService` | 1417 | prevod mehanički, **SQL stringovi se prepisuju doslovno** |
| `OccupancySolver` + test | 529 | čist algoritam, prevod 1:1 |
| Gradle | 51 | nestaje |

Neto novi Python: procenjeno 1100–1300 linija.
Trajna ušteda: nema više ručnog održavanja para enum/DTO/normalizacija.

## Rizici i kako se pokrivaju

1. **Tiha promena ponašanja pri prevodu.** Najveći rizik.
   Pokriva se time što se `OccupancySolverTest.kt` prevodi u `pytest` **pre**
   solvera, sa nepromenjenim očekivanim brojevima. Ti brojevi su verifikovana
   specifikacija, ne implementacioni detalj.
2. **Zaokruživanje novca.** `BigDecimal` → `decimal.Decimal`, nikad `float`.
   Svako mesto gde je Kotlin imao eksplicitan `RoundingMode` mora dobiti
   eksplicitan `ROUND_HALF_UP` u Pythonu. Podrazumevane vrednosti se razlikuju.
3. **Brzina `OccupancySolver`-a.** Python je sporiji od JVM-a. Ulaz je mali
   (≤8 putnika, nekoliko tipova soba), pa je razlika u mikrosekundama.
   Meri se i broj se upisuje u `CLAUDE.md`. Ako ikad postane usko grlo,
   rešenje je više predračuna u `departure_price_index`, ne drugi jezik.
4. **Gubitak keširanja.** Spring je keširao anotacijama; u Pythonu je eksplicitno.
   Pre brisanja Kotlina mora se popisati koji su endpointi bili `@Cacheable`,
   sa kojim TTL-om, i to preneti.
5. **Šema baze se ne sme pomeriti.** Posle prelaska na alembic, `pg_dump --schema-only`
   nad bazom migriranom alembicom mora biti **identičan** onom migriranom Flywayem.
   To je prihvatni kriterijum, ne preporuka.

## Redosled izvođenja

Svaki korak je zaseban commit i svaki se završava zelenim `pytest`-om.
Kotlin se briše **poslednji**, da povratak nazad ostane moguć do samog kraja.

1. `packages/travelcore` — izdvajanje enuma, modela i normalizacije iz `travelscrape`.
   `travelscrape` privremeno re-eksportuje iste simbole, da 130+ postojećih testova
   prođe bez ijedne izmene. **Provera: ceo paket zelen, bez dodiranja testova.**
2. alembic skelet, `V1`/`V2` SQL nepromenjen. **Provera: `pg_dump` diff prazan.**
3. `OccupancySolverTest.kt` → `tests/test_occupancy.py`, svi testovi crveni.
   Zatim `pricing/occupancy.py` dok ne pozelene.
4. Ostatak API-ja, modul po modul, redosledom: `errors` → `db` → `geo` →
   `accommodation` → `ingest` → `pricing/price_index` → `search`.
   Uz svaki modul idu njegovi testovi.
5. Provera kraj-do-kraja: skreper `soleazur` → `POST /internal/ingest` → baza →
   `GET /search` vraća tu ponudu. Bez izmene `IngestClient`-a.
6. Brisanje `apps/api/src/main/kotlin`, `src/test/kotlin`, `build.gradle.kts`,
   `settings.gradle.kts`, `gradle/`, `gradlew*`, i JVM `Dockerfile`. Zaseban commit.
7. VS Code: `.vscode/settings.json`, `extensions.json`, `launch.json`.
   Uklanjanje pominjanja IntelliJ-a i Gradle-a iz `README.md` i `CLAUDE.md`.
8. Prepisivanje `CLAUDE.md` §2, §4, §8, §9, §10 i unos u §12.

## Šta bi promenilo ovu odluku

Ako pretraga pod opterećenjem pokaže da je Python sloj usko grlo — a ne Postgres —
razmatra se prepisivanje **samo** `/search` endpointa. Do tada, jedan jezik.
