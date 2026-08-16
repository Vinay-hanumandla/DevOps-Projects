#!/usr/bin/env bash
# last_verified: 2026-08-15 · bash 5.3
# Demo worker: the "work" it does is to keep verifying the cache dependency is
# reachable. Startup ordering here is explicit in Bash (wait_for_port) and
# enforced again in compose via depends_on + service_healthy.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
# shellcheck disable=SC1091
source "$ROOT/lib/common.sh"

wait_for_port "${CACHE_HOST:-cache}" "${CACHE_PORT:-6379}" "${CACHE_MAX_ATTEMPTS:-30}"

while true; do
    log "worker tick: cache at ${CACHE_HOST:-cache}:${CACHE_PORT:-6379} is reachable"
    sleep 5
done
