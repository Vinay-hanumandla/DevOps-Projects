#!/usr/bin/env bash
# last_verified: 2026-07-25 · n/a

# Practice: Network connectivity, DNS, and port inspection
# I built this to test basic networking from a fresh Linux box —
# pinging, resolving DNS, checking open ports, and tracing routes.
# DevOps role: these are the commands I reach for when a service
# "just won't connect" and I need to figure out why.

set -u

TARGETS=("google.com" "github.com" "1.1.1.1")
REPORT=""

echo "=== Network connectivity check ==="
echo ""

# --- Ping test ---
# ping sends ICMP echo requests. If the host responds, we know
# the network path is up at L3. -c 1 = one packet, -W 3 = 3s timeout.
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
# dig gives the cleanest output. I fall back to host or getent
# if dig isn't installed (some minimal containers don't have it).
echo "--- DNS resolution ---"
for target in "${TARGETS[@]}"; do
    IP=$(dig +short "$target" 2>/dev/null | head -1)
    if [ -n "$IP" ]; then
        echo "  ✓ $target resolves to $IP"
    else
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
# /dev/tcp is a Bash-specific virtual file — no external tools needed.
# I'm checking HTTP(80) and HTTPS(443) to see if the remote service
# is actually listening.
echo "--- Port connectivity (HTTP/80 and HTTPS/443) ---"
for target in google.com github.com; do
    for port in 80 443; do
        timeout 3 bash -c "echo >/dev/tcp/$target/$port" 2>/dev/null && \
            echo "  ✓ $target:$port is open" || \
            echo "  ✗ $target:$port closed or filtered"
    done
done

echo ""

# --- Traceroute ---
# traceroute shows every hop between me and the target — useful
# when a connection is slow and I want to find where the delay is.
echo "--- Route tracing ---"
if command -v traceroute &>/dev/null; then
    for target in google.com github.com; do
        echo "  Tracing route to $target (first 5 hops)..."
        traceroute -m 5 "$target" 2>&1 | head -6
    done
else
    # tracepath is lighter and often available when traceroute isn't
    if command -v tracepath &>/dev/null; then
        for target in google.com github.com; do
            tracepath -m 5 "$target" 2>/dev/null | head -6
        done
    else
        echo "  (neither traceroute nor tracepath available)"
    fi
fi

echo ""

# --- Local listening ports ---
# ss is the modern replacement for netstat. I run it to see what
# services are actually listening on this machine.
echo "--- Local listening ports ---"
if command -v ss &>/dev/null; then
    ss -tlnp 2>/dev/null || echo "  (need root for process names)"
else
    netstat -tlnp 2>/dev/null || echo "  (neither ss nor netstat available)"
fi

echo ""
echo "=== Done ==="
echo "Summary: $REPORT"
