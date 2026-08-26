#!/usr/bin/env bats
# last_verified: 2026-08-25 · bash

load "../lib/logging.sh"
load "../lib/retry.sh"
load "../lib/flock.sh"
load "../lib/env.sh"

@test "env_assert fails when variable is unset" {
    run env_assert "MISSING_VAR"
    [ "$status" -ne 0 ]
    [[ "$output" == *"MISSING_VAR is required"* ]]
}

@test "require_cmd passes for existing command" {
    run require_cmd cat
    [ "$status" -eq 0 ]
}

@test "with_retry succeeds on first attempt" {
    run with_retry 3 1 true
    [ "$status" -eq 0 ]
}

@test "with_retry fails after exhausting retries" {
    run with_retry 2 1 false
    [ "$status" -ne 0 ]
}

@test "with_flock runs a command under an advisory lock" {
    run with_flock "/tmp/bash-production-scaffold.lock" -- true
    [ "$status" -eq 0 ]
}
