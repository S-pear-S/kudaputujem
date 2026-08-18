# Poruka za Claude Code

Kopiraj sve ispod crte u terminal.

---

C1 je prihvaćen. Objašnjenje za `\restrict` i `flyway_schema_history` je tačno, a
poređenje `pg_get_functiondef(norm_text)` između stare i `ref` baze je bilo baš ono
što je trebalo. Nismo razvijali protiv zastarele šeme. 153/0 stoji.

Ono sa `12345` koje slučajno padne u `0.0.0.0/8` pa ga `ipaddress` ionako flaguje kao
privatnu, i test lažno prolazi na oba koda — to je tačno ona vrsta zamke zbog koje se
traži da test padne na starom kodu. Dobro uhvaćeno.

## Odluka o `tree.root`: opcija 1, uz dopunu

Idemo na **1**, ali ne u obliku „ostavi i dokumentuj da je netestabilno".

### Zašto ne 2

Ako vratiš `7b47cb7`, `mypy --strict` odmah opet prijavi `Node | None`. Onda ti ostaju
samo `assert tree.root is not None` ili `# type: ignore`.

`assert` je gori od guarda — na praznom ulazu diže `AssertionError` umesto da vrati `[]`.
`type: ignore` je najgori, jer trajno laže proveraču tipova na mestu koje niko više
neće pogledati.

Vraćanje nije besplatno. Košta jedno zaobilaženje tipova, a to je skuplje od dve linije.

### Zašto ne 3

Menjati potpis produkcione funkcije da bi se dohvatila grana koja se ne može dogoditi
je rep koji maše psom. Dobio bi šav koji postoji samo zbog testa, i to na ulaznoj tački
adaptera, koju baš želimo stabilnom. Ne povećava bezbednost ni za šta.

### Gde tvoj princip stvarno važi

„Ne validiraj scenario koji ne može da se desi" se odnosi na **poslovna pravila nad
ulazom**. Ovo je nešto drugo: strana biblioteka svojim tipom kaže da vrednost sme biti
`None`. Autor stub-a je to napisao sa razlogom, a mi tu verziju ne kontrolišemo i sutra
se može promeniti.

Upiši u `CLAUDE.md` §8 kao **pravilo 17**:

> Kada tip strane biblioteke kaže `Optional`, a ne možemo to opovrgnuti kroz njen
> javni API, granu obrađujemo. Ne pišemo `assert` ni `# type: ignore` da bismo
> tvrdili da znamo bolje od tipa.

### Šta radiš sa testovima koje već imaš u radnom stablu

Zadrži ih, ali ih **preimenuj i preformuliši u karakterizacione testove**, ne u
regresione. Razlika je u tome šta tvrde.

Regresioni test tvrdi „ovo je nekad bilo pokvareno". To ovde nije tačno i zato ne pada
na starom kodu — s pravom si stao.

Karakterizacioni test tvrdi „ovako se sistem ponaša danas i to je namerno". Tu vrednost
ovi testovi stvarno imaju: ako sutra neko „pojednostavi" parser tako da
`parse_price_page("")` počne da diže izuzetak, test pada.

Konkretno:

- u docstringu piše da test fiksira postojeće ponašanje, a ne da čuva od nekadašnjeg buga
- pokrij `""`, `"<html></html>"`, `"   "` i HTML bez ijedne tabele
- isto za `oktopod`
- iznad guarda u kodu komentar: grana je po tipu moguća, kroz javni API ove verzije
  `selectolax` nedostižna, zadržana zbog pravila 17

Commituj to zajedno sa pravilom 17.

## Ispravka mog kriterijuma za C2

Moj prihvatni kriterijum je bio nepotpun i to je moja greška.

`pg_dump --schema-only` ne poredi **podatke**. `V2__seed_geo.sql` ubacuje 323
destinacije. Da alembic revizija `0002` uopšte ne bude izvršena, `--schema-only` diff
bi i dalje bio prazan i mi bismo to proglasili uspehom.

Zato C2 ima dve provere, ne jednu.

### C2, šema

`\restrict` token je nasumičan po dump-u, pa ga filtriraj da kriterijum bude čist:

```
docker compose exec -T postgres pg_dump -U kudaputujem --schema-only ref \
  | sed -e '/^\\restrict/d' -e '/^\\unrestrict/d' > ref.schema.sql

docker compose exec -T postgres pg_dump -U kudaputujem --schema-only \
  --exclude-table=alembic_version mig \
  | sed -e '/^\\restrict/d' -e '/^\\unrestrict/d' > mig.schema.sql

diff ref.schema.sql mig.schema.sql
```

### C2, podaci

```
docker compose exec -T postgres pg_dump -U kudaputujem --data-only ref \
  | sed -e '/^\\restrict/d' -e '/^\\unrestrict/d' > ref.data.sql

docker compose exec -T postgres pg_dump -U kudaputujem --data-only \
  --exclude-table=alembic_version mig \
  | sed -e '/^\\restrict/d' -e '/^\\unrestrict/d' > mig.data.sql

diff ref.data.sql mig.data.sql
```

**Oba `diff`-a moraju biti prazna.** To je prihvatni kriterijum koraka 2.

Ako `--data-only` ispadne osetljiv na redosled redova, koristi umesto njega proveru po
tabeli, sa eksplicitnim `order by` i `md5(string_agg(...))`. Javi ako do toga dođe.

Ostalo za C2 ostaje kako je dogovoreno: `.sql` fajlovi se sele bez izmene sadržaja i
`git status` mora pokazati čist `rename`, `0001` → `V1`, `0002` → `V2` kroz `op.execute`,
`sqlalchemy.url` iz `DATABASE_URL`, `downgrade()` diže `NotImplementedError`,
nijedan `import sqlalchemy` u kodu aplikacije.

## Redosled

Pravilo 17 i karakterizacioni testovi → C2 → **stani i javi oba diff-a** → C3.
