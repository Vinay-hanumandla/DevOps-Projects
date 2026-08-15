#!/usr/bin/env bash
# last_verified: 2026-08-15 · bash 5.3
# Generic container healthcheck. Probes a TCP endpoint with a single bounded
# /dev/tcp attempt and exits 0 on success. Wired into docker compose through
# `healthcheck:` blocks, and reusable on the host for the same service.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
# shellcheck disable=SC1091
source "$ROOT/lib/common.sh"

host="${HEALTHCHECK_HOST:-127.0.0.1}"
port=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --port)
            port="${2:?--port needs a value}"
            shift 2
            ;;
        --host)
            host="${2:?--host needs a value}"
            shift 2
            ;;
        *)
            log "unknown argument: $1" >&2
            exit 2
            ;;
    esac
done

if [[ -z "$port" ]]; then
    log "no port given (use --port)" >&2
    exit 2
fi

wait_for_port "$host" "$port" 1
