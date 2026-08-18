-- =====================================================================
-- GENERISANO IZ db/seed/geo.yaml — NE MENJATI RUČNO.
-- Regeneracija: python apps/api/scripts/gen_geo_seed.py
-- Destinacija: 323, aliasa: 541
-- =====================================================================

INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('srbija', NULL, 'COUNTRY', 'Srbija', 'Serbia', 'RS', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'srbija'), NULL, 'Srbija', 'srbija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'srbija'), NULL, 'Serbia', 'serbia', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'srbija'), NULL, 'domace destinacije', 'domace destinacije', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'srbija'), NULL, 'domaci turizam', 'domaci turizam', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('beograd', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Beograd', 'Belgrade', 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'beograd'), NULL, 'Beograd', 'beograd', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'beograd'), NULL, 'Belgrade', 'belgrade', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'beograd'), NULL, 'bg', 'bg', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('novi-sad', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Novi Sad', 'Novi Sad', 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'novi-sad'), NULL, 'Novi Sad', 'novi sad', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'novi-sad'), NULL, 'ns', 'ns', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('nis', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Niš', 'Nis', 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'nis'), NULL, 'Niš', 'nis', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'nis'), NULL, 'nis srbija', 'nis srbija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kragujevac', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Kragujevac', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kragujevac'), NULL, 'Kragujevac', 'kragujevac', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('cacak', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Čačak', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'cacak'), NULL, 'Čačak', 'cacak', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kraljevo', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Kraljevo', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kraljevo'), NULL, 'Kraljevo', 'kraljevo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('uzice', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Užice', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'uzice'), NULL, 'Užice', 'uzice', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('subotica', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Subotica', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'subotica'), NULL, 'Subotica', 'subotica', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('zrenjanin', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Zrenjanin', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zrenjanin'), NULL, 'Zrenjanin', 'zrenjanin', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sabac', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Šabac', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sabac'), NULL, 'Šabac', 'sabac', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('valjevo', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Valjevo', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'valjevo'), NULL, 'Valjevo', 'valjevo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('jagodina', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Jagodina', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'jagodina'), NULL, 'Jagodina', 'jagodina', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('leskovac', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Leskovac', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'leskovac'), NULL, 'Leskovac', 'leskovac', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('vranje', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Vranje', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'vranje'), NULL, 'Vranje', 'vranje', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('krusevac', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Kruševac', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'krusevac'), NULL, 'Kruševac', 'krusevac', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('smederevo', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Smederevo', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'smederevo'), NULL, 'Smederevo', 'smederevo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('pozarevac', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Požarevac', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'pozarevac'), NULL, 'Požarevac', 'pozarevac', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('pancevo', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Pančevo', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'pancevo'), NULL, 'Pančevo', 'pancevo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sombor', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Sombor', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sombor'), NULL, 'Sombor', 'sombor', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('loznica', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Loznica', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'loznica'), NULL, 'Loznica', 'loznica', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('novi-pazar', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Novi Pazar', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'novi-pazar'), NULL, 'Novi Pazar', 'novi pazar', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('zajecar', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Zaječar', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zajecar'), NULL, 'Zaječar', 'zajecar', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('pirot', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Pirot', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'pirot'), NULL, 'Pirot', 'pirot', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sremska-mitrovica', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Sremska Mitrovica', NULL, 'RS', TRUE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sremska-mitrovica'), NULL, 'Sremska Mitrovica', 'sremska mitrovica', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('zlatibor', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Zlatibor', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zlatibor'), NULL, 'Zlatibor', 'zlatibor', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zlatibor'), NULL, 'cajetina', 'cajetina', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kopaonik', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Kopaonik', NULL, 'RS', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kopaonik'), NULL, 'Kopaonik', 'kopaonik', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kopaonik'), NULL, 'kop', 'kop', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('tara', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Tara', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tara'), NULL, 'Tara', 'tara', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tara'), NULL, 'mitrovac', 'mitrovac', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tara'), NULL, 'kaluderske bare', 'kaluderske bare', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('divcibare', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Divčibare', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'divcibare'), NULL, 'Divčibare', 'divcibare', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('stara-planina', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Stara Planina', NULL, 'RS', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'stara-planina'), NULL, 'Stara Planina', 'stara planina', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'stara-planina'), NULL, 'babin zub', 'babin zub', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('zlatar', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Zlatar', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zlatar'), NULL, 'Zlatar', 'zlatar', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zlatar'), NULL, 'nova varos', 'nova varos', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('golija', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Golija', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'golija'), NULL, 'Golija', 'golija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('mokra-gora', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Mokra Gora', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'mokra-gora'), NULL, 'Mokra Gora', 'mokra gora', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'mokra-gora'), NULL, 'drvengrad', 'drvengrad', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'mokra-gora'), NULL, 'mecavnik', 'mecavnik', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('vrnjacka-banja', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Vrnjačka Banja', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'vrnjacka-banja'), NULL, 'Vrnjačka Banja', 'vrnjacka banja', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'vrnjacka-banja'), NULL, 'vrnjci', 'vrnjci', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sokobanja', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Sokobanja', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sokobanja'), NULL, 'Sokobanja', 'sokobanja', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sokobanja'), NULL, 'soko banja', 'soko banja', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('banja-koviljaca', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Banja Koviljača', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'banja-koviljaca'), NULL, 'Banja Koviljača', 'banja koviljaca', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('prolom-banja', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Prolom Banja', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'prolom-banja'), NULL, 'Prolom Banja', 'prolom banja', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('lukovska-banja', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Lukovska Banja', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'lukovska-banja'), NULL, 'Lukovska Banja', 'lukovska banja', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('niska-banja', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Niška Banja', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'niska-banja'), NULL, 'Niška Banja', 'niska banja', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('ribarska-banja', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Ribarska Banja', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ribarska-banja'), NULL, 'Ribarska Banja', 'ribarska banja', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('gamzigradska-banja', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Gamzigradska Banja', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'gamzigradska-banja'), NULL, 'Gamzigradska Banja', 'gamzigradska banja', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'gamzigradska-banja'), NULL, 'gamzigrad', 'gamzigrad', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('vrdnik', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Vrdnik', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'vrdnik'), NULL, 'Vrdnik', 'vrdnik', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'vrdnik'), NULL, 'banja vrdnik', 'banja vrdnik', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('palic', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Palić', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'palic'), NULL, 'Palić', 'palic', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sremski-karlovci', (SELECT id FROM destination WHERE slug = 'srbija'), 'CITY', 'Sremski Karlovci', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sremski-karlovci'), NULL, 'Sremski Karlovci', 'sremski karlovci', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('ivanjica', (SELECT id FROM destination WHERE slug = 'srbija'), 'RESORT', 'Ivanjica', NULL, 'RS', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ivanjica'), NULL, 'Ivanjica', 'ivanjica', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('crna-gora', NULL, 'COUNTRY', 'Crna Gora', 'Montenegro', 'ME', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'crna-gora'), NULL, 'Crna Gora', 'crna gora', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'crna-gora'), NULL, 'Montenegro', 'montenegro', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'crna-gora'), NULL, 'cg', 'cg', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('budva', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Budva', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'budva'), NULL, 'Budva', 'budva', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'budva'), NULL, 'budvanska rivijera', 'budvanska rivijera', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('becici', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Bečići', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'becici'), NULL, 'Bečići', 'becici', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'becici'), NULL, 'becici budva', 'becici budva', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('rafailovici', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Rafailovići', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'rafailovici'), NULL, 'Rafailovići', 'rafailovici', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('petrovac', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Petrovac', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'petrovac'), NULL, 'Petrovac', 'petrovac', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'petrovac'), NULL, 'petrovac na moru', 'petrovac na moru', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sveti-stefan', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Sveti Stefan', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sveti-stefan'), NULL, 'Sveti Stefan', 'sveti stefan', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('milocer', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Miločer', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'milocer'), NULL, 'Miločer', 'milocer', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sutomore', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Sutomore', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sutomore'), NULL, 'Sutomore', 'sutomore', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('bar', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Bar', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bar'), NULL, 'Bar', 'bar', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('canj', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Čanj', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'canj'), NULL, 'Čanj', 'canj', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('dobre-vode', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Dobre Vode', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'dobre-vode'), NULL, 'Dobre Vode', 'dobre vode', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('ulcinj', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Ulcinj', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ulcinj'), NULL, 'Ulcinj', 'ulcinj', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ulcinj'), NULL, 'velika plaza', 'velika plaza', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('herceg-novi', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Herceg Novi', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'herceg-novi'), NULL, 'Herceg Novi', 'herceg novi', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('igalo', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Igalo', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'igalo'), NULL, 'Igalo', 'igalo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('djenovici', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Đenovići', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'djenovici'), NULL, 'Đenovići', 'djenovici', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('bijela', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Bijela', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bijela'), NULL, 'Bijela', 'bijela', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('tivat', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Tivat', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tivat'), NULL, 'Tivat', 'tivat', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kotor', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Kotor', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kotor'), NULL, 'Kotor', 'kotor', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('perast', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Perast', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'perast'), NULL, 'Perast', 'perast', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('zabljak', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Žabljak', NULL, 'ME', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zabljak'), NULL, 'Žabljak', 'zabljak', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zabljak'), NULL, 'durmitor', 'durmitor', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kolasin', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'RESORT', 'Kolašin', NULL, 'ME', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kolasin'), NULL, 'Kolašin', 'kolasin', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('podgorica', (SELECT id FROM destination WHERE slug = 'crna-gora'), 'CITY', 'Podgorica', NULL, 'ME', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'podgorica'), NULL, 'Podgorica', 'podgorica', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('grcka', NULL, 'COUNTRY', 'Grčka', 'Greece', 'GR', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'grcka'), NULL, 'Grčka', 'grcka', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'grcka'), NULL, 'Greece', 'greece', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'grcka'), NULL, 'helada', 'helada', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('halkidiki', (SELECT id FROM destination WHERE slug = 'grcka'), 'REGION', 'Halkidiki', NULL, 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'halkidiki'), NULL, 'Halkidiki', 'halkidiki', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'halkidiki'), NULL, 'chalkidiki', 'chalkidiki', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'halkidiki'), NULL, 'halkidiki grcka', 'halkidiki grcka', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kasandra', (SELECT id FROM destination WHERE slug = 'halkidiki'), 'REGION', 'Kasandra', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kasandra'), NULL, 'Kasandra', 'kasandra', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kasandra'), NULL, 'kassandra', 'kassandra', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sitonija', (SELECT id FROM destination WHERE slug = 'halkidiki'), 'REGION', 'Sitonija', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sitonija'), NULL, 'Sitonija', 'sitonija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sitonija'), NULL, 'sithonia', 'sithonia', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('atos', (SELECT id FROM destination WHERE slug = 'halkidiki'), 'REGION', 'Atos', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'atos'), NULL, 'Atos', 'atos', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'atos'), NULL, 'athos', 'athos', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('hanioti', (SELECT id FROM destination WHERE slug = 'halkidiki'), 'RESORT', 'Hanioti', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'hanioti'), NULL, 'Hanioti', 'hanioti', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'hanioti'), NULL, 'chaniotis', 'chaniotis', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('pefkohori', (SELECT id FROM destination WHERE slug = 'halkidiki'), 'RESORT', 'Pefkohori', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'pefkohori'), NULL, 'Pefkohori', 'pefkohori', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'pefkohori'), NULL, 'pefkochori', 'pefkochori', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('polihrono', (SELECT id FROM destination WHERE slug = 'halkidiki'), 'RESORT', 'Polihrono', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'polihrono'), NULL, 'Polihrono', 'polihrono', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kalitea', (SELECT id FROM destination WHERE slug = 'halkidiki'), 'RESORT', 'Kalitea', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kalitea'), NULL, 'Kalitea', 'kalitea', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kalitea'), NULL, 'kallithea', 'kallithea', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('nea-kalikratija', (SELECT id FROM destination WHERE slug = 'halkidiki'), 'RESORT', 'Nea Kalikratija', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'nea-kalikratija'), NULL, 'Nea Kalikratija', 'nea kalikratija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('neos-marmaras', (SELECT id FROM destination WHERE slug = 'halkidiki'), 'RESORT', 'Neos Marmaras', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'neos-marmaras'), NULL, 'Neos Marmaras', 'neos marmaras', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sarti', (SELECT id FROM destination WHERE slug = 'halkidiki'), 'RESORT', 'Sarti', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sarti'), NULL, 'Sarti', 'sarti', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('nikiti', (SELECT id FROM destination WHERE slug = 'halkidiki'), 'RESORT', 'Nikiti', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'nikiti'), NULL, 'Nikiti', 'nikiti', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('toroni', (SELECT id FROM destination WHERE slug = 'halkidiki'), 'RESORT', 'Toroni', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'toroni'), NULL, 'Toroni', 'toroni', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('metamorfozis', (SELECT id FROM destination WHERE slug = 'halkidiki'), 'RESORT', 'Metamorfozis', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'metamorfozis'), NULL, 'Metamorfozis', 'metamorfozis', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('vurvuru', (SELECT id FROM destination WHERE slug = 'halkidiki'), 'RESORT', 'Vurvuru', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'vurvuru'), NULL, 'Vurvuru', 'vurvuru', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'vurvuru'), NULL, 'vourvourou', 'vourvourou', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('ouranopolis', (SELECT id FROM destination WHERE slug = 'halkidiki'), 'RESORT', 'Ouranopolis', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ouranopolis'), NULL, 'Ouranopolis', 'ouranopolis', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('olimpska-regija', (SELECT id FROM destination WHERE slug = 'grcka'), 'REGION', 'Olimpska regija', NULL, 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'olimpska-regija'), NULL, 'Olimpska regija', 'olimpska regija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'olimpska-regija'), NULL, 'pieria', 'pieria', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'olimpska-regija'), NULL, 'pijerija', 'pijerija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'olimpska-regija'), NULL, 'grcka olimpska regija', 'grcka olimpska regija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('paralija', (SELECT id FROM destination WHERE slug = 'olimpska-regija'), 'RESORT', 'Paralija', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'paralija'), NULL, 'Paralija', 'paralija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'paralija'), NULL, 'paralia', 'paralia', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'paralija'), NULL, 'paralija katerini', 'paralija katerini', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('nei-pori', (SELECT id FROM destination WHERE slug = 'olimpska-regija'), 'RESORT', 'Nei Pori', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'nei-pori'), NULL, 'Nei Pori', 'nei pori', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'nei-pori'), NULL, 'neoi poroi', 'neoi poroi', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('leptokarija', (SELECT id FROM destination WHERE slug = 'olimpska-regija'), 'RESORT', 'Leptokarija', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'leptokarija'), NULL, 'Leptokarija', 'leptokarija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'leptokarija'), NULL, 'leptokaria', 'leptokaria', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('platamon', (SELECT id FROM destination WHERE slug = 'olimpska-regija'), 'RESORT', 'Platamon', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'platamon'), NULL, 'Platamon', 'platamon', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'platamon'), NULL, 'platamonas', 'platamonas', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('olimpik-bic', (SELECT id FROM destination WHERE slug = 'olimpska-regija'), 'RESORT', 'Olimpik Bič', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'olimpik-bic'), NULL, 'Olimpik Bič', 'olimpik bic', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'olimpik-bic'), NULL, 'olympic beach', 'olympic beach', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('skotina', (SELECT id FROM destination WHERE slug = 'olimpska-regija'), 'RESORT', 'Skotina', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'skotina'), NULL, 'Skotina', 'skotina', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('panteleimonas', (SELECT id FROM destination WHERE slug = 'olimpska-regija'), 'RESORT', 'Panteleimonas', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'panteleimonas'), NULL, 'Panteleimonas', 'panteleimonas', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('pierija-i-solun', (SELECT id FROM destination WHERE slug = 'grcka'), 'REGION', 'Pierija i Solun', NULL, 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'pierija-i-solun'), NULL, 'Pierija i Solun', 'pierija i solun', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'pierija-i-solun'), NULL, 'solunska regija', 'solunska regija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('solun', (SELECT id FROM destination WHERE slug = 'pierija-i-solun'), 'CITY', 'Solun', 'Thessaloniki', 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'solun'), NULL, 'Solun', 'solun', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'solun'), NULL, 'Thessaloniki', 'thessaloniki', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'solun'), NULL, 'saloniki', 'saloniki', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('asprovalta', (SELECT id FROM destination WHERE slug = 'pierija-i-solun'), 'RESORT', 'Asprovalta', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'asprovalta'), NULL, 'Asprovalta', 'asprovalta', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('nea-vrasna', (SELECT id FROM destination WHERE slug = 'pierija-i-solun'), 'RESORT', 'Nea Vrasna', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'nea-vrasna'), NULL, 'Nea Vrasna', 'nea vrasna', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('stavros', (SELECT id FROM destination WHERE slug = 'pierija-i-solun'), 'RESORT', 'Stavros', NULL, 'GR', FALSE, FALSE, 60)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'stavros'), NULL, 'Stavros', 'stavros', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('tasos', (SELECT id FROM destination WHERE slug = 'grcka'), 'ISLAND', 'Tasos', 'Thassos', 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tasos'), NULL, 'Tasos', 'tasos', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tasos'), NULL, 'Thassos', 'thassos', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tasos'), NULL, 'ostrvo tasos', 'ostrvo tasos', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('krf', (SELECT id FROM destination WHERE slug = 'grcka'), 'ISLAND', 'Krf', 'Corfu', 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'krf'), NULL, 'Krf', 'krf', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'krf'), NULL, 'Corfu', 'corfu', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'krf'), NULL, 'kerkira', 'kerkira', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('zakintos', (SELECT id FROM destination WHERE slug = 'grcka'), 'ISLAND', 'Zakintos', 'Zakynthos', 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zakintos'), NULL, 'Zakintos', 'zakintos', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zakintos'), NULL, 'Zakynthos', 'zakynthos', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zakintos'), NULL, 'zante', 'zante', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('lefkada', (SELECT id FROM destination WHERE slug = 'grcka'), 'ISLAND', 'Lefkada', NULL, 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'lefkada'), NULL, 'Lefkada', 'lefkada', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'lefkada'), NULL, 'lefkas', 'lefkas', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('krit', (SELECT id FROM destination WHERE slug = 'grcka'), 'ISLAND', 'Krit', 'Crete', 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'krit'), NULL, 'Krit', 'krit', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'krit'), NULL, 'Crete', 'crete', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'krit'), NULL, 'kreta', 'kreta', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('rodos', (SELECT id FROM destination WHERE slug = 'grcka'), 'ISLAND', 'Rodos', 'Rhodes', 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'rodos'), NULL, 'Rodos', 'rodos', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'rodos'), NULL, 'Rhodes', 'rhodes', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kos', (SELECT id FROM destination WHERE slug = 'grcka'), 'ISLAND', 'Kos', NULL, 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kos'), NULL, 'Kos', 'kos', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('santorini', (SELECT id FROM destination WHERE slug = 'grcka'), 'ISLAND', 'Santorini', NULL, 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'santorini'), NULL, 'Santorini', 'santorini', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('mikonos', (SELECT id FROM destination WHERE slug = 'grcka'), 'ISLAND', 'Mikonos', NULL, 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'mikonos'), NULL, 'Mikonos', 'mikonos', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'mikonos'), NULL, 'mykonos', 'mykonos', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('skijatos', (SELECT id FROM destination WHERE slug = 'grcka'), 'ISLAND', 'Skijatos', NULL, 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'skijatos'), NULL, 'Skijatos', 'skijatos', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'skijatos'), NULL, 'skiathos', 'skiathos', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('evia', (SELECT id FROM destination WHERE slug = 'grcka'), 'ISLAND', 'Evia', NULL, 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'evia'), NULL, 'Evia', 'evia', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'evia'), NULL, 'evija', 'evija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('parga', (SELECT id FROM destination WHERE slug = 'grcka'), 'RESORT', 'Parga', NULL, 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'parga'), NULL, 'Parga', 'parga', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sivota', (SELECT id FROM destination WHERE slug = 'grcka'), 'RESORT', 'Sivota', NULL, 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sivota'), NULL, 'Sivota', 'sivota', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('preveza', (SELECT id FROM destination WHERE slug = 'grcka'), 'RESORT', 'Preveza', NULL, 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'preveza'), NULL, 'Preveza', 'preveza', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('atina', (SELECT id FROM destination WHERE slug = 'grcka'), 'CITY', 'Atina', 'Athens', 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'atina'), NULL, 'Atina', 'atina', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'atina'), NULL, 'Athens', 'athens', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('meteori', (SELECT id FROM destination WHERE slug = 'grcka'), 'CITY', 'Meteori', NULL, 'GR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'meteori'), NULL, 'Meteori', 'meteori', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'meteori'), NULL, 'meteora', 'meteora', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'meteori'), NULL, 'kalambaka', 'kalambaka', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('turska', NULL, 'COUNTRY', 'Turska', 'Turkey', 'TR', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'turska'), NULL, 'Turska', 'turska', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'turska'), NULL, 'Turkey', 'turkey', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'turska'), NULL, 'turkiye', 'turkiye', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('antalija', (SELECT id FROM destination WHERE slug = 'turska'), 'REGION', 'Antalija', 'Antalya', 'TR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'antalija'), NULL, 'Antalija', 'antalija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'antalija'), NULL, 'Antalya', 'antalya', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kemer', (SELECT id FROM destination WHERE slug = 'turska'), 'RESORT', 'Kemer', NULL, 'TR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kemer'), NULL, 'Kemer', 'kemer', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('side', (SELECT id FROM destination WHERE slug = 'turska'), 'RESORT', 'Side', NULL, 'TR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'side'), NULL, 'Side', 'side', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('alanja', (SELECT id FROM destination WHERE slug = 'turska'), 'RESORT', 'Alanja', 'Alanya', 'TR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'alanja'), NULL, 'Alanja', 'alanja', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'alanja'), NULL, 'Alanya', 'alanya', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('belek', (SELECT id FROM destination WHERE slug = 'turska'), 'RESORT', 'Belek', NULL, 'TR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'belek'), NULL, 'Belek', 'belek', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('lara', (SELECT id FROM destination WHERE slug = 'turska'), 'RESORT', 'Lara', NULL, 'TR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'lara'), NULL, 'Lara', 'lara', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kundu', (SELECT id FROM destination WHERE slug = 'turska'), 'RESORT', 'Kundu', NULL, 'TR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kundu'), NULL, 'Kundu', 'kundu', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('bodrum', (SELECT id FROM destination WHERE slug = 'turska'), 'RESORT', 'Bodrum', NULL, 'TR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bodrum'), NULL, 'Bodrum', 'bodrum', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('marmaris', (SELECT id FROM destination WHERE slug = 'turska'), 'RESORT', 'Marmaris', NULL, 'TR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'marmaris'), NULL, 'Marmaris', 'marmaris', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kusadasi', (SELECT id FROM destination WHERE slug = 'turska'), 'RESORT', 'Kušadasi', 'Kusadasi', 'TR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kusadasi'), NULL, 'Kušadasi', 'kusadasi', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('fetije', (SELECT id FROM destination WHERE slug = 'turska'), 'RESORT', 'Fetije', 'Fethiye', 'TR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'fetije'), NULL, 'Fetije', 'fetije', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'fetije'), NULL, 'Fethiye', 'fethiye', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'fetije'), NULL, 'oludeniz', 'oludeniz', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('istanbul', (SELECT id FROM destination WHERE slug = 'turska'), 'CITY', 'Istanbul', NULL, 'TR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'istanbul'), NULL, 'Istanbul', 'istanbul', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'istanbul'), NULL, 'carigrad', 'carigrad', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kapadokija', (SELECT id FROM destination WHERE slug = 'turska'), 'REGION', 'Kapadokija', NULL, 'TR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kapadokija'), NULL, 'Kapadokija', 'kapadokija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kapadokija'), NULL, 'cappadocia', 'cappadocia', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('egipat', NULL, 'COUNTRY', 'Egipat', 'Egypt', 'EG', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'egipat'), NULL, 'Egipat', 'egipat', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'egipat'), NULL, 'Egypt', 'egypt', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('hurgada', (SELECT id FROM destination WHERE slug = 'egipat'), 'RESORT', 'Hurgada', 'Hurghada', 'EG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'hurgada'), NULL, 'Hurgada', 'hurgada', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'hurgada'), NULL, 'Hurghada', 'hurghada', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sarm-el-seik', (SELECT id FROM destination WHERE slug = 'egipat'), 'RESORT', 'Šarm el Šeik', 'Sharm El Sheikh', 'EG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sarm-el-seik'), NULL, 'Šarm el Šeik', 'sarm el seik', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sarm-el-seik'), NULL, 'Sharm El Sheikh', 'sharm el sheikh', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sarm-el-seik'), NULL, 'sarm', 'sarm', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('marsa-alam', (SELECT id FROM destination WHERE slug = 'egipat'), 'RESORT', 'Marsa Alam', NULL, 'EG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'marsa-alam'), NULL, 'Marsa Alam', 'marsa alam', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sahl-hasis', (SELECT id FROM destination WHERE slug = 'egipat'), 'RESORT', 'Sahl Hašiš', NULL, 'EG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sahl-hasis'), NULL, 'Sahl Hašiš', 'sahl hasis', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sahl-hasis'), NULL, 'sahl hasheesh', 'sahl hasheesh', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('makadi-bej', (SELECT id FROM destination WHERE slug = 'egipat'), 'RESORT', 'Makadi Bej', NULL, 'EG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'makadi-bej'), NULL, 'Makadi Bej', 'makadi bej', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'makadi-bej'), NULL, 'makadi bay', 'makadi bay', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('el-guna', (SELECT id FROM destination WHERE slug = 'egipat'), 'RESORT', 'El Guna', NULL, 'EG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'el-guna'), NULL, 'El Guna', 'el guna', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kairo', (SELECT id FROM destination WHERE slug = 'egipat'), 'CITY', 'Kairo', 'Cairo', 'EG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kairo'), NULL, 'Kairo', 'kairo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kairo'), NULL, 'Cairo', 'cairo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('albanija', NULL, 'COUNTRY', 'Albanija', 'Albania', 'AL', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'albanija'), NULL, 'Albanija', 'albanija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'albanija'), NULL, 'Albania', 'albania', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('drac', (SELECT id FROM destination WHERE slug = 'albanija'), 'RESORT', 'Drač', 'Durres', 'AL', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'drac'), NULL, 'Drač', 'drac', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'drac'), NULL, 'Durres', 'durres', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('golem', (SELECT id FROM destination WHERE slug = 'albanija'), 'RESORT', 'Golem', NULL, 'AL', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'golem'), NULL, 'Golem', 'golem', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('valona', (SELECT id FROM destination WHERE slug = 'albanija'), 'RESORT', 'Valona', 'Vlore', 'AL', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'valona'), NULL, 'Valona', 'valona', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'valona'), NULL, 'Vlore', 'vlore', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'valona'), NULL, 'vlora', 'vlora', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('saranda', (SELECT id FROM destination WHERE slug = 'albanija'), 'RESORT', 'Saranda', NULL, 'AL', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'saranda'), NULL, 'Saranda', 'saranda', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'saranda'), NULL, 'sarande', 'sarande', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('ksamil', (SELECT id FROM destination WHERE slug = 'albanija'), 'RESORT', 'Ksamil', NULL, 'AL', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ksamil'), NULL, 'Ksamil', 'ksamil', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('himara', (SELECT id FROM destination WHERE slug = 'albanija'), 'RESORT', 'Himara', NULL, 'AL', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'himara'), NULL, 'Himara', 'himara', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sengjin', (SELECT id FROM destination WHERE slug = 'albanija'), 'RESORT', 'Šengjin', NULL, 'AL', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sengjin'), NULL, 'Šengjin', 'sengjin', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sengjin'), NULL, 'shengjin', 'shengjin', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('drimades', (SELECT id FROM destination WHERE slug = 'albanija'), 'RESORT', 'Drimades', NULL, 'AL', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'drimades'), NULL, 'Drimades', 'drimades', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('tirana', (SELECT id FROM destination WHERE slug = 'albanija'), 'CITY', 'Tirana', NULL, 'AL', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tirana'), NULL, 'Tirana', 'tirana', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('bugarska', NULL, 'COUNTRY', 'Bugarska', 'Bulgaria', 'BG', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bugarska'), NULL, 'Bugarska', 'bugarska', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bugarska'), NULL, 'Bulgaria', 'bulgaria', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('suncev-breg', (SELECT id FROM destination WHERE slug = 'bugarska'), 'RESORT', 'Sunčev Breg', 'Sunny Beach', 'BG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'suncev-breg'), NULL, 'Sunčev Breg', 'suncev breg', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'suncev-breg'), NULL, 'Sunny Beach', 'sunny beach', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'suncev-breg'), NULL, 'slancev brjag', 'slancev brjag', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('zlatni-pjasci', (SELECT id FROM destination WHERE slug = 'bugarska'), 'RESORT', 'Zlatni Pjasci', 'Golden Sands', 'BG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zlatni-pjasci'), NULL, 'Zlatni Pjasci', 'zlatni pjasci', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zlatni-pjasci'), NULL, 'Golden Sands', 'golden sands', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('nesebar', (SELECT id FROM destination WHERE slug = 'bugarska'), 'RESORT', 'Nesebar', NULL, 'BG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'nesebar'), NULL, 'Nesebar', 'nesebar', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sozopol', (SELECT id FROM destination WHERE slug = 'bugarska'), 'RESORT', 'Sozopol', NULL, 'BG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sozopol'), NULL, 'Sozopol', 'sozopol', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sveti-vlas', (SELECT id FROM destination WHERE slug = 'bugarska'), 'RESORT', 'Sveti Vlas', NULL, 'BG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sveti-vlas'), NULL, 'Sveti Vlas', 'sveti vlas', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('obzor', (SELECT id FROM destination WHERE slug = 'bugarska'), 'RESORT', 'Obzor', NULL, 'BG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'obzor'), NULL, 'Obzor', 'obzor', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('ravda', (SELECT id FROM destination WHERE slug = 'bugarska'), 'RESORT', 'Ravda', NULL, 'BG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ravda'), NULL, 'Ravda', 'ravda', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('primorsko', (SELECT id FROM destination WHERE slug = 'bugarska'), 'RESORT', 'Primorsko', NULL, 'BG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'primorsko'), NULL, 'Primorsko', 'primorsko', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kiten', (SELECT id FROM destination WHERE slug = 'bugarska'), 'RESORT', 'Kiten', NULL, 'BG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kiten'), NULL, 'Kiten', 'kiten', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('albena', (SELECT id FROM destination WHERE slug = 'bugarska'), 'RESORT', 'Albena', NULL, 'BG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'albena'), NULL, 'Albena', 'albena', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('varna', (SELECT id FROM destination WHERE slug = 'bugarska'), 'CITY', 'Varna', NULL, 'BG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'varna'), NULL, 'Varna', 'varna', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('burgas', (SELECT id FROM destination WHERE slug = 'bugarska'), 'CITY', 'Burgas', NULL, 'BG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'burgas'), NULL, 'Burgas', 'burgas', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('bansko', (SELECT id FROM destination WHERE slug = 'bugarska'), 'RESORT', 'Bansko', NULL, 'BG', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bansko'), NULL, 'Bansko', 'bansko', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('borovec', (SELECT id FROM destination WHERE slug = 'bugarska'), 'RESORT', 'Borovec', 'Borovets', 'BG', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'borovec'), NULL, 'Borovec', 'borovec', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'borovec'), NULL, 'Borovets', 'borovets', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('pamporovo', (SELECT id FROM destination WHERE slug = 'bugarska'), 'RESORT', 'Pamporovo', NULL, 'BG', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'pamporovo'), NULL, 'Pamporovo', 'pamporovo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sofija', (SELECT id FROM destination WHERE slug = 'bugarska'), 'CITY', 'Sofija', 'Sofia', 'BG', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sofija'), NULL, 'Sofija', 'sofija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sofija'), NULL, 'Sofia', 'sofia', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('hrvatska', NULL, 'COUNTRY', 'Hrvatska', 'Croatia', 'HR', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'hrvatska'), NULL, 'Hrvatska', 'hrvatska', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'hrvatska'), NULL, 'Croatia', 'croatia', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('makarska', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'RESORT', 'Makarska', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'makarska'), NULL, 'Makarska', 'makarska', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'makarska'), NULL, 'makarska rivijera', 'makarska rivijera', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('split', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'CITY', 'Split', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'split'), NULL, 'Split', 'split', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('dubrovnik', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'CITY', 'Dubrovnik', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'dubrovnik'), NULL, 'Dubrovnik', 'dubrovnik', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('zadar', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'CITY', 'Zadar', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zadar'), NULL, 'Zadar', 'zadar', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sibenik', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'CITY', 'Šibenik', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sibenik'), NULL, 'Šibenik', 'sibenik', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('vodice', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'RESORT', 'Vodice', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'vodice'), NULL, 'Vodice', 'vodice', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('porec', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'RESORT', 'Poreč', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'porec'), NULL, 'Poreč', 'porec', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('rovinj', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'RESORT', 'Rovinj', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'rovinj'), NULL, 'Rovinj', 'rovinj', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('pula', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'CITY', 'Pula', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'pula'), NULL, 'Pula', 'pula', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('umag', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'RESORT', 'Umag', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'umag'), NULL, 'Umag', 'umag', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('opatija', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'RESORT', 'Opatija', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'opatija'), NULL, 'Opatija', 'opatija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('crikvenica', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'RESORT', 'Crikvenica', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'crikvenica'), NULL, 'Crikvenica', 'crikvenica', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('hvar', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'ISLAND', 'Hvar', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'hvar'), NULL, 'Hvar', 'hvar', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('brac', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'ISLAND', 'Brač', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'brac'), NULL, 'Brač', 'brac', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'brac'), NULL, 'bol', 'bol', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('krk', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'ISLAND', 'Krk', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'krk'), NULL, 'Krk', 'krk', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('zagreb', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'CITY', 'Zagreb', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zagreb'), NULL, 'Zagreb', 'zagreb', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('plitvice', (SELECT id FROM destination WHERE slug = 'hrvatska'), 'RESORT', 'Plitvice', NULL, 'HR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'plitvice'), NULL, 'Plitvice', 'plitvice', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'plitvice'), NULL, 'plitvicka jezera', 'plitvicka jezera', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('italija', NULL, 'COUNTRY', 'Italija', 'Italy', 'IT', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'italija'), NULL, 'Italija', 'italija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'italija'), NULL, 'Italy', 'italy', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('rimini', (SELECT id FROM destination WHERE slug = 'italija'), 'RESORT', 'Rimini', NULL, 'IT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'rimini'), NULL, 'Rimini', 'rimini', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('riccone', (SELECT id FROM destination WHERE slug = 'italija'), 'RESORT', 'Riččone', NULL, 'IT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'riccone'), NULL, 'Riččone', 'riccone', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'riccone'), NULL, 'riccione', 'riccione', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('lido-di-jezolo', (SELECT id FROM destination WHERE slug = 'italija'), 'RESORT', 'Lido di Jezolo', NULL, 'IT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'lido-di-jezolo'), NULL, 'Lido di Jezolo', 'lido di jezolo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'lido-di-jezolo'), NULL, 'lido di jesolo', 'lido di jesolo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'lido-di-jezolo'), NULL, 'jesolo', 'jesolo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kalabrija', (SELECT id FROM destination WHERE slug = 'italija'), 'REGION', 'Kalabrija', NULL, 'IT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kalabrija'), NULL, 'Kalabrija', 'kalabrija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kalabrija'), NULL, 'calabria', 'calabria', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sicilija', (SELECT id FROM destination WHERE slug = 'italija'), 'ISLAND', 'Sicilija', NULL, 'IT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sicilija'), NULL, 'Sicilija', 'sicilija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sicilija'), NULL, 'sicily', 'sicily', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sardinija', (SELECT id FROM destination WHERE slug = 'italija'), 'ISLAND', 'Sardinija', NULL, 'IT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sardinija'), NULL, 'Sardinija', 'sardinija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sardinija'), NULL, 'sardinia', 'sardinia', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('rim', (SELECT id FROM destination WHERE slug = 'italija'), 'CITY', 'Rim', 'Rome', 'IT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'rim'), NULL, 'Rim', 'rim', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'rim'), NULL, 'Rome', 'rome', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'rim'), NULL, 'roma', 'roma', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('milano', (SELECT id FROM destination WHERE slug = 'italija'), 'CITY', 'Milano', NULL, 'IT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'milano'), NULL, 'Milano', 'milano', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('venecija', (SELECT id FROM destination WHERE slug = 'italija'), 'CITY', 'Venecija', 'Venice', 'IT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'venecija'), NULL, 'Venecija', 'venecija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'venecija'), NULL, 'Venice', 'venice', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'venecija'), NULL, 'venezia', 'venezia', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('firenca', (SELECT id FROM destination WHERE slug = 'italija'), 'CITY', 'Firenca', 'Florence', 'IT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'firenca'), NULL, 'Firenca', 'firenca', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'firenca'), NULL, 'Florence', 'florence', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'firenca'), NULL, 'firenze', 'firenze', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('napulj', (SELECT id FROM destination WHERE slug = 'italija'), 'CITY', 'Napulj', 'Naples', 'IT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'napulj'), NULL, 'Napulj', 'napulj', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'napulj'), NULL, 'Naples', 'naples', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'napulj'), NULL, 'napoli', 'napoli', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('toskana', (SELECT id FROM destination WHERE slug = 'italija'), 'REGION', 'Toskana', NULL, 'IT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'toskana'), NULL, 'Toskana', 'toskana', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'toskana'), NULL, 'tuscany', 'tuscany', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('livinjo', (SELECT id FROM destination WHERE slug = 'italija'), 'RESORT', 'Livinjo', NULL, 'IT', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'livinjo'), NULL, 'Livinjo', 'livinjo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'livinjo'), NULL, 'livigno', 'livigno', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('bormio', (SELECT id FROM destination WHERE slug = 'italija'), 'RESORT', 'Bormio', NULL, 'IT', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bormio'), NULL, 'Bormio', 'bormio', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('val-di-fasa', (SELECT id FROM destination WHERE slug = 'italija'), 'RESORT', 'Val di Fasa', NULL, 'IT', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'val-di-fasa'), NULL, 'Val di Fasa', 'val di fasa', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'val-di-fasa'), NULL, 'val di fassa', 'val di fassa', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kronplac', (SELECT id FROM destination WHERE slug = 'italija'), 'RESORT', 'Kronplac', NULL, 'IT', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kronplac'), NULL, 'Kronplac', 'kronplac', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kronplac'), NULL, 'kronplatz', 'kronplatz', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kronplac'), NULL, 'plan de corones', 'plan de corones', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('madona-di-kampiljo', (SELECT id FROM destination WHERE slug = 'italija'), 'RESORT', 'Madona di Kampiljo', NULL, 'IT', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'madona-di-kampiljo'), NULL, 'Madona di Kampiljo', 'madona di kampiljo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'madona-di-kampiljo'), NULL, 'madonna di campiglio', 'madonna di campiglio', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('selva', (SELECT id FROM destination WHERE slug = 'italija'), 'RESORT', 'Selva', NULL, 'IT', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'selva'), NULL, 'Selva', 'selva', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'selva'), NULL, 'val gardena', 'val gardena', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('spanija', NULL, 'COUNTRY', 'Španija', 'Spain', 'ES', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'spanija'), NULL, 'Španija', 'spanija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'spanija'), NULL, 'Spain', 'spain', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'spanija'), NULL, 'espana', 'espana', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kosta-brava', (SELECT id FROM destination WHERE slug = 'spanija'), 'REGION', 'Kosta Brava', NULL, 'ES', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kosta-brava'), NULL, 'Kosta Brava', 'kosta brava', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kosta-brava'), NULL, 'costa brava', 'costa brava', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kosta-del-sol', (SELECT id FROM destination WHERE slug = 'spanija'), 'REGION', 'Kosta del Sol', NULL, 'ES', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kosta-del-sol'), NULL, 'Kosta del Sol', 'kosta del sol', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kosta-del-sol'), NULL, 'costa del sol', 'costa del sol', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kosta-dorada', (SELECT id FROM destination WHERE slug = 'spanija'), 'REGION', 'Kosta Dorada', NULL, 'ES', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kosta-dorada'), NULL, 'Kosta Dorada', 'kosta dorada', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kosta-dorada'), NULL, 'costa dorada', 'costa dorada', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('malorka', (SELECT id FROM destination WHERE slug = 'spanija'), 'ISLAND', 'Malorka', 'Mallorca', 'ES', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'malorka'), NULL, 'Malorka', 'malorka', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'malorka'), NULL, 'Mallorca', 'mallorca', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'malorka'), NULL, 'majorka', 'majorka', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('ibica', (SELECT id FROM destination WHERE slug = 'spanija'), 'ISLAND', 'Ibica', 'Ibiza', 'ES', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ibica'), NULL, 'Ibica', 'ibica', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ibica'), NULL, 'Ibiza', 'ibiza', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('tenerife', (SELECT id FROM destination WHERE slug = 'spanija'), 'ISLAND', 'Tenerife', NULL, 'ES', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tenerife'), NULL, 'Tenerife', 'tenerife', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('gran-kanarija', (SELECT id FROM destination WHERE slug = 'spanija'), 'ISLAND', 'Gran Kanarija', NULL, 'ES', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'gran-kanarija'), NULL, 'Gran Kanarija', 'gran kanarija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'gran-kanarija'), NULL, 'gran canaria', 'gran canaria', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('barselona', (SELECT id FROM destination WHERE slug = 'spanija'), 'CITY', 'Barselona', 'Barcelona', 'ES', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'barselona'), NULL, 'Barselona', 'barselona', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'barselona'), NULL, 'Barcelona', 'barcelona', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('madrid', (SELECT id FROM destination WHERE slug = 'spanija'), 'CITY', 'Madrid', NULL, 'ES', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'madrid'), NULL, 'Madrid', 'madrid', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sevilja', (SELECT id FROM destination WHERE slug = 'spanija'), 'CITY', 'Sevilja', NULL, 'ES', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sevilja'), NULL, 'Sevilja', 'sevilja', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sevilja'), NULL, 'sevilla', 'sevilla', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sevilja'), NULL, 'seville', 'seville', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('valensija', (SELECT id FROM destination WHERE slug = 'spanija'), 'CITY', 'Valensija', NULL, 'ES', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'valensija'), NULL, 'Valensija', 'valensija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'valensija'), NULL, 'valencia', 'valencia', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('austrija', NULL, 'COUNTRY', 'Austrija', 'Austria', 'AT', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'austrija'), NULL, 'Austrija', 'austrija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'austrija'), NULL, 'Austria', 'austria', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('bec', (SELECT id FROM destination WHERE slug = 'austrija'), 'CITY', 'Beč', 'Vienna', 'AT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bec'), NULL, 'Beč', 'bec', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bec'), NULL, 'Vienna', 'vienna', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bec'), NULL, 'wien', 'wien', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('salcburg', (SELECT id FROM destination WHERE slug = 'austrija'), 'CITY', 'Salcburg', NULL, 'AT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'salcburg'), NULL, 'Salcburg', 'salcburg', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'salcburg'), NULL, 'salzburg', 'salzburg', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('zel-am-zee', (SELECT id FROM destination WHERE slug = 'austrija'), 'RESORT', 'Zel am Zee', NULL, 'AT', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zel-am-zee'), NULL, 'Zel am Zee', 'zel am zee', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zel-am-zee'), NULL, 'zell am see', 'zell am see', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kaprun', (SELECT id FROM destination WHERE slug = 'austrija'), 'RESORT', 'Kaprun', NULL, 'AT', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kaprun'), NULL, 'Kaprun', 'kaprun', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sladming', (SELECT id FROM destination WHERE slug = 'austrija'), 'RESORT', 'Šladming', NULL, 'AT', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sladming'), NULL, 'Šladming', 'sladming', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sladming'), NULL, 'schladming', 'schladming', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('bad-gastajn', (SELECT id FROM destination WHERE slug = 'austrija'), 'RESORT', 'Bad Gaštajn', NULL, 'AT', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bad-gastajn'), NULL, 'Bad Gaštajn', 'bad gastajn', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bad-gastajn'), NULL, 'bad gastein', 'bad gastein', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('nasfeld', (SELECT id FROM destination WHERE slug = 'austrija'), 'RESORT', 'Nasfeld', NULL, 'AT', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'nasfeld'), NULL, 'Nasfeld', 'nasfeld', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('zilertal', (SELECT id FROM destination WHERE slug = 'austrija'), 'RESORT', 'Zilertal', NULL, 'AT', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zilertal'), NULL, 'Zilertal', 'zilertal', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zilertal'), NULL, 'zillertal', 'zillertal', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zilertal'), NULL, 'majrhofen', 'majrhofen', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zilertal'), NULL, 'mayrhofen', 'mayrhofen', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('zauhenze', (SELECT id FROM destination WHERE slug = 'austrija'), 'RESORT', 'Zauhenze', NULL, 'AT', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zauhenze'), NULL, 'Zauhenze', 'zauhenze', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zauhenze'), NULL, 'zauchensee', 'zauchensee', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('bosna-i-hercegovina', NULL, 'COUNTRY', 'Bosna i Hercegovina', 'Bosnia and Herzegovina', 'BA', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bosna-i-hercegovina'), NULL, 'Bosna i Hercegovina', 'bosna i hercegovina', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bosna-i-hercegovina'), NULL, 'Bosnia and Herzegovina', 'bosnia and herzegovina', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bosna-i-hercegovina'), NULL, 'bih', 'bih', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bosna-i-hercegovina'), NULL, 'bosna', 'bosna', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('jahorina', (SELECT id FROM destination WHERE slug = 'bosna-i-hercegovina'), 'RESORT', 'Jahorina', NULL, 'BA', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'jahorina'), NULL, 'Jahorina', 'jahorina', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('bjelasnica', (SELECT id FROM destination WHERE slug = 'bosna-i-hercegovina'), 'RESORT', 'Bjelašnica', NULL, 'BA', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bjelasnica'), NULL, 'Bjelašnica', 'bjelasnica', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kupres', (SELECT id FROM destination WHERE slug = 'bosna-i-hercegovina'), 'RESORT', 'Kupres', NULL, 'BA', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kupres'), NULL, 'Kupres', 'kupres', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('vlasic', (SELECT id FROM destination WHERE slug = 'bosna-i-hercegovina'), 'RESORT', 'Vlašić', NULL, 'BA', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'vlasic'), NULL, 'Vlašić', 'vlasic', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sarajevo', (SELECT id FROM destination WHERE slug = 'bosna-i-hercegovina'), 'CITY', 'Sarajevo', NULL, 'BA', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sarajevo'), NULL, 'Sarajevo', 'sarajevo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('mostar', (SELECT id FROM destination WHERE slug = 'bosna-i-hercegovina'), 'CITY', 'Mostar', NULL, 'BA', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'mostar'), NULL, 'Mostar', 'mostar', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('neum', (SELECT id FROM destination WHERE slug = 'bosna-i-hercegovina'), 'RESORT', 'Neum', NULL, 'BA', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'neum'), NULL, 'Neum', 'neum', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('banja-luka', (SELECT id FROM destination WHERE slug = 'bosna-i-hercegovina'), 'CITY', 'Banja Luka', NULL, 'BA', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'banja-luka'), NULL, 'Banja Luka', 'banja luka', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('trebinje', (SELECT id FROM destination WHERE slug = 'bosna-i-hercegovina'), 'CITY', 'Trebinje', NULL, 'BA', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'trebinje'), NULL, 'Trebinje', 'trebinje', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('visegrad', (SELECT id FROM destination WHERE slug = 'bosna-i-hercegovina'), 'CITY', 'Višegrad', NULL, 'BA', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'visegrad'), NULL, 'Višegrad', 'visegrad', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'visegrad'), NULL, 'andricgrad', 'andricgrad', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('severna-makedonija', NULL, 'COUNTRY', 'Severna Makedonija', 'North Macedonia', 'MK', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'severna-makedonija'), NULL, 'Severna Makedonija', 'severna makedonija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'severna-makedonija'), NULL, 'North Macedonia', 'north macedonia', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'severna-makedonija'), NULL, 'makedonija', 'makedonija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('ohrid', (SELECT id FROM destination WHERE slug = 'severna-makedonija'), 'RESORT', 'Ohrid', NULL, 'MK', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ohrid'), NULL, 'Ohrid', 'ohrid', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('struga', (SELECT id FROM destination WHERE slug = 'severna-makedonija'), 'RESORT', 'Struga', NULL, 'MK', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'struga'), NULL, 'Struga', 'struga', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('dojran', (SELECT id FROM destination WHERE slug = 'severna-makedonija'), 'RESORT', 'Dojran', NULL, 'MK', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'dojran'), NULL, 'Dojran', 'dojran', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('skoplje', (SELECT id FROM destination WHERE slug = 'severna-makedonija'), 'CITY', 'Skoplje', 'Skopje', 'MK', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'skoplje'), NULL, 'Skoplje', 'skoplje', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'skoplje'), NULL, 'Skopje', 'skopje', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('mavrovo', (SELECT id FROM destination WHERE slug = 'severna-makedonija'), 'RESORT', 'Mavrovo', NULL, 'MK', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'mavrovo'), NULL, 'Mavrovo', 'mavrovo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('popova-sapka', (SELECT id FROM destination WHERE slug = 'severna-makedonija'), 'RESORT', 'Popova Šapka', NULL, 'MK', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'popova-sapka'), NULL, 'Popova Šapka', 'popova sapka', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('slovenija', NULL, 'COUNTRY', 'Slovenija', 'Slovenia', 'SI', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'slovenija'), NULL, 'Slovenija', 'slovenija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'slovenija'), NULL, 'Slovenia', 'slovenia', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('ljubljana', (SELECT id FROM destination WHERE slug = 'slovenija'), 'CITY', 'Ljubljana', NULL, 'SI', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ljubljana'), NULL, 'Ljubljana', 'ljubljana', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('bled', (SELECT id FROM destination WHERE slug = 'slovenija'), 'RESORT', 'Bled', NULL, 'SI', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bled'), NULL, 'Bled', 'bled', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('bohinj', (SELECT id FROM destination WHERE slug = 'slovenija'), 'RESORT', 'Bohinj', NULL, 'SI', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bohinj'), NULL, 'Bohinj', 'bohinj', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kranjska-gora', (SELECT id FROM destination WHERE slug = 'slovenija'), 'RESORT', 'Kranjska Gora', NULL, 'SI', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kranjska-gora'), NULL, 'Kranjska Gora', 'kranjska gora', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('portoroz', (SELECT id FROM destination WHERE slug = 'slovenija'), 'RESORT', 'Portorož', NULL, 'SI', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'portoroz'), NULL, 'Portorož', 'portoroz', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('rogaska-slatina', (SELECT id FROM destination WHERE slug = 'slovenija'), 'RESORT', 'Rogaška Slatina', NULL, 'SI', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'rogaska-slatina'), NULL, 'Rogaška Slatina', 'rogaska slatina', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('madjarska', NULL, 'COUNTRY', 'Mađarska', 'Hungary', 'HU', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'madjarska'), NULL, 'Mađarska', 'madjarska', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'madjarska'), NULL, 'Hungary', 'hungary', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'madjarska'), NULL, 'madarska', 'madarska', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('budimpesta', (SELECT id FROM destination WHERE slug = 'madjarska'), 'CITY', 'Budimpešta', 'Budapest', 'HU', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'budimpesta'), NULL, 'Budimpešta', 'budimpesta', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'budimpesta'), NULL, 'Budapest', 'budapest', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('segedin', (SELECT id FROM destination WHERE slug = 'madjarska'), 'CITY', 'Segedin', NULL, 'HU', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'segedin'), NULL, 'Segedin', 'segedin', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'segedin'), NULL, 'szeged', 'szeged', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('hajduszoboslo', (SELECT id FROM destination WHERE slug = 'madjarska'), 'RESORT', 'Hajduszoboslo', NULL, 'HU', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'hajduszoboslo'), NULL, 'Hajduszoboslo', 'hajduszoboslo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'hajduszoboslo'), NULL, 'hajduszoboszlo', 'hajduszoboszlo', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('mora-halom', (SELECT id FROM destination WHERE slug = 'madjarska'), 'RESORT', 'Mora Halom', NULL, 'HU', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'mora-halom'), NULL, 'Mora Halom', 'mora halom', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'mora-halom'), NULL, 'morahalom', 'morahalom', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('ceska', NULL, 'COUNTRY', 'Češka', 'Czechia', 'CZ', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ceska'), NULL, 'Češka', 'ceska', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ceska'), NULL, 'Czechia', 'czechia', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ceska'), NULL, 'czech republic', 'czech republic', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('prag', (SELECT id FROM destination WHERE slug = 'ceska'), 'CITY', 'Prag', 'Prague', 'CZ', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'prag'), NULL, 'Prag', 'prag', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'prag'), NULL, 'Prague', 'prague', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'prag'), NULL, 'praha', 'praha', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('karlove-vari', (SELECT id FROM destination WHERE slug = 'ceska'), 'CITY', 'Karlove Vari', NULL, 'CZ', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'karlove-vari'), NULL, 'Karlove Vari', 'karlove vari', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'karlove-vari'), NULL, 'karlovy vary', 'karlovy vary', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('francuska', NULL, 'COUNTRY', 'Francuska', 'France', 'FR', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'francuska'), NULL, 'Francuska', 'francuska', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'francuska'), NULL, 'France', 'france', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('pariz', (SELECT id FROM destination WHERE slug = 'francuska'), 'CITY', 'Pariz', 'Paris', 'FR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'pariz'), NULL, 'Pariz', 'pariz', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'pariz'), NULL, 'Paris', 'paris', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('nica', (SELECT id FROM destination WHERE slug = 'francuska'), 'CITY', 'Nica', 'Nice', 'FR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'nica'), NULL, 'Nica', 'nica', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'nica'), NULL, 'Nice', 'nice', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('lazurna-obala', (SELECT id FROM destination WHERE slug = 'francuska'), 'REGION', 'Lazurna obala', NULL, 'FR', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'lazurna-obala'), NULL, 'Lazurna obala', 'lazurna obala', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'lazurna-obala'), NULL, 'cote d azur', 'cote d azur', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('val-torans', (SELECT id FROM destination WHERE slug = 'francuska'), 'RESORT', 'Val Torans', NULL, 'FR', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'val-torans'), NULL, 'Val Torans', 'val torans', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'val-torans'), NULL, 'val thorens', 'val thorens', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('tinj', (SELECT id FROM destination WHERE slug = 'francuska'), 'RESORT', 'Tinj', NULL, 'FR', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tinj'), NULL, 'Tinj', 'tinj', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tinj'), NULL, 'tignes', 'tignes', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('nemacka', NULL, 'COUNTRY', 'Nemačka', 'Germany', 'DE', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'nemacka'), NULL, 'Nemačka', 'nemacka', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'nemacka'), NULL, 'Germany', 'germany', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('berlin', (SELECT id FROM destination WHERE slug = 'nemacka'), 'CITY', 'Berlin', NULL, 'DE', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'berlin'), NULL, 'Berlin', 'berlin', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('minhen', (SELECT id FROM destination WHERE slug = 'nemacka'), 'CITY', 'Minhen', 'Munich', 'DE', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'minhen'), NULL, 'Minhen', 'minhen', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'minhen'), NULL, 'Munich', 'munich', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'minhen'), NULL, 'munchen', 'munchen', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('hamburg', (SELECT id FROM destination WHERE slug = 'nemacka'), 'CITY', 'Hamburg', NULL, 'DE', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'hamburg'), NULL, 'Hamburg', 'hamburg', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('frankfurt', (SELECT id FROM destination WHERE slug = 'nemacka'), 'CITY', 'Frankfurt', NULL, 'DE', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'frankfurt'), NULL, 'Frankfurt', 'frankfurt', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('portugalija', NULL, 'COUNTRY', 'Portugalija', 'Portugal', 'PT', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'portugalija'), NULL, 'Portugalija', 'portugalija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'portugalija'), NULL, 'Portugal', 'portugal', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('lisabon', (SELECT id FROM destination WHERE slug = 'portugalija'), 'CITY', 'Lisabon', 'Lisbon', 'PT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'lisabon'), NULL, 'Lisabon', 'lisabon', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'lisabon'), NULL, 'Lisbon', 'lisbon', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'lisabon'), NULL, 'lisboa', 'lisboa', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('porto', (SELECT id FROM destination WHERE slug = 'portugalija'), 'CITY', 'Porto', NULL, 'PT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'porto'), NULL, 'Porto', 'porto', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('algarve', (SELECT id FROM destination WHERE slug = 'portugalija'), 'REGION', 'Algarve', NULL, 'PT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'algarve'), NULL, 'Algarve', 'algarve', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('madeira', (SELECT id FROM destination WHERE slug = 'portugalija'), 'ISLAND', 'Madeira', NULL, 'PT', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'madeira'), NULL, 'Madeira', 'madeira', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('holandija', NULL, 'COUNTRY', 'Holandija', 'Netherlands', 'NL', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'holandija'), NULL, 'Holandija', 'holandija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'holandija'), NULL, 'Netherlands', 'netherlands', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'holandija'), NULL, 'nizozemska', 'nizozemska', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('amsterdam', (SELECT id FROM destination WHERE slug = 'holandija'), 'CITY', 'Amsterdam', NULL, 'NL', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'amsterdam'), NULL, 'Amsterdam', 'amsterdam', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('velika-britanija', NULL, 'COUNTRY', 'Velika Britanija', 'United Kingdom', 'GB', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'velika-britanija'), NULL, 'Velika Britanija', 'velika britanija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'velika-britanija'), NULL, 'United Kingdom', 'united kingdom', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'velika-britanija'), NULL, 'uk', 'uk', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'velika-britanija'), NULL, 'engleska', 'engleska', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('london', (SELECT id FROM destination WHERE slug = 'velika-britanija'), 'CITY', 'London', NULL, 'GB', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'london'), NULL, 'London', 'london', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('edinburg', (SELECT id FROM destination WHERE slug = 'velika-britanija'), 'CITY', 'Edinburg', NULL, 'GB', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'edinburg'), NULL, 'Edinburg', 'edinburg', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'edinburg'), NULL, 'edinburgh', 'edinburgh', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('poljska', NULL, 'COUNTRY', 'Poljska', 'Poland', 'PL', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'poljska'), NULL, 'Poljska', 'poljska', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'poljska'), NULL, 'Poland', 'poland', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('krakov', (SELECT id FROM destination WHERE slug = 'poljska'), 'CITY', 'Krakov', 'Krakow', 'PL', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'krakov'), NULL, 'Krakov', 'krakov', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'krakov'), NULL, 'Krakow', 'krakow', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'krakov'), NULL, 'krakuv', 'krakuv', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('varsava', (SELECT id FROM destination WHERE slug = 'poljska'), 'CITY', 'Varšava', NULL, 'PL', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'varsava'), NULL, 'Varšava', 'varsava', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'varsava'), NULL, 'warsaw', 'warsaw', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('zakopane', (SELECT id FROM destination WHERE slug = 'poljska'), 'RESORT', 'Zakopane', NULL, 'PL', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zakopane'), NULL, 'Zakopane', 'zakopane', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('rumunija', NULL, 'COUNTRY', 'Rumunija', 'Romania', 'RO', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'rumunija'), NULL, 'Rumunija', 'rumunija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'rumunija'), NULL, 'Romania', 'romania', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('bukurest', (SELECT id FROM destination WHERE slug = 'rumunija'), 'CITY', 'Bukurešt', 'Bucharest', 'RO', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bukurest'), NULL, 'Bukurešt', 'bukurest', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bukurest'), NULL, 'Bucharest', 'bucharest', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('temisvar', (SELECT id FROM destination WHERE slug = 'rumunija'), 'CITY', 'Temišvar', NULL, 'RO', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'temisvar'), NULL, 'Temišvar', 'temisvar', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'temisvar'), NULL, 'timisoara', 'timisoara', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('brasov', (SELECT id FROM destination WHERE slug = 'rumunija'), 'CITY', 'Brašov', NULL, 'RO', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'brasov'), NULL, 'Brašov', 'brasov', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('ujedinjeni-arapski-emirati', NULL, 'COUNTRY', 'Ujedinjeni Arapski Emirati', 'United Arab Emirates', 'AE', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ujedinjeni-arapski-emirati'), NULL, 'Ujedinjeni Arapski Emirati', 'ujedinjeni arapski emirati', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ujedinjeni-arapski-emirati'), NULL, 'United Arab Emirates', 'united arab emirates', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ujedinjeni-arapski-emirati'), NULL, 'uae', 'uae', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ujedinjeni-arapski-emirati'), NULL, 'emirati', 'emirati', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('dubai', (SELECT id FROM destination WHERE slug = 'ujedinjeni-arapski-emirati'), 'CITY', 'Dubai', NULL, 'AE', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'dubai'), NULL, 'Dubai', 'dubai', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'dubai'), NULL, 'dubaj', 'dubaj', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('abu-dabi', (SELECT id FROM destination WHERE slug = 'ujedinjeni-arapski-emirati'), 'CITY', 'Abu Dabi', NULL, 'AE', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'abu-dabi'), NULL, 'Abu Dabi', 'abu dabi', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'abu-dabi'), NULL, 'abu dhabi', 'abu dhabi', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('ras-el-hajma', (SELECT id FROM destination WHERE slug = 'ujedinjeni-arapski-emirati'), 'RESORT', 'Ras el Hajma', NULL, 'AE', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ras-el-hajma'), NULL, 'Ras el Hajma', 'ras el hajma', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ras-el-hajma'), NULL, 'ras al khaimah', 'ras al khaimah', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('tajland', NULL, 'COUNTRY', 'Tajland', 'Thailand', 'TH', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tajland'), NULL, 'Tajland', 'tajland', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tajland'), NULL, 'Thailand', 'thailand', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('bangkok', (SELECT id FROM destination WHERE slug = 'tajland'), 'CITY', 'Bangkok', NULL, 'TH', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bangkok'), NULL, 'Bangkok', 'bangkok', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('puket', (SELECT id FROM destination WHERE slug = 'tajland'), 'ISLAND', 'Puket', 'Phuket', 'TH', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'puket'), NULL, 'Puket', 'puket', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'puket'), NULL, 'Phuket', 'phuket', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('krabi', (SELECT id FROM destination WHERE slug = 'tajland'), 'RESORT', 'Krabi', NULL, 'TH', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'krabi'), NULL, 'Krabi', 'krabi', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('koh-samui', (SELECT id FROM destination WHERE slug = 'tajland'), 'ISLAND', 'Koh Samui', NULL, 'TH', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'koh-samui'), NULL, 'Koh Samui', 'koh samui', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'koh-samui'), NULL, 'samui', 'samui', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('pataja', (SELECT id FROM destination WHERE slug = 'tajland'), 'RESORT', 'Pataja', NULL, 'TH', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'pataja'), NULL, 'Pataja', 'pataja', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'pataja'), NULL, 'pattaya', 'pattaya', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('tanzanija', NULL, 'COUNTRY', 'Tanzanija', 'Tanzania', 'TZ', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tanzanija'), NULL, 'Tanzanija', 'tanzanija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tanzanija'), NULL, 'Tanzania', 'tanzania', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('zanzibar', (SELECT id FROM destination WHERE slug = 'tanzanija'), 'ISLAND', 'Zanzibar', NULL, 'TZ', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'zanzibar'), NULL, 'Zanzibar', 'zanzibar', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('maldivi', NULL, 'COUNTRY', 'Maldivi', 'Maldives', 'MV', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'maldivi'), NULL, 'Maldivi', 'maldivi', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'maldivi'), NULL, 'Maldives', 'maldives', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('sri-lanka', NULL, 'COUNTRY', 'Šri Lanka', 'Sri Lanka', 'LK', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'sri-lanka'), NULL, 'Šri Lanka', 'sri lanka', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('indonezija', NULL, 'COUNTRY', 'Indonezija', 'Indonesia', 'ID', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'indonezija'), NULL, 'Indonezija', 'indonezija', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'indonezija'), NULL, 'Indonesia', 'indonesia', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('bali', (SELECT id FROM destination WHERE slug = 'indonezija'), 'ISLAND', 'Bali', NULL, 'ID', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bali'), NULL, 'Bali', 'bali', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kuba', NULL, 'COUNTRY', 'Kuba', 'Cuba', 'CU', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kuba'), NULL, 'Kuba', 'kuba', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kuba'), NULL, 'Cuba', 'cuba', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('varadero', (SELECT id FROM destination WHERE slug = 'kuba'), 'RESORT', 'Varadero', NULL, 'CU', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'varadero'), NULL, 'Varadero', 'varadero', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('havana', (SELECT id FROM destination WHERE slug = 'kuba'), 'CITY', 'Havana', NULL, 'CU', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'havana'), NULL, 'Havana', 'havana', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('dominikanska-republika', NULL, 'COUNTRY', 'Dominikanska Republika', 'Dominican Republic', 'DO', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'dominikanska-republika'), NULL, 'Dominikanska Republika', 'dominikanska republika', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'dominikanska-republika'), NULL, 'Dominican Republic', 'dominican republic', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'dominikanska-republika'), NULL, 'dominikana', 'dominikana', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('punta-kana', (SELECT id FROM destination WHERE slug = 'dominikanska-republika'), 'RESORT', 'Punta Kana', NULL, 'DO', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'punta-kana'), NULL, 'Punta Kana', 'punta kana', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'punta-kana'), NULL, 'punta cana', 'punta cana', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('meksiko', NULL, 'COUNTRY', 'Meksiko', 'Mexico', 'MX', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'meksiko'), NULL, 'Meksiko', 'meksiko', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'meksiko'), NULL, 'Mexico', 'mexico', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kankun', (SELECT id FROM destination WHERE slug = 'meksiko'), 'RESORT', 'Kankun', NULL, 'MX', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kankun'), NULL, 'Kankun', 'kankun', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kankun'), NULL, 'cancun', 'cancun', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('rivijera-maja', (SELECT id FROM destination WHERE slug = 'meksiko'), 'REGION', 'Rivijera Maja', NULL, 'MX', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'rivijera-maja'), NULL, 'Rivijera Maja', 'rivijera maja', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'rivijera-maja'), NULL, 'riviera maya', 'riviera maya', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('tunis', NULL, 'COUNTRY', 'Tunis', 'Tunisia', 'TN', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tunis'), NULL, 'Tunis', 'tunis', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'tunis'), NULL, 'Tunisia', 'tunisia', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('hamamet', (SELECT id FROM destination WHERE slug = 'tunis'), 'RESORT', 'Hamamet', NULL, 'TN', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'hamamet'), NULL, 'Hamamet', 'hamamet', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'hamamet'), NULL, 'hammamet', 'hammamet', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('suse', (SELECT id FROM destination WHERE slug = 'tunis'), 'RESORT', 'Suse', NULL, 'TN', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'suse'), NULL, 'Suse', 'suse', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'suse'), NULL, 'sousse', 'sousse', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('dzerba', (SELECT id FROM destination WHERE slug = 'tunis'), 'ISLAND', 'Džerba', NULL, 'TN', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'dzerba'), NULL, 'Džerba', 'dzerba', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'dzerba'), NULL, 'djerba', 'djerba', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('maroko', NULL, 'COUNTRY', 'Maroko', 'Morocco', 'MA', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'maroko'), NULL, 'Maroko', 'maroko', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'maroko'), NULL, 'Morocco', 'morocco', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('marakes', (SELECT id FROM destination WHERE slug = 'maroko'), 'CITY', 'Marakeš', NULL, 'MA', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'marakes'), NULL, 'Marakeš', 'marakes', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'marakes'), NULL, 'marrakech', 'marrakech', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('agadir', (SELECT id FROM destination WHERE slug = 'maroko'), 'RESORT', 'Agadir', NULL, 'MA', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'agadir'), NULL, 'Agadir', 'agadir', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('kipar', NULL, 'COUNTRY', 'Kipar', 'Cyprus', 'CY', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kipar'), NULL, 'Kipar', 'kipar', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'kipar'), NULL, 'Cyprus', 'cyprus', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('ajia-napa', (SELECT id FROM destination WHERE slug = 'kipar'), 'RESORT', 'Ajia Napa', NULL, 'CY', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ajia-napa'), NULL, 'Ajia Napa', 'ajia napa', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'ajia-napa'), NULL, 'ayia napa', 'ayia napa', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('larnaka', (SELECT id FROM destination WHERE slug = 'kipar'), 'CITY', 'Larnaka', NULL, 'CY', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'larnaka'), NULL, 'Larnaka', 'larnaka', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'larnaka'), NULL, 'larnaca', 'larnaca', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('pafos', (SELECT id FROM destination WHERE slug = 'kipar'), 'RESORT', 'Pafos', NULL, 'CY', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'pafos'), NULL, 'Pafos', 'pafos', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'pafos'), NULL, 'paphos', 'paphos', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('malta', NULL, 'COUNTRY', 'Malta', 'Malta', 'MT', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'malta'), NULL, 'Malta', 'malta', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('andora', NULL, 'COUNTRY', 'Andora', 'Andorra', 'AD', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'andora'), NULL, 'Andora', 'andora', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'andora'), NULL, 'Andorra', 'andorra', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('slovacka', NULL, 'COUNTRY', 'Slovačka', 'Slovakia', 'SK', FALSE, FALSE, 100)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'slovacka'), NULL, 'Slovačka', 'slovacka', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'slovacka'), NULL, 'Slovakia', 'slovakia', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('jasna', (SELECT id FROM destination WHERE slug = 'slovacka'), 'RESORT', 'Jasna', NULL, 'SK', FALSE, TRUE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'jasna'), NULL, 'Jasna', 'jasna', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
INSERT INTO destination (slug, parent_id, kind, name_sr, name_en, country_code, is_departure_hub, is_ski, popularity)
VALUES ('bratislava', (SELECT id FROM destination WHERE slug = 'slovacka'), 'CITY', 'Bratislava', NULL, 'SK', FALSE, FALSE, 80)
ON CONFLICT (slug) DO UPDATE SET parent_id = EXCLUDED.parent_id, kind = EXCLUDED.kind, name_sr = EXCLUDED.name_sr, name_en = EXCLUDED.name_en, is_departure_hub = EXCLUDED.is_departure_hub, is_ski = EXCLUDED.is_ski, popularity = EXCLUDED.popularity, updated_at = now();
INSERT INTO destination_alias (destination_id, source_id, raw_name, normalized, status)
VALUES ((SELECT id FROM destination WHERE slug = 'bratislava'), NULL, 'Bratislava', 'bratislava', 'CONFIRMED')
ON CONFLICT (normalized, COALESCE(source_id, 0)) DO NOTHING;
