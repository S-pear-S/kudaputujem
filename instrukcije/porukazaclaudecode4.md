# Poruka za Claude Code

Kopiraj sve ispod crte u terminal.

---

1c je prihvaćen. Dve tvoje odluke su bile ispravne: `Text.kt` KDoc se ne dira do koraka 6,
i vraćanje onih 8 `ruff --fix` izmena van ovog commita.

Odgovor na 13 preskočenih menja plan. Ne krećemo odmah na alembic.

## Ono što je ispalo najvažnije

Tih 13 preskočenih je `test_sql_parity.py`. To nije sporedan test. To je jedini test
koji proverava da Python `normalize()` i SQL `norm_text()` daju isti rezultat.

Ako se to dvoje raziđe, ništa ne pukne. Skreper upiše alias `djerdap`, baza traži
`derdap`, alias tabele prestanu da pogađaju, i pretraga tiho vraća manje rezultata
nego što treba. Nema izuzetka, nema loga, nema crvenog testa.

**Taj test nikad nije pokrenut na ovoj mašini.** Uvek je bio preskočen.
Prioritet je da počne da se pokreće, pre nego što se doda išta novo.

## A) Prvo čišćenje duga, zaseban commit

14 `mypy --strict` grešaka i 11 `ruff` nalaza u `cli.py`, `core/{fetch,ingest,adapter,pipeline}.py`,
`adapters/{soleazur,oktopod}.py`. Tačan si da nisu tvoje i da nisu iz 1c.

Ipak ih sređujemo sada, pre koraka 2. Razlog: od koraka 3 pišemo oko 1200 novih linija.
Ako je `mypy --strict` crven pre nego što počnemo, nikad nećemo videti prvu **novu**
grešku u toj gomili. Crvena osnovna linija je isto što i pokvaren detektor dima.

U taj commit ide i onih 8 izmena koje je `ruff --fix` hteo, a ti vratio.

Cilj: `mypy --strict` nad `packages/travelcore` i `apps/scrapers/src` daje nulu,
`ruff check .` daje nulu, `pytest` i dalje 140 prolazi.

**Ograničenje:** ako neka tipska greška ne može da se reši bez promene ponašanja u
izvršavanju, to nije tipska sitnica nego pravi bug. Stani i prijavi ga posebno.
Ne zakopavaj ispravku ponašanja u commit koji se zove čišćenje.

Da `adapters/soleazur.py` i `adapters/oktopod.py` imaju tipske greške mi je najsumnjivije
od svega. To su fajlovi koji proizvode podatke. Njih pogledaj prve i reci mi šta su.

## B) Postgres gore, pa parity test prepisan

**B1. Digni bazu.**

```
copy .env.example .env
docker compose up -d postgres redis
docker compose ps
```

U `.env` promeni `POSTGRES_PASSWORD` i uskladi `DATABASE_URL` sa njim.

**B2. Prepiši `test_sql_parity.py` da koristi `psycopg`, ne `psql`.**

Sadašnja verzija ima dva problema:

1. Traži `psql` na `PATH`-u. Postgres je u Dockeru, pa na Windows hostu `psql` ne
   postoji i test se preskače zauvek. To je razlog zašto nikad nije pokrenut.
2. Vrednost se ubacuje u SQL kroz `$sql$...$sql$` umesto kao parametar.
   Radi za ovih 13 slučajeva, ali je pogrešan obrazac i ne prolazi našu obavezu o
   sanitizaciji ulaza.

Nova verzija: `psycopg.connect(DATABASE_URL)`, upit `select norm_text(%s)` sa vezanim
parametrom. Jedini uslov za preskakanje ostaje odsustvo `DATABASE_URL`.

Dodaj `psycopg[binary]>=3.2` u dev zavisnosti. Ista biblioteka je i glavna zavisnost
API-ja u koraku 4, pa ništa ne bacamo.

**B3. Napuni bazu i pusti test.**

```
docker compose exec -T postgres psql -U kudaputujem -d kudaputujem < apps/api/src/main/resources/db/migration/V1__init.sql
docker compose exec -T postgres psql -U kudaputujem -d kudaputujem < apps/api/src/main/resources/db/migration/V2__seed_geo.sql
pytest
```

Očekivanje: **153 prolazi, 0 preskočeno.**

Ako neki od 13 padne, to je pravo otkriće, ne smetnja. Javi mi tačno koji ulaz i
koje dve vrednosti se razlikuju. Ne popravljaj ni Python ni SQL dok ne pregledam,
jer nije unapred jasno koja je strana pogrešna.

## C) Tek onda korak 2, alembic

Kad B3 bude zeleno.

Referentna šema se **ne** dobija iz Flywaya. Ne treba nam JVM za ovo, a i ne bi ništa
dodalo, jer alembic revizije izvršavaju isti taj SQL. Referenca je direktna primena
`.sql` fajlova.

```
# referenca
docker compose exec -T postgres createdb -U kudaputujem ref
docker compose exec -T postgres psql -U kudaputujem -d ref < ...V1__init.sql
docker compose exec -T postgres psql -U kudaputujem -d ref < ...V2__seed_geo.sql
docker compose exec -T postgres pg_dump -U kudaputujem --schema-only ref > ref.sql

# alembic
docker compose exec -T postgres createdb -U kudaputujem mig
alembic upgrade head          # ka bazi mig
docker compose exec -T postgres pg_dump -U kudaputujem --schema-only \
    --exclude-table=alembic_version mig > mig.sql

diff ref.sql mig.sql
```

**`diff` mora biti prazan.** To je prihvatni kriterijum.

Detalji:

- `.sql` fajlovi se sele u `apps/api/migrations/sql/` **bez ijedne izmene sadržaja**.
  `git status` mora prikazati čist `rename`, ne `delete` + `add`. Proveri `sha256sum`
  pre i posle ako git ne prepozna preimenovanje.
- Revizija `0001` radi `op.execute` nad `V1__init.sql`, `0002` nad `V2__seed_geo.sql`.
- `sqlalchemy.url` se čita iz `DATABASE_URL`, ne upisuje se u `alembic.ini`.
- **Migracije su jednosmerne.** `downgrade()` za `0001` diže `NotImplementedError`
  sa jasnom porukom. Ne piši `DROP SCHEMA public CASCADE` — to je nož koji jednom
  omane i obriše pravu bazu. Upiši tu odluku u `CLAUDE.md`.
- SQLAlchemy je tu samo kao pogon alembica. Nijedan `import sqlalchemy` u kodu
  aplikacije. Kad API bude postojao, dodaj i to u `.importlinter` kao kontrakt.

## D) Sitnica za korak 6, samo da se ne zaboravi

`docker-compose.yml` još kaže:

```
# API se u razvoju pokreće iz IntelliJ-a (./gradlew bootRun), ne odavde.
```

i prosleđuje `DATABASE_URL_JDBC`. Oboje umire u koraku 6, ne diraj sada.
Samo dodaj podsetnik u `CLAUDE.md` §7 da ne promakne.

## Redosled

A → B1 → B2 → B3 → stani i javi.

Ne kreći na C dok ne vidim rezultat parity testa. Ako se Python i SQL razilaze,
menja se plan za korak 2.
