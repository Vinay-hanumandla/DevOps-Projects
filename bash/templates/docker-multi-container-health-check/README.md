---
last_verified: 2026-08-15
tool_version: n/a
sources:
  - https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/add-scripts
  - https://bashsnippets.xyz/guides/bash-scripting-for-ci-cd-pipelines
---

# Project scaffold: Bash + Docker multi-container health-check integration

A project skeleton that demonstrates how a Bash wrapper script can coordinate
a multi-container Docker Compose environment by waiting for health-check signals
before proceeding. The pattern replaces brittle fixed sleep intervals with a
polling loop that queries actual container state.

## When to use

Use this scaffold when a script must guarantee that dependent services are ready
before running commands against them. Typical cases include:

- Running database migrations after the database container is healthy.
- Sending a smoke-test request to a web service after its container passes its
  own internal health check.
- Orchestrating a local integration-test environment from a single `make up`
  invocation.

## Prerequisites

- Docker Engine 28.x or later with the Compose v2 plugin (`docker compose`).
- `make` (the Makefile delegates all commands).
- Bash 5.x (the startup script uses `/dev/tcp` probing, available in all
  standard Bash builds).

## Layout

```
.
├── Makefile                # convenience targets for build / up / down / test
├── Dockerfile              # web-app image: Python 3.12 + Flask
├── docker-compose.yaml     # three services with health checks
├── startup-wait.sh         # waits for services to report healthy
└── README.md
```

## Steps

### 1. Build the images

```sh
make build
```

The Makefile runs `docker compose build --no-cache`, which forces a fresh pull
of the `python:3.12-slim` base image and re-runs the `pip install` layer only
when `requirements.txt` changes.

### 2. Start the stack and wait for readiness

```sh
make up
```

This calls `startup-wait.sh`, which runs `docker compose up -d` and then polls
each service's health status every two seconds until all services report
`healthy` or a 60-second timeout expires. The script exits non-zero on timeout
so CI pipelines fail fast instead of running tests against a half-ready stack.

### 3. Verify health status

```sh
make status
```

Runs `docker compose ps` and greps for any container that is not `healthy` or
`running`. A clean run prints nothing and exits 0.

### 4. Run a smoke test

```sh
make test
```

Sends an HTTP GET to the web-app container. The test passes only after the
health-check probe confirms the service is ready, so the request cannot race
the startup sequence.

### 5. Tear down

```sh
make down
```

Runs `docker compose down -v`, which removes containers and the named Redis
volume. Omit `-v` if you need to preserve data across restarts.

## Verify

After `make up`:

```sh
docker compose ps
# Every service should show "healthy" in the STATE column.

curl -fsS http://localhost:5000/
# {"status":"ok"}
```

If `startup-wait.sh` times out, inspect the container logs:

```sh
docker compose logs web
docker compose logs redis
```

## Common errors

- **Health check reports `unhealthy` immediately.** The `test` command in the
  Compose health check runs inside the container. If the image lacks `curl`
  (or `python` for a `CMD`-based probe), the check will always fail. Install
  the required binary in the Dockerfile or switch to a `CMD` probe.
- **`/dev/tcp` probe hangs.** Bash's built-in TCP check blocks until the kernel
  accepts or rejects the connection. Pair it with `timeout 2` (as the script
  does) so a closed port returns quickly instead of stalling the loop.
- **`docker compose down -v` deletes data.** Named volumes are destroyed by the
  `-v` flag. Use plain `docker compose down` during active development if you
  need to keep the Redis dataset between restarts.
- **Port already in use.** If another process occupies `localhost:5000`, Compose
  fails to start the web service. Stop the conflicting process or change the
  host-side port mapping in `docker-compose.yaml`.
