#!/usr/bin/env bash
# last_verified: 2026-08-25 · bash 5.3.15

with_retry() {
    local max="$1" delay="$2"
    shift 2
    local cmd=("$@")
    local attempt=0
    until "${cmd[@]}"; do
        attempt=$((attempt + 1))
        if (( attempt >= max )); then
            err "Command failed after $attempt attempts: ${cmd[*]}"
            return 1
        fi
        warn "Attempt $attempt failed, retrying in ${delay}s..."
        sleep "$delay"
    done
}
