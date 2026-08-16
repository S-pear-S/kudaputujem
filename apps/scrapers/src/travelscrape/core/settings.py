"""Konfiguracija skrepera iz environment varijabli i .env fajla."""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        env_prefix="SCRAPER_",
        extra="ignore",
    )

    # API konekcija
    api_url: str = "http://localhost:8080"
    ingest_api_key: str = "dev-ingest-key"

    # Ponašanje skrepera (poštovanje sajtova)
    min_request_delay_s: float = 2.0
    max_concurrent_per_domain: int = 2
    request_timeout_s: float = 30.0
    max_retries: int = 3

    # Pipeline
    batch_size: int = 50
    dry_run: bool = False


settings = Settings()
