---
last_verified: 2026-09-30
tool_version: n/a
---

# Microservices multistage scaffold

> A Compose stack where every built service uses a two-stage Dockerfile, with health-gated startup and file-based secrets. This is one way to lay out a small api + worker + web project; the Compose docs also show single-stage builds, which are simpler when image size does not matter yet.

## Purpose

The scaffold wires four practices together so a new microservices checkout starts in a known-good shape: each service image is built in two stages (a `builder` stage that gathers sources and a `runtime` stage that ships only what the service runs), every long-running service carries a `healthcheck` so `depends_on: condition: service_healthy` waits for readiness instead of just startup, secrets reach containers as files under `/run/secrets` rather than environment values, and ports plus database names stay tunable through an `.env` file.

## Layout

| Path | What it is |
|---|---|
| `docker-compose.yml` | Five services: `db`, `cache`, `api`, `worker`, `web`, plus `pgdata` volume and two file secrets |
| `api/Dockerfile`, `api/server.py` | Two-stage build; stdlib-only HTTP API with `/health` |
| `worker/Dockerfile`, `worker/worker.py` | Two-stage build; background consumer that reads the api key secret file |
| `web/index.html` | Static page mounted read-only into the web server |
| `.env.example` | Tunables (ports, db name/user) — copy to `.env` |
| `secrets/*.example` | Placeholder secret files — copy without the extension and fill in |

## Steps

1. Copy the examples into real (git-ignored) files: `cp .env.example .env`, `cp secrets/db_password.txt.example secrets/db_password.txt`, `cp secrets/api_key.txt.example secrets/api_key.txt`, then fill in real values.
2. Build and start the stack: `docker compose up --build`. The `worker` and `web` services wait until `api` is healthy, which itself waits until `db` and `cache` are healthy.
3. Check the API: open `/health` on the configured api port; it answers `{"status": "ok"}`. The `web` port serves the static page from `web/index.html`.

## Verify

- `docker compose ps` shows `db`, `cache`, and `api` as `healthy`, with `worker` running behind the healthy `api` and `web` serving traffic.
- The API `/health` endpoint returns `{"status": "ok"}` on the configured api port.
- `docker compose logs worker` shows the `api_key present` start line followed by heartbeat lines, confirming the secret file was mounted.
- `docker images` shows the built `api` and `worker` images with no build-time leftovers beyond the single copied source file.
