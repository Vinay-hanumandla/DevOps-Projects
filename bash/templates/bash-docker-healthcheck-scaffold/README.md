---
last_verified: 2026-08-15
tool_version: 5.3
sources:
  - https://bashsnippets.xyz/guides/bash-scripting-for-ci-cd-pipelines
  - https://docs.docker.com/guides/gha/
  - https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/add-scripts
  - https://www.gnu.org/software/bash/manual/bash.html
---

# Project scaffold: Bash + Docker multi-container health-check integration

A starting layout for a Bash project that runs as several containers and treats
health checks as the contract between them. Every service declares one, the
entry point refuses to start a process whose dependency port is not reachable,
and the host orchestration script waits for `healthy` before it reports a
successful bring-up.

This is the second Bash + Docker scaffold in the kit — where `bash-docker-scaffold`
is a dev toolchain container, this one is a small running stack whose startup
ordering is wired through health checks.

## Layout

```
.
├── Makefile               # up / down / ps / logs / health / lint shortcuts
├── docker-compose.yml     # cache + web + worker, service_healthy ordering
├── Dockerfile             # runtime image: bash 5.3-alpine, non-root app user
├── docker-entrypoint.sh   # runs hooks, then `exec "$@"` so CMD becomes PID 1
├── docker-entrypoint.d/
│   └── 10-wait-for-cache.sh  # refuses to start until the cache port is open
├── app/
│   ├── healthcheck.sh     # generic TCP healthcheck, used by compose and hosts
│   ├── responder.sh       # demo TCP listener so checks have a port to probe
│   └── main.sh            # demo worker that keeps verifying the dependency
├── lib/
│   └── common.sh          # log / wait_for_port / wait_for_healthy helpers
├── scripts/
│   ├── up.sh              # compose up -d, then wait for every service healthy
│   └── down.sh            # compose down
└── tests/
    └── common_test.bats   # bats tests with docker/timeout mocked via PATH
```

The rule of thumb: `lib/` holds functions you `source`, `app/` holds what runs
inside a container, `scripts/` holds host-side orchestration, `tests/` holds
bats tests.

## Getting started

Prerequisites: Docker with the `docker compose` v2 plugin. Nothing else needs
installing — the helpers run inside the same images they manage.

```sh
make up       # compose up -d --build, then wait_for_healthy on each service
make ps       # confirm the services are running
make health   # print container -> health status for every container
make logs     # follow container logs
make down     # tear the stack down
```

`scripts/up.sh` is the interesting part: it builds the stack, then for each of
`cache`, `web`, `worker` resolves the container id and polls its Docker health
status. If a service stays `unhealthy`, the script exits nonzero with a message
instead of pretending the bring-up succeeded.

## Verify

```sh
make health
# abc123: healthy
# def456: healthy
# ghi789: healthy
```

Compose enforces the ordering through `depends_on: ... condition:
service_healthy`, so `web` will not start until `cache` is healthy and `worker`
will not start until `web` is. The entry point enforces the same rule in Bash
(10-wait-for-cache.sh), which means ordering also holds if someone starts a
single container directly, bypassing compose.

## Conventions baked in

- Every entry point starts with `#!/usr/bin/env bash` and `set -Eeuo pipefail`.
  In CI, where `command | tee log` can swallow an exit code, `pipefail` is what
  keeps a failing step from shipping a green checkmark.
- The entry point ends with `exec "$@"`. Without it the CMD runs as a child of
  the entry point, stays out of PID 1, and a stop never reaches the real
  process. The hooks run first so dependencies are confirmed before the main
  command.
- Port probing uses a bounded `/dev/tcp` attempt wrapped in a short `timeout`,
  retried with backoff capped at 5s, and fails after a set number of attempts
  with a clear message — never blocks forever.
- Health checks live in one script (`app/healthcheck.sh`) that compose `CMD-SHELL`
  blocks and the host share, so the container and the orchestrator are judging
  the same condition.

This is one way to wire the pieces together. Compose also ships a built-in
`up --wait` flag that polls service health itself; this scaffold keeps the
polling in Bash so the same helpers are unit-testable on the host without a
running daemon. The GitHub Actions docs also recommend committing scripts as
executable and invoking them through `run: bash script.sh` — the entry point
and hook layout here assume the same contract.
