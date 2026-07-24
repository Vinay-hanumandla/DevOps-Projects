#!/usr/bin/env bash
# last_verified: 2026-07-24 · Networking Fundamentals L2

# Practice: Network connectivity, DNS, and port inspection
# I built this to test basic networking from a fresh Linux box —
# pinging, resolving DNS, checking open ports, and tracing a route.

set -u

TARGETS=("google.com" "github.com" "1.1.1.1")
REPORT=""

echo "=== Network connectivity check ==="
echo ""

# --- Ping test ---
echo "--- Ping tests ---"
for target in "${TARGETS[@]}"; do
    if ping -c 1 -W 3 "$target" &>/dev/null; then
        echo "  ✓ $target is reachable"
        REPORT="${REPORT}ping:${target}=reachable "
    else
        echo "  ✗ $target is NOT reachable"
        REPORT="${REPORT}ping:${target}=unreachable "
    fi
done

echo ""

# --- DNS resolution ---
echo "--- DNS resolution ---"
for target in "${TARGETS[@]}"; do
    IP=$(dig +short "$target" 2>/dev/null | head -1)
    if [ -n "$IP" ]; then
        echo "  ✓ $target resolves to $IP"
    else
        # fallback: try host or getent
        IP=$(host "$target" 2>/dev/null | awk '/has address/ {print $4}' | head -1)
        if [ -n "$IP" ]; then
            echo "  ✓ $target resolves to $IP (via host)"
        else
            echo "  ✗ $target DNS lookup failed"
        fi
    fi
done

echo ""

# --- Port check using /dev/tcp (Bash built-in) ---
echo "--- Port connectivity (HTTP/80 and HTTPS/443) ---"
for target in google.com github.com; do
    for port in 80 443; do
        timeout 3 bash -c "echo >/dev/tcp/$target/$port" 2>/dev/null && \
            echo "  ✓ $target:$port is open" || \
            echo "  ✗ $target:$port closed or filtered"
    done
done

echo ""

# --- Local listening ports ---
echo "--- Local listening ports ---"
ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null || echo "  (neither ss nor netstat available)"

echo ""
echo "=== Done ==="
