#!/usr/bin/env bash
# last_verified: 2026-08-17 · bash 5.3
# Hook 10: refuse to start the main process until the cache dependency is
# reachable. Skips itself when SKIP_ENTRYPOINT_WAIT=true (used by the cache
# service so it does not wait for itself to be ready before starting).
set -Eeuo pipefail

# shellcheck source=/opt/app/lib/common.sh
# shellcheck disable=SC1091
source /opt/app/lib/common.sh

if [[ "${SKIP_ENTRYPOINT_WAIT:-}" == "true" ]]; then
    log "skipping entrypoint wait (SKIP_ENTRYPOINT_WAIT=true)"
    exit 0
fi

wait_for_port "${CACHE_HOST:-cache}" "${CACHE_PORT:-6379}" "${CACHE_MAX_ATTEMPTS:-30}"
