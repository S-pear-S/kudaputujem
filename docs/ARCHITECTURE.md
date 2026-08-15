# Arhitektura

## 1. Osnovna odluka: pre-crawl indeks, ne live fan-out

Skyscanner i Kayak rade live fan-out jer imaju partnerske API-je sa ugovorenim SLA. Srpske agencije
nemaju javne API-je, pa live upit ka 20 sajtova znači 20 skrepova po pretrazi: 15-60s odgovor,
trenutno banovanje IP-ja i neupotrebljiv proizvod.

Zato: **skreperi periodično pune naš indeks, pretraga čita samo naš indeks.**

Posledice koje moramo da rešimo:
- Cena može da zastari → uz svaku ponudu prikazujemo `Ažurirano pre X` i vodimo `last_seen_at`.
- Ponuda može da nestane sa sajta → `crawl_run` na kraju deaktivira sve što nije viđeno u toj rundi.
- Skreper mora da pokrije *sav* katalog izvora, ne samo ono što je korisnik tražio → crawl je po
  izvoru, ne po upitu.

Faza 2 (kad bude vredelo): live provera cene samo za ponudu koju korisnik otvori.

## 2. Tok podataka

```
                       ┌──────────────────────────────────────────┐
                       │  apps/scrapers  (Python, cron/ručno)      │
                       │                                          │
 sajt agencije ──────► │  Fetcher (httpx | Playwright)            │
                       │     ↓ raw HTML/JSON  → raw_document      │
                       │  Adapter.parse()  → RawOffer             │
                       │     ↓                                    │
                       │  Normalizatori (board, transport, sobe,  │
                       │  datumi, novac, geo)  → OfferIn (pydantic)│
                       │     ↓                                    │
                       │  IngestClient  ── HTTP batch ────────────┼──┐
                       └──────────────────────────────────────────┘  │
                                                                     ▼
                       ┌──────────────────────────────────────────────────────┐
                       │  apps/api  (Kotlin, Spring Boot)                     │
                       │                                                      │
                       │  /internal/ingest/*  upsert po (source, external_id) │
                       │        ↓                                             │
                       │  PostgreSQL: offer / departure / price_option / ...  │
                       │        ↓  (job posle svake runde)                    │
                       │  departure_price_index  (denormalizovane cene)       │
                       │        ↓                                             │
                       │  /api/search   ← Redis keš                           │
                       │  /api/offers/{id}, /api/destinations, /api/leads     │
                       └──────────────────────────────────────────────────────┘
                                                    ▲
                                                    │
                       ┌────────────────────────────┴─────────────────────────┐
                       │  apps/web  (Next.js, SSR za SEO)                     │
                       └──────────────────────────────────────────────────────┘
```

## 3. Zašto dva jezika

- Skreping u Pythonu: `httpx`, `selectolax`, `playwright`, `dateparser`, `rapidfuzz` — nema ekvivalenta
  te zrelosti na JVM-u, a skreperi su 70% posla na ovom projektu.
- API u Kotlinu: tipizovan domen, Spring ekosistem, lako se hostuje, dobra podrška za JPA/JDBC i keš.

Granica između njih je **jedan HTTP ugovor** (`/internal/ingest`), opisan OpenAPI šemom. Skreper ne zna
za bazu. To znači da se skreper može zameniti, prepisati ili pokrenuti sa druge mašine bez diranja API-ja.

## 4. Model izvora

Jedna agencija = više izvora. `travelland` može imati izvore `travelland-letovanje`,
`travelland-zimovanje`, `travelland-evropski-gradovi` — svaki sa svojim adapterom, rasporedom i
zdravstvenim statusom. Kad se sajt promeni, pada jedan izvor, ne cela agencija.

Svaki izvor ima:
- `adapter_key` → koji Python adapter ga obrađuje
- `config` (JSONB) → parametri adaptera (početni URL-ovi, sezona, jezik)
- `crawl_delay_ms`, `max_concurrency` → pristojnost
- `health_status` → `OK | DEGRADED | FAILING | DISABLED`, računato iz poslednjih N `crawl_run`

## 5. Detekcija da se sajt promenio

Najčešći uzrok tihog kvara skrepera nije greška nego prazan rezultat. Zato:
- Adapter deklariše `expected_min_items` po rundi.
- Runda koja vrati < 50% proseka poslednjih 5 rundi ne ingestuje ništa i označava se `SUSPECT`.
- Ingest sa `dry_run` uvek vraća dijagnostiku (koliko polja je bilo prazno po ponudi).

## 6. Ključni algoritam: raspored putnika po sobama

Ovo je najteži deo domena. Agencija daje cene po *rasporedu*, npr. `1/2`, `1/2+1`, `1/3`, `1/4`,
uz posebnu cenu za dete na pomoćnom ležaju po uzrastu.

Korisnik unosi npr. 4 odrasla + 1 dete (8 god), i može da traži jednu sobu ili više soba.
Rešenje je mali problem raspoređivanja (bin packing sa cenom):

- `OccupancySolver` uzima sve `price_option` redove jednog `departure`,
- gradi kandidate soba (kapacitet odraslih + pomoćni ležaji + cena po slotu),
- DP preko (preostali odrasli, preostala deca) → minimalna ukupna cena i plan soba,
- vraća `RoomPlan` koji se prikazuje korisniku (npr. `1× soba 1/3 + 1× soba 1/2`).

Pošto je to preskupo za milione redova u pretrazi, radi se u dva koraka:
1. **Filtriranje i sortiranje** ide preko `departure_price_index` — precomputed minimalna ukupna cena
   za 1..8 odraslih (bez dece). Jedan indeksiran red po (departure, pax).
2. **Tačna cena** se računa `OccupancySolver`-om samo za stranicu rezultata koja se prikazuje
   (do 50 ponuda), gde uzimamo u obzir i uzraste dece.

## 7. Normalizacija

Tri sloja modela, isto kao u Showtime projektu:

```
RawOffer      (šta je skreper pokupio, string polja, bez garancija)
   ↓ normalizatori
OfferIn       (pydantic, validirano, enumi, Decimal cene, ISO datumi)   ← ovo ide preko HTTP-a
   ↓ ingest
Offer/Departure/PriceOption   (JPA entiteti, kanonski oblik u bazi)
```

Kanonske šifre (detaljno u `DATA_MODEL.md`): usluga (`RO/BB/HB/FB/AI/UAI`), prevoz
(`BUS/PLANE/OWN/TRAIN/FERRY/MINIVAN`), valuta uvek uz iznos, sve cene se čuvaju u originalnoj valuti
plus konvertovane u RSD po dnevnom kursu NBS radi sortiranja.

## 8. Deduplikacija

Ista destinacija i isti hotel dolaze pod različitim imenima sa 15 sajtova
(`Sitonija` / `Sithonia` / `Sitonija-Halkidiki`, `Hotel Porto Matina` / `Porto Matina 3*`).

- `destination` i `accommodation` su kanonske tabele, `*_alias` tabele mapiraju sirova imena.
- Novo sirovo ime se prvo traži u alias tabeli (tačno poklapanje na normalizovanom obliku),
  pa `pg_trgm` sličnost > 0.82 uz istu destinaciju,
- ako ništa ne prođe, pravi se `pending` zapis koji čeka ručnu potvrdu u admin panelu.
  **Nikad ne spajamo automatski ispod praga** — pogrešno spojen hotel je gori bug od dupliranog.

## 9. Keširanje

- Redis keš rezultata pretrage, ključ = hash normalizovanih parametara, TTL 5 min.
- Redis keš autocomplete destinacija, TTL 1h.
- HTTP keš u skreperu (`.cache/`, po URL-u i ETag-u) da ponovno parsiranje ne znači ponovni request.

## 10. Šta je namerno ostavljeno za kasnije

Nalozi korisnika, sačuvane pretrage, price alerts, provizioni model, live provera cene,
Meilisearch, više tržišta osim Srbije. Model podataka je napravljen da ih primi bez migracije šeme
(zato postoje `market`, `currency` i `locale` kolone od početka).
