# ADR 0002: Format na žici — `/internal/*` snake_case, `/api/*` camelCase

Status: **prihvaćeno**, 18.08.2026.
Ispravlja: tvrdnju u `docs/decisions/0001pythononly.md` §"Šta se NE menja" da format na žici
ostaje nepromenjen (camelCase) i da se `core/ingest.py` ne dira. Ta tvrdnja je bila zasnovana
na pretpostavci koja nije provera protiv stvarnog koda.

## Kontekst

ADR 0001 je napisan uz pretpostavku da postoji jedan, već ustaljen format na žici između
skrepera i API-ja, i da taj format ostaje nepromenjen kroz prelazak na Python. Ta pretpostavka
nije bila proverena protiv stvarnog koda.

Stvarno stanje, utvrđeno 18.08.2026:

- `IngestClient.send_batch` (`apps/scrapers/src/travelscrape/core/ingest.py`) šalje
  `batch.model_dump(mode="json")`. `IngestBatch` u `travelcore.models` je pydantic model sa
  poljima `run_id`, `source_slug`, `offers`, `dry_run` — bez `alias` konfiguracije. Izlaz je
  dakle doslovno **snake_case**: `run_id`, `source_slug`, `room_code`, `capacity_total`, ...
  Isto važi za `finish_run` (`summary.model_dump(mode="json")`).
- `IngestDto.kt` (`apps/api/src/main/kotlin/rs/kudaputujem/api/ingest/IngestDto.kt`) očekuje
  **camelCase** — `roomName`, `capacityTotal`, `pricingBasis`, `originalAmount`, ...
  `JacksonConfig.kt` ne postavlja nikakvu `PropertyNamingStrategy`, pa Jackson koristi Kotlin
  imena polja doslovno, camelCase.
- `IngestClient.start_run` je jedini poziv koji je ikad radio, i to slučajno: telo zahteva se
  tamo ne pravi preko pydantic modela nego ručno piše kao `{"sourceSlug": source_slug}` —
  neko je pri pisanju te jedne linije ručno pogodio Kotlin-ovo očekivano ime.

Posledica: **lanac skreper → API nikad nije prošao od kraja do kraja.** `send_batch` i
`finish_run` bi na pravom Kotlin API-ju danas pali sa poljima koja Jackson ne prepoznaje
(deserijalizacija u DTO sa `null`/podrazumevanim vrednostima umesto stvarnih podataka, ili
grešku, zavisno od `FAIL_ON_UNKNOWN_PROPERTIES`). Ovo nije primećeno ranije jer se ceo lanac
do sada testirao samo delimično (soleazur/oktopod adapteri testirani su nad fixture-ima, ne
end-to-end kroz pravi ingest — E2E provera je tek ADR 0001 korak 5).

## Odluka

Format na žici **nije jedinstven** — zavisi od zone:

| Zona | Format | Zašto |
|---|---|---|
| `/internal/*` (skreper → API) | **snake_case** | Python priča sa Pythonom. Kad Python API (ADR 0001 korak 4) preuzme `/internal/ingest`, prirodno prihvata isti oblik koji `IngestClient` već šalje. `core/ingest.py` se **ne dira**. |
| `/api/*` (API → frontend) | **camelCase** | `apps/web/lib/types.ts` je već pisan po camelCase ugovoru i to se ne menja bez razloga na frontend strani. |

Python API u koraku 4 dakle:
- prima `/internal/*` telo kao snake_case pydantic model direktno (`OfferIn` itd. iz
  `travelcore.models`, bez transformacije),
- vraća `/api/*` odgovore serijalizovane u camelCase (FastAPI/pydantic `alias_generator` ka
  camelCase + `model_config = ConfigDict(populate_by_name=True)`, ili ekvivalentan mehanizam).

### Šta se NE menja

- `apps/scrapers/src/travelscrape/core/ingest.py` — `IngestClient` ostaje netaknut, već šalje
  ispravan format za novu odluku.
- `packages/travelcore/src/travelcore/models.py` — polja ostaju snake_case (to je Python
  konvencija i to je sad i zvanično ugovoreni format za `/internal/*`).

### Šta ide u ADR 0001 korak 4 kao obavezan deo, ne opciono

**Ugovorni test.** Pravi `OfferIn` sa punim sadržajem (sva polja popunjena, ne minimalan
primer) mora proći kroz pravi `POST /internal/ingest/offers` (pravi HTTP zahtev ka pravom
FastAPI procesu, prava Postgres baza) i stići u bazu nepromenjen. Ne mock HTTP klijenta, ne
poređenje JSON šema — stvarno izvršavanje. Ovaj test bi otkrio tačno ovaj problem da je postojao
pre ADR 0001, i sprečava da se isti tip greške (pretpostavljen ugovor umesto provereno) ponovi.

## Rizici i kako se pokrivaju

1. **Dva formata u jednom procesu je izvor konfuzije.** Pokriva se time što je granica čista:
   `/internal/*` nikad ne prolazi kroz camelCase serijalizator, `/api/*` nikad ne vraća
   snake_case. Nema deljenih Pydantic modela između te dve zone koji bi zahtevali dvostruku
   `alias` konfiguraciju — `travelcore.models` (`/internal/*` ugovor) i budući `travelapi`
   response modeli (`/api/*` ugovor) su namerno odvojeni tipovi.
2. **Postojeći Kotlin `/api/search` je već camelCase** (frontend ga tako i čita) — ADR 0002 ne
   menja ponašanje `/api/*` zone, samo je imenuje eksplicitno kao odluku umesto prećutne
   pretpostavke. Rizik je nula za tu stranu.

## Šta bi promenilo ovu odluku

Ništa predviđeno — ovo je ispravka pogrešne pretpostavke, ne otvoreno pitanje. Ako se u koraku 4
otkrije da ugovorni test i dalje ne prolazi ni sa ovom odlukom, to je nov nalaz, ne razlog da se
ADR 0002 preispita bez dodatnih podataka.
