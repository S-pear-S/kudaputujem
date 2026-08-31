-- =====================================================================================
-- Kuda putujem — V4: accommodation_alias dobija destination_id
--
-- ADR 0001 korak 4, poruka 16 (31.08.2026) — PRVO SVESNO ODSTUPANJE od vernog porta
-- Kotlin -> Python (za razliku od svih dosadašnjih zamki koje su prenete doslovno, §9).
--
-- Kotlinov AccommodationResolver.aliasHit traži alias SAMO po `normalized`, bez filtera po
-- destinaciji. "Vila Marija" u Sitoniji i "Vila Marija" u Budvi bi zato postali ISTI
-- accommodation_id, i cene dva različita hotela bi se tiho spojile — ništa ne pukne. Da je
-- ovo previd, a ne namera, vidi se iz `fuzzyHit` ispod njega, koji IMA filter po destinaciji
-- i komentar "bez destinacije ne spajamo, previše rizično". Python `AccommodationResolver`
-- (apps/api/src/travelapi/accommodation/resolver.py) ispravlja ovo umesto da ga prenese —
-- vidi CLAUDE.md §13 za puno obrazloženje i docs/decisions/ za ADR.
--
-- Samo sužavanje upita u Pythonu ne bi bilo dovoljno: uq_accommodation_alias je
-- (normalized, COALESCE(source_id, 0)) — jedan izvor sme imati samo JEDAN red po
-- normalizovanom imenu, bez obzira na destinaciju. Bez izmene indeksa, sužen upit samo
-- pomera kvar sa tihog spajanja na pucanje o jedinstvenost pri drugom upisu istog imena
-- u drugoj destinaciji.
--
-- Tabela `accommodation_alias` je prazna (provereno upitom pre pisanja ove migracije,
-- 31.08.2026) — ništa se ne dira, samo se menja šema unapred.
-- =====================================================================================

ALTER TABLE accommodation_alias
    ADD COLUMN destination_id BIGINT REFERENCES destination (id) ON DELETE SET NULL;

DROP INDEX uq_accommodation_alias;

CREATE UNIQUE INDEX uq_accommodation_alias
    ON accommodation_alias (normalized, COALESCE(source_id, 0), COALESCE(destination_id, 0));
