# last_verified: 2026-09-16 · python n/a
"""
config-loader-pydantic-settings.py

Reusable configuration loader: a Pydantic Settings model that reads from a YAML
file and lets environment variables override any field. Exposes a single
`get_settings()` entry point so callers get one validated config object no
matter how the process was started.

Usage:
    python config-loader-pydantic-settings.py path/to/config.yaml
    APP_PORT=9000 python config-loader-pydantic-settings.py path/to/config.yaml
"""

import os
import sys
from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class AppSettings(BaseSettings):
    """Validated application settings sourced from YAML with env overrides."""

    model_config = SettingsConfigDict(
        env_prefix="APP_",
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=False,
    )

    app_name: str = Field(default="my-app", description="Human-readable app name")
    debug: bool = Field(default=False, description="Enable debug logging")
    host: str = Field(default="127.0.0.1", description="Bind address")
    port: int = Field(default=8000, description="Listen port")
    log_level: str = Field(default="info", description="Logging level")

    database_url: str = Field(
        default="sqlite:///app.db",
        description="Database connection URL",
    )
    database_pool_size: int = Field(default=5, description="Connection pool size")
    database_timeout: float = Field(default=30.0, description="Query timeout in seconds")


def load_settings(config_path: str | None = None) -> AppSettings:
    """Build an AppSettings instance, merging YAML then environment variables.

    Precedence (lowest to highest): defaults -> YAML file -> environment
    variables -> constructor overrides.
    """
    yaml_data: dict = {}
    if config_path:
        path = Path(config_path)
        if not path.is_file():
            print(f"Error: config file not found: {config_path}", file=sys.stderr)
            sys.exit(1)
        try:
            import yaml

            with path.open("r", encoding="utf-8") as f:
                loaded = yaml.safe_load(f)
            if isinstance(loaded, dict):
                yaml_data = loaded
        except ImportError:
            print("PyYAML is required to read YAML config files", file=sys.stderr)
            sys.exit(1)

    return AppSettings(**yaml_data)


def main() -> None:
    if len(sys.argv) > 2:
        print("Usage: python config-loader-pydantic-settings.py [config.yaml]")
        sys.exit(1)

    config_path = sys.argv[1] if len(sys.argv) == 2 else None
    settings = load_settings(config_path)

    print(f"app_name:    {settings.app_name}")
    print(f"debug:       {settings.debug}")
    print(f"host:        {settings.host}")
    print(f"port:        {settings.port}")
    print(f"log_level:   {settings.log_level}")
    print(f"database_url: {settings.database_url}")
    print(f"database_pool_size: {settings.database_pool_size}")
    print(f"database_timeout:   {settings.database_timeout}")


if __name__ == "__main__":
    main()