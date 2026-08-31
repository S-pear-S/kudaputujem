# ADR 0003: `AccommodationResolver` filtrira spajanje po destinaciji

Status: **prihvaćeno**, 31.08.2026.
Prvo svesno odstupanje ADR 0001 porta (Kotlin → Python) od vernog prevoda. Svi dosadašnji
nalazi u portu (solver, adapteri, `fetch.py`) su ili preneti doslovno uz dokumentovan
razlog (§9 u `CLAUDE.md`, "Sedam zamki iz Kotlina"), ili prijavljeni i namerno NEISPRAVLJENI
do daljeg dogovora (bug u rangiranju dece za pomoćni ležaj, `OccupancySolver`). Ovo je prvi
slučaj gde je port ISPRAVIO grešku iz Kotlin koda umesto da je prenese.

## Kontekst

Pri pisanju Python `AccommodationResolver` (ADR 0001 korak 4, "jedna prava runda od kraja
do kraja") pročitan je red po red `apps/api/src/main/kotlin/rs/kudaputujem/api/accommodation/
AccommodationResolver.kt` pre pisanja porta — isti postupak kao za sve ostale module.

`aliasHit` (deo koji prvi proverava da li je hotel već viđen) glasi:

```kotlin
private fun aliasHit(canonical: String, sourceId: Long, externalId: String?): Long? = jdbc.sql(
    """
    SELECT accommodation_id FROM accommodation_alias
    WHERE accommodation_id IS NOT NULL
      AND status = 'CONFIRMED'
      AND (normalized = :canonical OR (:externalId IS NOT NULL AND external_id = :externalId AND source_id = :sourceId))
    ORDER BY (source_id = :sourceId) DESC
    LIMIT 1
    """
)
```

Poklapanje po `normalized = :canonical` **nema filter po destinaciji.** Posledica: dva
različita hotela sa istim (kanonizovanim) imenom u dve različite destinacije — "Vila Marija"
u Sitoniji (Grčka) i "Vila Marija" u Budvi (Crna Gora) je konkretan primer korišćen u analizi
— bi dobili **isti** `accommodation_id`. Cena jednog bi se mešala sa cenom drugog na istoj
stranici ponude, bez ijedne greške, bez pada testa, bez upozorenja u logu.

`fuzzyHit`, funkcija ODMAH ISPOD `aliasHit` u istom fajlu, filter po destinaciji IMA:

```kotlin
private fun fuzzyHit(canonical: String, destinationId: Long?, stars: Double?): Long? {
    if (destinationId == null) return null   // bez destinacije ne spajamo, previse rizicno
    return jdbc.sql(
        """
        SELECT id, similarity(norm_text(name), :canonical) AS score, stars
        FROM accommodation
        WHERE destination_id = :destinationId
          AND norm_text(name) % :canonical
        ...
```

Prisustvo filtera i eksplicitnog komentara "bez destinacije ne spajamo, previše rizično" u
susednoj funkciji istog fajla je dokaz da je odsustvo filtera u `aliasHit` **previd, ne
namera** — autor je znao da destinacija mora da ograniči spajanje, i primenio je to pravilo
u `fuzzyHit`, ali ga je preskočio u `aliasHit` iznad. §8 pravilo 9 ovog projekta kaže "radije
precenimo nego da prikažemo nižu cenu od stvarne" za solver — ovaj bug ide u suprotnom
pravcu: SPAJA dva različita objekta, što znači da bi korisnik mogao da vidi cenu i uslove
jednog hotela dok rezerviše potpuno drugi. To je gori ishod od dupliranog reda.

### Zašto se ne prenosi doslovno, za razliku od svega dosadašnjeg u portu

Postojeći presedan (bug u rangiranju dece za pomoćni ležaj, `OccupancySolver`, CLAUDE.md §9)
je namerno ostavljen neispravljen jer **17 (kasnije 25) testova fiksira tačne novčane iznose
kao specifikaciju porta** — ispravka bi promenila očekivane brojeve i time obesmislila
testove kojima se dokazivalo da je port veran. `AccommodationResolver` **nema nijedan
postojeći test** (ni u Kotlinu, ni pre ove ADR) — nema specifikacije koju bi ispravka
narušila. Razlika nije u ozbiljnosti buga (spajanje dva hotela je ozbiljnije od pogrešnog
rangiranja dece u ivičnom slučaju), nego isključivo u tome da li postoji test-specifikacija
koja bi ispravkom prestala da važi.

## Odluka

`AccommodationResolver.resolve_or_create` (Python) ograničava poklapanje po imenu
(`normalized = canonical` grana) na istu destinaciju, koristeći `IS NOT DISTINCT FROM` da
NULL destinacija (nepoznata i za alias i za tekuću ponudu) i dalje broji kao poklapanje —
ne kao promašaj. Poklapanje po `external_id` (isti izvor + isti identifikator sa sajta
agencije) **ostaje bez** filtera po destinaciji, jer je već nedvosmisleno — destinacija tu
ne dodaje informaciju, samo bi bez razloga odbila legitiman povratni pogodak ako se
destinacija između dva skrepovanja promeni (npr. ispravka na sajtu agencije).

`fuzzyHit`/`_fuzzy_hit` prenet je doslovno — već je imao filter, nije trebalo ništa menjati.

### Migracija V4

Samo suženje SQL upita nije dovoljno. `uq_accommodation_alias` je bio
`(normalized, COALESCE(source_id, 0))` — jedan izvor je smeo imati samo JEDAN red po
normalizovanom imenu, bez obzira na destinaciju. Bez izmene indeksa, suženi upit bi samo
pomerio kvar sa tihog spajanja na `UniqueViolation` pri drugom upisu istog imena u drugoj
destinaciji od istog izvora. `V4__accommodation_alias_destination.sql`:

1. `accommodation_alias.destination_id BIGINT REFERENCES destination (id) ON DELETE SET NULL`
2. novi indeks: `(normalized, COALESCE(source_id, 0), COALESCE(destination_id, 0))`

Tabela je bila prazna u trenutku migracije (provereno upitom pre pisanja) — ništa se ne
dira, samo se menja šema unapred.

## Dokaz

`apps/api/tests/test_accommodation_resolver.py`:
- `test_same_name_different_destinations_creates_two_accommodations` — isto ime, dve
  destinacije (Budva/Sitonija, pravi seed podaci), dva `accommodation_id`. **Ovaj test PADA**
  na doslovnom Kotlin upitu bez `destination_id` filtera — provereno pre pisanja porta,
  privremenim skriptom van repoa koja kopira stari upit i stari `ON CONFLICT` cilj: isto ime
  u Budvi i Sitoniji je dalo `id_budva == id_sitonija` (spojeni u jedan red).
- `test_same_name_same_destination_reuses_accommodation` — isti hotel, ista destinacija, dva
  poziva daju isti `accommodation_id` (osnovna funkcija resolvera i dalje radi).

## Rizici i kako se pokrivaju

1. **Isti hotel na granici dve destinacije (npr. opština/regija) se sad NE spaja
   automatski**, iako bi ranije (pogrešno) bio spojen. Ovo je namerna posledica — ako je
   destinacija dvosmislena ili pogrešno raspoznata, bolje je da postoje dva `PENDING`-
   nalik reda (u ovom slučaju dva `accommodation` reda) nego jedan pogrešno spojen. Ručna
   provera u budućem admin panelu (§7 stavka 17) rešava ovaj slučaj.
2. **`fuzzyHit`/`_fuzzy_hit` drugi nalaz iz istog fajla NIJE ispravljen ovom odlukom** —
   poredi kanonsko ime (bez "hotel"/"vila" prefiksa) sa sirovim imenom iz baze, pa "hotel
   porto matina" prema kanonskom "porto matina" nikad ne pređe prag sličnosti i fuzzy grana
   praktično ne opali. Zabeleženo za Fazu B (CLAUDE.md §7), namerno NE popravljeno sada —
   drugačiji tip problema (fuzzy grana slabo radi) od ovog (aliasHit tiho spaja pogrešno).

## Šta bi promenilo ovu odluku

Ako se pokaže da je destinaciono ograničenje previše strogo u praksi (npr. isti hotel legitimno
menja dodeljenu destinaciju između dva skrepovanja i time gubi kontinuitet aliasa) — otvoriti
novi razgovor, ne menjati ćutke. Do tada ova odluka stoji.
