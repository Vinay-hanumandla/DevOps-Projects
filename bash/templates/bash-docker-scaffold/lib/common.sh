#!/usr/bin/env bash
# last_verified: 2026-08-13 · bash
# Sourced helper library: functions and readonly constants only. Never runs
# code at the top level beyond defining things, so it can be sourced safely.
readonly APP_NAME="bash-docker-scaffold"

# greet: print a one-line greeting.
greet() {
    local name="${1:-world}"
    printf '%s: hello, %s!\n' "$APP_NAME" "$name"
}