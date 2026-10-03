"""Typed application settings, read from the environment and an optional .env file."""
# last_verified: 2026-10-03 · python n/a

from functools import lru_cache
from typing import Literal

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Every setting the service reads.

    Values resolve from real environment variables first, then from the ``.env``
    file, then from the defaults below.
    """

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    app_name: str = "python-service-scaffold"
    environment: Literal["local", "test", "staging", "production"] = "local"
    log_level: str = "INFO"

    database_url: str = Field(
        default="sqlite:///./app.db",
        description="SQLAlchemy URL; use postgresql+psycopg://... for a server.",
    )
    sql_echo: bool = False


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return the one settings instance for this process."""
    return Settings()