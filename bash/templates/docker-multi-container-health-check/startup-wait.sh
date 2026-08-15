#!/usr/bin/env bash
# last_verified: 2026-08-15 · bash
# Waits for all Compose services to report healthy before exiting.
# Designed to be called from `make up` or directly from CI.
set -Eeuo pipefail

TIMEOUT="${HEALTH_TIMEOUT:-60}"
POLL_INTERVAL="${HEALTH_POLL:-2}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yaml}"

docker compose -f "$COMPOSE_FILE" up -d

elapsed=0
while [ "$elapsed" -lt "$TIMEOUT" ]; do
  unhealthy=$(docker compose -f "$COMPOSE_FILE" ps --format '{{.Name}} {{.State}}' \
    | grep -vE '(healthy|running)' || true)
  if [ -z "$unhealthy" ]; then
    echo "All services healthy after ${elapsed}s."
    exit 0
  fi
  sleep "$POLL_INTERVAL"
  elapsed=$((elapsed + POLL_INTERVAL))
done

echo "Timeout: services not healthy after ${TIMEOUT}s." >&2
echo "$unhealthy" >&2
docker compose -f "$COMPOSE_FILE" ps >&2
exit 1
