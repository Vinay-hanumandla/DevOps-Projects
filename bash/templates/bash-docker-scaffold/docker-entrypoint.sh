#!/usr/bin/env bash
# last_verified: 2026-08-13 · bash
# Runs docker-entrypoint.d/*.sh hooks in order, then execs the real CMD so it
# becomes PID 1. Mirrors the pattern the nginx/postgres images use.
set -Eeuo pipefail

for hook in /docker-entrypoint.d/*.sh; do
    [ -e "$hook" ] || continue
    echo "[entrypoint] running $hook"
    bash "$hook"
done

exec "$@"