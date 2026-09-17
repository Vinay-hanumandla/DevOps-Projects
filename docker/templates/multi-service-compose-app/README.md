---
last_verified: 2026-09-17
tool_version: n/a
---

# Multi-service Compose app scaffold

> A starting point for a small Compose stack — web front, stdlib API, database, and cache — with health-gated startup, file-based secrets, and a `tools` profile for one-shot helpers.

## Purpose

The scaffold shows one way to wire the three Compose features that keep biting in larger projects: `depends_on` that actually waits for readiness (via `healthcheck` plus `condition: service_healthy`), secrets passed as files instead of environment values, and `profiles` so helper services stay out of the default `up`. The `web` service has no healthcheck of its own; ordering is enforced through the healthy `api` instead, which keeps the web definition to a mount and a port mapping.

## Layout

| Path | What it is |
|---|---|
| `docker-compose.yml` | Six services: `db`, `cache`, `api`, `web`, plus profile-gated `migrate` and `db-shell` |
| `api/Dockerfile`, `api/server.py` | Stdlib-only HTTP API with `/health`; no third-party installs |
| `api/migrate.py` | Placeholder one-shot job for the `tools` profile |
| `web/index.html` | Static page mounted read-only into the web server |
| `.env.example` | Tunables (ports, db name/user, profiles) — copy to `.env` |
| `secrets/*.example` | Placeholder secret files — copy without the extension and fill in |

## Steps

1. Copy the examples into real (git-ignored) files:
   `cp .env.example .env`, `cp secrets/db_password.txt.example secrets/db_password.txt`, `cp secrets/api_key.txt.example secrets/api_key.txt`.
2. Bring up the default stack: `docker compose up --build`. The `migrate` and `db-shell` services stay out unless the `tools` profile is enabled.
3. Run the one-shot migration: `docker compose --profile tools run --rm migrate`. (Setting `COMPOSE_PROFILES=tools` in `.env` enables the profile for every command instead.)
4. Open an ad-hoc database shell: `docker compose --profile tools run --rm db-shell psql -h db -U app -d appdb`.

## Verify

- `docker compose ps` shows `db`, `cache`, and `api` as `healthy`, with `web` running behind the healthy `api`.
- The API answers on the configured api port: `/health` returns `{"status": "ok"}`.
- The web port serves the static page from `web/index.html`.
- `docker compose --profile tools run --rm migrate` exits 0 without starting extra long-running containers (`docker compose ps` afterwards shows only the four default services).
