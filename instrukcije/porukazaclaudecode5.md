# Poruka za Claude Code

Kopiraj sve ispod crte u terminal.

---

A i B su prihvaćeni. Izdvajanje ona dva nalaza iz commita čišćenja je bilo tačno —
`ipaddress.ip_address()` koji guta `int` je prava rupa u fail-closed grani, bez obzira
što je nedostižna kroz ovaj poziv.

Dve stvari pre koraka C. Prva je propust, druga je nešto što tvoj izveštaj otkriva
a nisi ga tako pročitao.

## A) Nedostaju testovi za dva bug fix-a

`83596d2` i `7b47cb7` su ispravke ponašanja, ne tipske sitnice. Sam si ih tako i
izdvojio, s pravom. Ali nijedan nije došao sa testom.

Pravilo projekta je da svaka ispravka buga nosi test koji pada pre nje. Bez toga smo
za tri meseca u istoj rupi i nemamo pojma da smo je već jednom zatvorili.

Dodaj u zasebnom commitu:

- **`fetch.py`, SSRF:** test koji zameni `socket.getaddrinfo` tako da vrati adresu u
  obliku koji je ranije prolazio, i potvrdi da `fetch` sada odbija. `monkeypatch`,
  bez mreže.
- **`soleazur.py`, prazan HTML:** `parse_price_page("")` i
  `parse_price_page("<html></html>")` vraćaju `[]`, ne dižu izuzetak.
  Dodaj isti par i za `oktopod.py`, jer i on ima istu granu.

Vrati oba na commit pre ispravke i potvrdi da testovi tamo padaju. Ako prolaze,
test ne pokriva ono što misliš da pokriva.

## B) Parity test je prošao nad bazom koju nismo proverili

Ovo je važnije.

Napisao si da je `postgres_data` volumen od **15.08.** i da šemu nisi ponovo učitavao.
To znači da `norm_text()` u toj bazi potiče od one verzije `V1__init.sql` kakva je bila
15.08, a ne od one koja je danas u repou.

153/0 je zeleno **nad tom bazom**. To još nije dokaz da se Python slaže sa SQL-om koji
je u repou. Dokaz je tek kad se baza napravi iz današnjih fajlova.

Verovatno je sve u redu — `Đerdap` i `Đenovići` prolaze, pa `đ → dj` jeste tamo.
Ali „verovatno" je premalo za jedini test koji čuva alias mehanizam.

Zato korak C dobija još jedan zadatak: da odgovori i na pitanje da li smo dva dana
razvijali protiv zastarele šeme.

## C) Alembic, sada u tri dela

### C1. Provera odstupanja postojeće baze

Pre nego što bilo šta obrišeš:

```
# sta je danas u bazi
docker compose exec -T postgres pg_dump -U kudaputujem --schema-only kudaputujem > staro.sql

# sta daju danasnji fajlovi
docker compose exec -T postgres createdb -U kudaputujem ref
docker compose exec -T postgres psql -U kudaputujem -d ref < ...V1__init.sql
docker compose exec -T postgres psql -U kudaputujem -d ref < ...V2__seed_geo.sql
docker compose exec -T postgres pg_dump -U kudaputujem --schema-only ref > ref.sql

diff staro.sql ref.sql
```

**Javi mi taj `diff`, prazan ili ne.**

Ako nije prazan, razvijali smo protiv zastarele šeme i hoću da znam u čemu tačno.
Posebno pogledaj definiciju funkcije:

```
docker compose exec -T postgres psql -U kudaputujem -d kudaputujem \
  -tAc "select pg_get_functiondef(oid) from pg_proc where proname='norm_text'"
```

### C2. Alembic, pa poređenje sa referencom

```
docker compose exec -T postgres createdb -U kudaputujem mig
alembic upgrade head            # ka bazi mig
docker compose exec -T postgres pg_dump -U kudaputujem --schema-only \
    --exclude-table=alembic_version mig > mig.sql

diff ref.sql mig.sql
```

`diff` mora biti prazan. To je prihvatni kriterijum koraka 2.

Detalji, nepromenjeni od prošle poruke:

- `.sql` fajlovi se sele u `apps/api/migrations/sql/` bez ijedne izmene sadržaja.
  `git status` mora pokazati čist `rename`. Proveri `sha256sum` ako git ne prepozna.
- revizija `0001` → `V1__init.sql`, `0002` → `V2__seed_geo.sql`, kroz `op.execute`
- `sqlalchemy.url` iz `DATABASE_URL`, ne u `alembic.ini`
- migracije su jednosmerne, `downgrade()` diže `NotImplementedError`.
  Nikakav `DROP SCHEMA public CASCADE`.
- nijedan `import sqlalchemy` u kodu aplikacije

### C3. Razvojna baza se pravi iznova, kroz alembic

Kad C2 bude prazan, ne vraćamo se na volumen od 15.08.

```
docker compose down
docker volume rm kudaputujem_postgres_data
```

U `.env` postavi **pravu lozinku**, ne `promeni_me`. Sad je pravi trenutak, jer baza
ionako nastaje iznova. Proveri da je `.env` u `.gitignore` — ako nije, dodaj pre commita.

Zatim `docker compose up -d postgres redis`, `alembic upgrade head`, pa pun `pytest`.

**Očekivanje: 153 prolazi, 0 preskočeno**, sada nad bazom koja je nastala iz današnjih
fajlova kroz alembic. Tek to je pravi rezultat parity testa.

Obriši i `ref` i `mig` baze kad završiš.

## Sitnica

Tvoj izlaz kaže `1 shell still running`. Proveri šta je i ugasi ako je zaostalo.

## Redosled

A → C1 → **stani i javi mi `diff staro.sql ref.sql`** → C2 → C3.

Kod C1 stani bez obzira na ishod. Ako je diff prazan, to je isto vredna informacija
i idemo dalje odmah.
