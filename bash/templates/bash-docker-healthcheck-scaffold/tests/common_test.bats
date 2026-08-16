#!/usr/bin/env bats
# last_verified: 2026-08-15 · bash 5.3

load "../lib/common.sh"

setup() {
    MOCK_BIN="$(mktemp -d)"
    export PATH="$MOCK_BIN:$PATH"
}

@test "log prefixes a UTC timestamp" {
    run log "hello"
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^\[[0-9]{2}:[0-9]{2}:[0-9]{2}\]\ hello$ ]]
}

@test "wait_for_port gives up with a message when the probe never succeeds" {
    cat > "$MOCK_BIN/timeout" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
    chmod +x "$MOCK_BIN/timeout"

    run wait_for_port "127.0.0.1" "1" 2
    [ "$status" -eq 1 ]
    [[ "$output" == *"gave up after 2 attempts"* ]]
}

@test "wait_for_healthy exits 0 once docker reports healthy" {
    cat > "$MOCK_BIN/docker" <<'EOF'
#!/usr/bin/env bash
echo healthy
EOF
    chmod +x "$MOCK_BIN/docker"

    run wait_for_healthy "mock-container" 2
    [ "$status" -eq 0 ]
    [[ "$output" == *"is healthy"* ]]
}

@test "wait_for_healthy exits 1 when docker reports unhealthy" {
    cat > "$MOCK_BIN/docker" <<'EOF'
#!/usr/bin/env bash
echo unhealthy
EOF
    chmod +x "$MOCK_BIN/docker"

    run wait_for_healthy "mock-container" 2
    [ "$status" -eq 1 ]
    [[ "$output" == *"reported unhealthy"* ]]
}
