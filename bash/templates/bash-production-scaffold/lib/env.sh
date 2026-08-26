#!/usr/bin/env bash
# last_verified: 2026-08-25 · bash 5.3.15

require_cmd() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1 || fail "Required command not found: $cmd"
}

env_assert() {
    local var="$1"
    : "${!var:?Environment variable $var is required}"
}
