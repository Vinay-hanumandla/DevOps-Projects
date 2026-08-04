#!/usr/bin/env bash
# last_verified: 2026-08-04 · bash n/a

# Networking + Observability: automated network health check with structured output.
# This script combines Networking Fundamentals diagnostics (ping, DNS, port checks,
# traceroute) with Observability & Monitoring patterns (structured logging, exit-code
# aggregation, summary reporting) to produce a repeatable health-check artifact.
# DevOps role: run this from a cron job or CI step to continuously verify that
# critical endpoints are reachable and DNS/resolution paths are intact.

set -uo pipefail

TARGETS=("google.com" "github.com" "1.1.1.1")
PORTS=(80 443)
LOG_FILE=""
FAIL_COUNT=0
PASS_COUNT=0

usage() {
    echo "Usage: $0 [-l logfile] [-t target1,target2,...]"
    echo "  -l  Write structured results to logfile (JSON-lines)"
    echo "  -t  Comma-separated targets (default: google.com,github.com,1.1.1.1)"
}

while getopts "l:t:h" opt; do
    case "$opt" in
        l) LOG_FILE="$OPTARG" ;;
        t) IFS=',' read -r -a TARGETS <<< "$OPTARG" ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

log_json() {
    local timestamp target check status detail
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    target="$1"
    check="$2"
    status="$3"
    detail="${4:-}"
    if [ -n "$LOG_FILE" ]; then
        printf '{"timestamp":"%s","target":"%s","check":"%s","status":"%s","detail":"%s"}\n' \
            "$timestamp" "$target" "$check" "$status" "$detail" >> "$LOG_FILE"
    fi
}

run_check() {
    local target="$1"
    local check="$2"
    local cmd="$3"
    local result=""

    if eval "$cmd" >/tmp/_health_check_out 2>/tmp/_health_check_err; then
        result=$(cat /tmp/_health_check_out)
        log_json "$target" "$check" "pass" "$result"
        PASS_COUNT=$((PASS_COUNT + 1))
        echo "  ✓ $target — $check: $result"
    else
        local err
        err=$(cat /tmp/_health_check_err)
        log_json "$target" "$check" "fail" "$err"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo "  ✗ $target — $check: $err"
    fi
    rm -f /tmp/_health_check_out /tmp/_health_check_err
}

echo "=== Network Health Check ==="
echo "Targets: ${TARGETS[*]}"
echo "Ports: ${PORTS[*]}"
echo ""

# --- Ping tests ---
echo "--- Ping Tests ---"
for target in "${TARGETS[@]}"; do
    run_check "$target" "ping" "ping -c 1 -W 3 '$target'"
done

echo ""

# --- DNS resolution ---
echo "--- DNS Resolution ---"
for target in "${TARGETS[@]}"; do
    if [[ "$target" == 1.* || "$target" == 10.* || "$target" == 172.* || "$target" == 192.* ]]; then
        echo "  ⊘ $target — skipping DNS (IP address)"
        continue
    fi
    run_check "$target" "dns" "dig +short '$target' 2>/dev/null | head -1"
done

echo ""

# --- Port checks ---
echo "--- Port Checks ---"
for target in "${TARGETS[@]}"; do
    for port in "${PORTS[@]}"; do
        run_check "$target" "port:$port" "timeout 3 bash -c 'echo >/dev/tcp/$target/$port' 2>/dev/null"
    done
done

echo ""

# --- Traceroute ---
echo "--- Route Tracing ---"
for target in "${TARGETS[@]}"; do
    if command -v traceroute &>/dev/null; then
        run_check "$target" "traceroute" "traceroute -m 5 '$target' 2>&1 | head -6"
    elif command -v tracepath &>/dev/null; then
        run_check "$target" "tracepath" "tracepath -m 5 '$target' 2>/dev/null | head -6"
    else
        echo "  ⊘ $target — neither traceroute nor tracepath available"
        log_json "$target" "traceroute" "skip" "no traceroute or tracepath binary"
    fi
done

echo ""

# --- Summary ---
echo "=== Summary ==="
echo "Targets tested: ${#TARGETS[@]}"
echo "Checks passed: $PASS_COUNT"
echo "Checks failed: $FAIL_COUNT"

if [ -n "$LOG_FILE" ]; then
    echo "Structured log written to: $LOG_FILE"
fi

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "Result: DEGRADED ($FAIL_COUNT check(s) failed)"
    exit 1
else
    echo "Result: ALL CHECKS PASSED"
    exit 0
fi