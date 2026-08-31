-- =====================================================================================
-- Kuda putujem — V3: agencije i izvori za dva gotova adaptera
--
-- Bez ovoga `source.slug` ne postoji u bazi, `find_source()` diže source_not_found, i
-- nijedan adapter ne moze da otvori rundu — nijedan red u V1/V2 nikad nije popunio ove
-- dve tabele (samo geo seed). Otkriveno pri pisanju ADR 0001 koraka 4 (CLAUDE.md §7/§9).
--
-- `source.slug` MORA da se poklapa sa adapterovim `source_slug` ClassVar-om, jer ga
-- travelscrape CLI ("travelscrape run <source_slug>") koristi da nadje adapter kroz
-- registry.get(), a IngestClient.start_run salje TAJ ISTI string API-ju. Provereno u
-- apps/scrapers/src/travelscrape/adapters/{soleazur,oktopod}.py — nije prepisano naslepo.
-- =====================================================================================

INSERT INTO agency (slug, name, website_url, country_code, product_kinds, is_active)
VALUES
    ('sole-azur', 'Sole Azur', 'https://soleazur.rs', 'RS', ARRAY['PACKAGE'], TRUE),
    ('oktopod-travel', 'Oktopod Travel', 'https://oktopod.rs', 'RS', ARRAY['PACKAGE'], TRUE);

INSERT INTO source (
    agency_id, slug, label, base_url, adapter_key, product_kind,
    robots_allowed, crawl_delay_ms, max_concurrency, expected_min_items, is_enabled
)
VALUES
    (
        (SELECT id FROM agency WHERE slug = 'sole-azur'),
        'soleazur-grcka', 'Sole Azur — Grčka (last minute)', 'https://soleazur.rs',
        'soleazur', 'PACKAGE', TRUE, 2000, 2, 20, TRUE
    ),
    (
        (SELECT id FROM agency WHERE slug = 'oktopod-travel'),
        'oktopod-grcka', 'Oktopod Travel — Grčka', 'https://oktopod.rs',
        'oktopod', 'PACKAGE', TRUE, 2000, 2, 20, TRUE
    );
