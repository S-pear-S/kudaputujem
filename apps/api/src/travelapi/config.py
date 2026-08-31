"""Sva podešavanja na jednom mestu — ADR 0001 korak 4.

Prevod `ApiProperties.kt`, isti brojevi (application.yml), isti razlog da postoje na
jednom mestu: kad konfiguracija fali, server treba da padne odmah pri pokretanju sa
jasnom porukom, ne na prvom zahtevu. `DATABASE_URL` je isti izvor koji već koriste
`alembic` (migrations/env.py) i `travelscrape`/`test_sql_parity.py` — jedna kopija
konekcionog stringa.
"""

from __future__ import annotations

from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

# Apsolutna putanja do .env u korenu repoa — ne zavisi od radnog direktorijuma iz kog
# se uvicorn/pytest pokreće (za razliku od relativnog ".env", koje bi tražilo
# apps/api/.env kad se pokrene iz apps/api). Ako je DATABASE_URL već u okruženju
# (isti obrazac kao migrations/env.py i test_sql_parity.py), taj ima prednost —
# pydantic-settings čita process env pre .env fajla.
_REPO_ROOT_ENV = Path(__file__).resolve().parents[4] / ".env"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=str(_REPO_ROOT_ENV),
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # Isti podrazumevani obrazac kao .env.example / docker-compose.yml — Kotlin
    # ApiProperties.kt takođe daje dev-podrazumevane vrednosti svim poljima (§8 pravilo
    # 16: dva statička ključa), ne zahteva ih. Test kolekcija ne sme da pukne samo zato
    # što neki nepovezan test (npr. test_occupancy.py) uvozi nešto iz travelapi paketa.
    database_url: str = "postgresql://kudaputujem:promeni_me@localhost:5432/kudaputujem"

    # Zaštita /internal/ i /admin/ — isti princip kao ApiKeyFilter.kt (§8 pravilo 16:
    # namerno odvojeni ključevi, skreper koji procuri ne sme da briše agencije).
    ingest_api_key: str = "dev-ingest-key"
    admin_api_key: str = "dev-admin-key"

    # ingest (application.yml kudaputujem.ingest, CLAUDE.md §6 — brojevi se ne izmišljaju)
    suspect_ratio: float = 0.5
    history_window: int = 5
    max_offers_per_batch: int = 500


settings = Settings()
