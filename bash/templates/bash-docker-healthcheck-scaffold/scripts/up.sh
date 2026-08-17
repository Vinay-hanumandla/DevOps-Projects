#!/usr/bin/env bash
# last_verified: 2026-08-17 · bash 5.3
# Bring the stack up and confirm every service reports healthy before handing
# back to the caller. Uses the same lib helpers the containers themselves use.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
# shellcheck disable=SC1091
source "$ROOT/lib/common.sh"

require_command docker

cd "$ROOT"
log "starting stack"
docker compose up -d --build

for service in cache web worker; do
    container="$(docker compose ps -q "$service")"
    if [[ -n "$container" ]]; then
        wait_for_healthy "$container" 60
    else
        log "no container found for service $service" >&2
        exit 1
    fi
done

log "stack is up and healthy"
docker compose ps
