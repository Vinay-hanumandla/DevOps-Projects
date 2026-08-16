#!/usr/bin/env bash
# last_verified: 2026-08-15 · bash 5.3
# Container entry point. Runs every hook in /docker-entrypoint.d/*.sh in order,
# then execs the real CMD so that process becomes PID 1. Without the trailing
# `exec "$@"` the CMD would run as a child, and a stop/signal would not reach
# the main process.
set -Eeuo pipefail

# shellcheck source=/opt/app/lib/common.sh
# shellcheck disable=SC1091
source /opt/app/lib/common.sh

for hook in /docker-entrypoint.d/*.sh; do
    [ -e "$hook" ] || continue
    log "running $hook"
    bash "$hook"
done

exec "$@"
