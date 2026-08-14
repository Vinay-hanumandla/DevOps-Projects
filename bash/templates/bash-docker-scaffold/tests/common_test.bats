#!/usr/bin/env bats
# last_verified: 2026-08-13 · bash

load "../lib/common.sh"

@test "greet prints app name and given name" {
    run greet "dev"
    [ "$status" -eq 0 ]
    [[ "$output" == *"bash-docker-scaffold: hello, dev!"* ]]
}

@test "greet defaults to world when no name given" {
    run greet
    [ "$status" -eq 0 ]
    [[ "$output" == *"hello, world!"* ]]
}

@test "greet handles a name with spaces" {
    run greet "Jane Doe"
    [ "$status" -eq 0 ]
    [[ "$output" == *"hello, Jane Doe!"* ]]
}