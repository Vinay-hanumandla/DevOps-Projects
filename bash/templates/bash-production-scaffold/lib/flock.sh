#!/usr/bin/env bash
# last_verified: 2026-08-25 · bash 5.3.15

with_flock() {
    local lockfile="$1"
    shift
    local cmd=("$@")
    exec {fd}>"$lockfile" || fail "Could not open lockfile $lockfile"
    if ! flock -n "$fd"; then
        fail "Another instance is running (lockfile: $lockfile)"
    fi
    "${cmd[@]}"
}
