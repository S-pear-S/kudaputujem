# Poruka za Claude Code

Kopiraj sve ispod crte u terminal.

---

1b je prihvaćen. Diff je čist, 140 prolazi, `git diff --stat` nad testovima prazan.
To je dokaz koji je i bio cilj. Kreni na 1c.

## 1c, obim

Jedan commit. U njemu:

- svi importi u `travelscrape` (izvor **i** testovi) idu direktno na `travelcore.*`
- shim-ovi se **brišu kao fajlovi**, ne prazne:
  - `travelscrape/core/enums.py` — obriši
  - `travelscrape/core/models.py` — obriši
  - `travelscrape/normalize/` — obriši ceo direktorijum, uključujući `__init__.py`
- proveri da `travelscrape/core/__init__.py` ne re-eksportuje ništa od premeštenog

Ništa drugo u tom commitu. Bez preimenovanja, bez sređivanja onih 11 `ruff` nalaza
u `cli.py` i `core/*` — to je zaseban posao, zaseban commit, kasnije.

## Provere posle 1c

**1. Nema zaostalih referenci.**

```
grep -rn "travelscrape.core.enums\|travelscrape.core.models\|travelscrape.normalize" \
  apps/ packages/ docs/ CLAUDE.md
```

Mora vratiti prazno. Ako nešto ostane u `CLAUDE.md` ili `docs/ARCHITECTURE.md`,
ispravi i te putanje — u istom commitu, jer je to ista izmena.

**2. Diff nad testovima sadrži samo import linije.**

```
git diff -- apps/scrapers/tests
```

Pokaži mi ga. Svaka izmenjena linija mora biti `import` ili `from ... import`.
Ako se promenila bilo koja druga linija, stani.

**3. `mypy --strict` nad oba paketa, ne samo nad shim-ovima.** Sad kad skele nema,
hoću pun prolaz preko `packages/travelcore` i `apps/scrapers/src`.

**4. `pytest` zelen.** Isti brojevi: 140 prolazi, 13 preskočeno.
Ako se broj preskočenih promeni, to je signal, ne slučajnost.

## Pravilo 16 mora imati zube

Zapisali smo da `travelcore` ne sme da uvozi scraping biblioteke. Zapisano pravilo
koje niko ne proverava propada za mesec dana.

Dodaj **`import-linter`** u dev zavisnosti. Alat postoji upravo za ovo, ne piši
sopstvenu proveru. Kontrakt u `.importlinter` u root-u:

```ini
[importlinter]
root_packages = travelcore, travelscrape

[importlinter:contract:travelcore-je-cist]
name = travelcore ne sme da zavisi od scraping biblioteka
type = forbidden
source_modules = travelcore
forbidden_modules =
    httpx
    selectolax
    typer
    structlog
    tenacity
    playwright
    rich

[importlinter:contract:smer-zavisnosti]
name = travelcore ne sme da zna za travelscrape
type = forbidden
source_modules = travelcore
forbidden_modules = travelscrape
```

Pusti `lint-imports` i javi izlaz. Drugi kontrakt je važan koliko i prvi: smer
zavisnosti mora ići samo u jednom pravcu, inače nam se za mesec dana `travelcore`
vrati u scraping paket kroz sporedna vrata.

Kad API bude postojao, tu ide i treći kontrakt, `travelapi` ne sme da uvozi `travelscrape`.

## Jedno pitanje

Kojih 13 testova je preskočeno i zašto? Nabroj ih.

Preskočen test ne štiti ništa. Ako su preskočeni jer traže bazu ili mrežu, u redu je,
ali hoću da znam koji su, jer u koraku 2 dolazi Postgres i deo njih bi trebalo da
počne da se pokreće.

## Posle 1c

Stani. Ne kreći na korak 2 dok ne pregledam diff nad testovima i listu preskočenih.
