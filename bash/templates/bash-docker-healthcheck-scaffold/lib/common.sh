#!/usr/bin/env bash
# last_verified: 2026-08-15 · bash 5.3
# Shared helpers for the health-check scaffold. Sourced only — this file never
# executes anything at the top level beyond defining functions and readonly
# constants, so it is safe to load from a hook, a host script, or a bats test.
set -Eeuo pipefail

# log: print a timestamped line. UTC keeps host and container timestamps
# comparable even when TZ settings differ.
log() {
    printf '[%s] %s\n' "$(date -u +%H:%M:%S)" "$*"
}

# wait_for_port: probe a TCP port with a short /dev/tcp attempt, retry with a
# backoff capped at 5s, and give up after a bounded number of attempts with a
# clear message rather than blocking forever.
wait_for_port() {
    local host="${1:?host required}"
    local port="${2:?port required}"
    local attempts="${3:-30}"
    local attempt=0
    local delay=1

    log "waiting for $host:$port to accept connections"
    while (( attempt < attempts )); do
        if timeout 2 bash -c "echo > /dev/tcp/$host/$port" 2>/dev/null; then
            log "$host:$port is up"
            return 0
        fi
        attempt=$((attempt + 1))
        log "attempt $attempt/$attempts: $host:$port not reachable yet"
        sleep "$delay"
        delay=$((delay < 5 ? delay + 1 : 5))
    done

    log "gave up after $attempts attempts: $host:$port never came up" >&2
    return 1
}

# wait_for_healthy: poll a container's health status until it reports healthy.
# Accepts a container name or id. The `docker` binary is resolved through PATH
# so tests can mock it.
wait_for_healthy() {
    local container="${1:?container name or id required}"
    local attempts="${2:-60}"
    local attempt=0

    while (( attempt < attempts )); do
        local status
        status="$(docker inspect --format '{{.State.Health.Status}}' "$container" 2>/dev/null || echo unknown)"
        case "$status" in
            healthy)
                log "$container is healthy"
                return 0
                ;;
            unhealthy)
                log "$container reported unhealthy" >&2
                return 1
                ;;
        esac
        attempt=$((attempt + 1))
        sleep 1
    done

    log "gave up after $attempts seconds: $container never became healthy" >&2
    return 1
}

# require_command: fail fast with a readable message when a binary is missing.
require_command() {
    local bin="${1:?binary required}"
    if ! command -v "$bin" >/dev/null 2>&1; then
        log "required binary not found: $bin" >&2
        return 1
    fi
}
