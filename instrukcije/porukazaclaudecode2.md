# Poruka za Claude Code

Kopiraj sve ispod crte u terminal.

---

Nastavi, ali sa tri dopune. Jedna je važna.

## 1. Original ne sme da ostane kao kopija

Napisao si „kopije originala". Ako `travelscrape/core/enums.py` ostane sa telom, a
`travelcore/enums.py` dobije isto to telo, napravili smo tačno onu duplikaciju zbog
koje smo izbacili Kotlin, samo sada u jednom jeziku. To je gore, jer neće pući ni build.

Original mora da **ostane bez tela**. Posle shim-a, `travelscrape/core/enums.py` sadrži
samo re-eksport i nijedan `class`, nijedan `def`, nijednu konstantu.

Provera pre nego što kreneš dalje: u `apps/scrapers/src/travelscrape/core/enums.py`,
`core/models.py` i `normalize/*.py` ne sme ostati nijedna linija logike.

## 2. Dokaži da je premeštanje verno, pa tek onda čisti

Korak 1 se deli na dva commita.

**1b — shim, testovi se ne diraju.**
Tela u `travelscrape` zameni eksplicitnim re-eksportom iz `travelcore`.
Ne `import *` — nabroj simbole, da `ruff` i `mypy --strict` ostanu čisti.
Iznad svakog shim-a komentar: `# Privremeni re-eksport. Brise se u koraku 1c.`

Pusti `pytest`. Mora biti zeleno uz **nula izmena u fajlovima testova**.
To je jedini dokaz da je premeštanje verno. Ako moraš da diraš test, nešto se
promenilo u prevodu i tražimo šta.

**1c — zaseban commit, brisanje skele.**
Prepravi importe u celom `travelscrape` (izvor **i** testovi) da idu direktno na
`travelcore.*`. Obriši shim-ove. Ponovo `pytest`.

Sad su testovi promenjeni, ali samo import linije, i već znamo iz 1b da je ponašanje
isto. Ta dva commita se ne smeju spojiti u jedan.

Pre 1b pokaži mi izlaz od:

```
diff -u apps/scrapers/src/travelscrape/core/enums.py  packages/travelcore/src/travelcore/enums.py
diff -u apps/scrapers/src/travelscrape/core/models.py packages/travelcore/src/travelcore/models.py
```

Očekujem razliku **samo** u importima i docstringovima. Ako se pojavi bilo šta drugo,
stani. U commitu premeštanja ne sme biti nijedne promene ponašanja, ni preimenovanja,
ni „usput sam popravio".

## 3. `travelcore` je čist domenski sloj

`packages/travelcore/pyproject.toml` sme da zavisi **samo** od `pydantic` i
`python-dateutil` (dodaj `rapidfuzz` samo ako ga normalizacija stvarno uvozi).

Ne sme da zavisi od `httpx`, `selectolax`, `typer`, `structlog`, `tenacity`,
`playwright`. To je pravilo, ne preferencija: API će zavisiti od `travelcore`, i ne sme
kroz njega da povuče scraping biblioteke.

Ostaje u `travelscrape`, ne seli se: `core/settings.py`, `core/adapter.py`,
`core/fetch.py`, `core/ingest.py`, `core/pipeline.py`, `core/registry.py`, `adapters/`.

Seli se u `travelcore/models.py` i `IngestBatch`, `IngestResult`, `RunSummary` —
to je format na žici, treba i API-ju.

Upiši u `CLAUDE.md` §8 kao **pravilo 16**:
`travelcore` ne sme da uvozi nijednu scraping biblioteku. Ako neki modul mora, taj
modul ne pripada `travelcore`-u.

## 4. Usput: verzije Pythona u konfiguraciji

`apps/scrapers/pyproject.toml` još kaže `requires-python = ">=3.11"`,
`ruff target-version = "py311"`, `mypy python_version = "3.11"`.

Podigni sve na `3.12`, u oba `pyproject.toml`. Upravo je nesklad između deklarisane i
stvarne verzije napravio zabunu sa 3.8. Neka konfiguracija govori istinu.

## Instalacija

```
pip install -e packages/travelcore
pip install -e apps/scrapers
```

## Kada da staneš

- Ako `diff` pokaže razliku koja nije import ili docstring
- Ako `pytest` u koraku 1b nije zelen bez diranja testova
- Ako neki modul iz `normalize/` uvozi nešto sa liste zabranjenih zavisnosti

Javi rezultat posle 1b, pre nego što kreneš na 1c.
