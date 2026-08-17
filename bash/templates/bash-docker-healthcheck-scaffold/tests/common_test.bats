#!/usr/bin/env bats
# last_verified: 2026-08-17 · bash 5.3

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

@test "wait_for_healthy logs starting state and continues polling" {
    cat > "$MOCK_BIN/docker" <<'EOF'
#!/usr/bin/env bash
if [[ ! -f "$MOCK_STATE" ]]; then
    echo starting > "$MOCK_STATE"
    echo starting
else
    echo healthy
fi
EOF
    chmod +x "$MOCK_BIN/docker"
    export MOCK_STATE="$(mktemp)"

    run wait_for_healthy "mock-container" 3
    [ "$status" -eq 0 ]
    [[ "$output" == *"is healthy"* ]]
    [[ "$output" == *"healthcheck is starting"* ]]
}

@test "wait_for_healthy exits 1 when container has no healthcheck" {
    cat > "$MOCK_BIN/docker" <<'EOF'
#!/usr/bin/env bash
echo ""
EOF
    chmod +x "$MOCK_BIN/docker"

    run wait_for_healthy "no-hc-container" 2
    [ "$status" -eq 1 ]
    [[ "$output" == *"no healthcheck defined"* ]]
}

@test "wait_for_healthy exits 1 on unexpected status" {
    cat > "$MOCK_BIN/docker" <<'EOF'
#!/usr/bin/env bash
echo "paused"
EOF
    chmod +x "$MOCK_BIN/docker"

    run wait_for_healthy "paused-container" 2
    [ "$status" -eq 1 ]
    [[ "$output" == *"unexpected status: paused"* ]]
}
