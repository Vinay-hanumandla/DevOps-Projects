---
last_verified: 2026-08-17
tool_version: 5.3
sources:
  - https://kubernetes.recipes/recipes/configuration/kubernetes-kubectl-wait-scripting/
---

# Project scaffold: Bash + Docker multi-container health-check integration

A copy-in project layout for a multi-container stack whose startup ordering is
driven by Docker health checks rather than fixed sleeps. Compose uses
`depends_on: condition: service_healthy` to enforce ordering, and the entrypoint
hook refuses to start a process whose dependency port is not yet reachable — so
ordering holds even when a container is started directly, bypassing Compose.

## When to use

Use this scaffold when a service depends on another service being ready, and
`docker compose up` alone is not enough because Compose only waits for a
container to be running, not for its health check to pass. The pattern applies
to any stack where startup ordering matters: a cache before a web front end,
a web front end before a background worker, or a database before a migration
job.

## Prerequisites

- Docker Engine with the `docker compose` v2 plugin.
- Bash 5.x on the host (the scripts assume `set -Eeuo pipefail` and `/dev/tcp`).
- `make` is optional; the `scripts/` wrappers can be invoked directly.

## Directory layout

```
.
├── .dockerignore               # keeps build context small
├── Dockerfile                  # runtime image: bash 5.3-alpine, non-root app user
├── Makefile                    # up / down / ps / logs / health / lint shortcuts
├── README.md                   # this file
├── docker-compose.yml          # cache + web + worker with service_healthy ordering
├── docker-entrypoint.sh        # runs /docker-entrypoint.d/*.sh hooks, then execs CMD
├── docker-entrypoint.d/
│   └── 10-wait-for-cache.sh    # skips itself for the cache service; waits for others
├── app/
│   ├── healthcheck.sh          # generic TCP probe used by compose and the entrypoint
│   ├── main.sh                 # demo worker that verifies the cache dependency
│   └── responder.sh            # demo TCP listener for health-check targets
├── lib/
│   └── common.sh               # log / wait_for_port / wait_for_healthy / require_command
├── scripts/
│   ├── down.sh                 # compose down
│   └── up.sh                   # compose up -d --build, then poll every service healthy
└── tests/
    └── common_test.bats        # bats unit tests with docker and timeout mocked
```

## How the health-check flow works

1. Compose starts `cache`, `web`, and `worker` in parallel.
2. `depends_on: condition: service_healthy` blocks `web` until `cache` reports
   `healthy`, and blocks `worker` until both `cache` and `web` report `healthy`.
3. Inside each container, `docker-entrypoint.sh` runs
   `/docker-entrypoint.d/10-wait-for-cache.sh` before the CMD. The hook skips
   itself for the cache service (`SKIP_ENTRYPOINT_WAIT=true`) and otherwise
   waits for the cache port to accept connections.
4. `scripts/up.sh` calls `docker compose up -d --build`, then resolves each
   service's container id and polls `docker inspect --format
   '{{.State.Health.Status}}'` until it returns `healthy` or the attempt limit
   is hit.

The health check logic lives in one place — `app/healthcheck.sh` — so Compose
and the host scripts judge the same condition.

## Getting started

```sh
make up       # compose up -d --build, then wait_for_healthy on each service
make ps       # confirm the services are running
make health   # print container -> health status for every container
make logs     # follow container logs
make down     # tear the stack down
```

## Verify

```sh
make health
# <container-id>: healthy
# <container-id>: healthy
# <container-id>: healthy
```

If a service stays `unhealthy`, `scripts/up.sh` exits nonzero with a message
instead of pretending the bring-up succeeded.

## Common errors

- **Container never becomes healthy.** The most common cause is a port conflict
  on the host (another process already bound to 6379 or 8080). Check with
  `docker compose ps` and `docker logs <container>`.
- **Health check stuck in `starting`.** Docker reports `starting` while the
  health check command is running but has not yet produced a result. If a
  service stays in `starting` past its `start_period`, inspect the container
  logs — the health check script may be hanging on a DNS lookup or a file
  permission.
- **Entry-point hook exits before CMD.** Hooks run with `set -Eeuo pipefail`;
  any unhandled non-zero exit aborts the entrypoint. Make every hook tolerate
  the container's initial state.

## Conventions baked in

- Every entry point starts with `#!/usr/bin/env bash` and `set -Eeuo pipefail`.
  In CI, where `command | tee log` can swallow an exit code, `pipefail` keeps
  a failing step from shipping a green checkmark.
- The entry point ends with `exec "$@"`. Without it the CMD runs as a child of
  the entry point, stays out of PID 1, and a stop never reaches the real
  process.
- Port probing uses a bounded `/dev/tcp` attempt wrapped in a short `timeout`,
  retried with backoff capped at 5s, and fails after a set number of attempts
  with a clear message — never blocks forever.
- Health checks live in one script (`app/healthcheck.sh`) that Compose
  `CMD-SHELL` blocks and the host share, so the container and the orchestrator
  judge the same condition.
