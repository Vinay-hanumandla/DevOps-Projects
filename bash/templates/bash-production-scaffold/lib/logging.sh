#!/usr/bin/env bash
# last_verified: 2026-08-25 · bash 5.3.15

log() {
    printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >&2
}

warn() {
    log "WARN: $*"
}

err() {
    log "ERROR: $*"
}

fail() {
    err "$@"
    exit 1
}
