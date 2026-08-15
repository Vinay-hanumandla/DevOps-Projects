#!/usr/bin/env bash
# last_verified: 2026-08-15 · bash 5.3
# Hook 10: refuse to start the main process until the cache dependency is
# reachable. Runs inside the container before the CMD, using the same
# wait_for_port helper the host orchestration scripts use.
set -Eeuo pipefail

# shellcheck source=/opt/app/lib/common.sh
# shellcheck disable=SC1091
source /opt/app/lib/common.sh

wait_for_port "${CACHE_HOST:-cache}" "${CACHE_PORT:-6379}" "${CACHE_MAX_ATTEMPTS:-30}"
