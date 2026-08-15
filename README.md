# Putovanja — metapretraživač turističkih ponuda (Srbija)

Agregator ponuda srpskih turističkih agencija: aranžmani (prevoz + smeštaj), samo prevoz i samo smeštaj.
Podaci se skidaju skreperima u naš indeks, korisnik pretražuje indeks, a kontakt ide preko lead forme.

## Stack

| Sloj | Tehnologija |
|---|---|
| API | Kotlin 2.1 + Spring Boot 3.4, Gradle KTS, Flyway, Spring Data JPA + JdbcTemplate |
| Skreperi | Python 3.12, httpx + selectolax, Playwright za JS sajtove, Typer CLI |
| Baza | PostgreSQL 16 (+ `pg_trgm`, `unaccent`, `btree_gist`) |
| Keš / red poslova | Redis 7 |
| Web | Next.js 15 (App Router) + TypeScript + Tailwind |
| Lokalno okruženje | Docker Compose |

## Struktura

```
apps/api        Kotlin backend: public search API, ingest API, admin API, lead API
apps/scrapers   Python: adapteri po izvoru, recon alat, runner
apps/web        Next.js frontend
docs/           arhitektura, model podataka, katalog izvora, pravne napomene
infra/          docker, init skripte
```

## Pokretanje (lokalno)

```bash
cp .env.example .env

# 1) baza + redis
docker compose up -d postgres redis

# 2) API (migracije se izvrše automatski)
cd apps/api && ./gradlew bootRun          # prvi put: gradle wrapper

# 3) skreperi
cd apps/scrapers && python -m venv .venv && .venv/Scripts/activate   # Windows
pip install -e ".[dev]"
travelscrape sources list

# 4) web
cd apps/web && npm install && npm run dev
```

API: http://localhost:8080 (Swagger na `/swagger-ui.html`)
Web: http://localhost:3000

## Kako se dodaje nova agencija

1. `travelscrape recon https://www.agencija.rs` → generiše `docs/recon/agencija.md` sa profilom sajta
   (robots.txt, sitemap, da li je SSR ili XHR, pronađeni JSON endpointi, framework).
2. Napisati adapter u `apps/scrapers/src/travelscrape/adapters/agencija.py` (naslediti `BaseAdapter`).
3. Upisati agenciju i izvor u bazu (`docs/SOURCES.md` + seed migracija ili admin API).
4. `travelscrape run agencija --limit 20 --dry-run` → proveriti normalizovan izlaz.
5. `travelscrape run agencija` → ingest u API.

## Dokumentacija

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — arhitektura, tok podataka, odluke
- [docs/DATA_MODEL.md](docs/DATA_MODEL.md) — model podataka i normalizacija
- [docs/SOURCES.md](docs/SOURCES.md) — katalog izvora i njihov status
- [docs/LEGAL.md](docs/LEGAL.md) — pravila skrepovanja i zaštita podataka
