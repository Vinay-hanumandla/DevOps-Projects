#!/usr/bin/env bash
# last_verified: 2026-08-17 · bash 5.3
# Minimal demo TCP responder so a service actually opens a port the health
# checks can probe. Busybox nc serves one connection per iteration; the `||`
# guard keeps the loop from spinning if a bind fails. Real services would
# replace this with the actual application.
set -Eeuo pipefail

port="${1:-8080}"

log() {
    printf '[responder] %s\n' "$*"
}

log "listening on :$port"
while true; do
    nc -l -p "$port" >/dev/null 2>&1 || sleep 0.2
done
