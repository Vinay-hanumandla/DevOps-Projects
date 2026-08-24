#!/usr/bin/env bash
# last_verified: 2026-08-24 · bash n/a

# Practice: network interface and routing inspection
# I wrote this after getting confused about why containers couldn't reach each
# other on a custom bridge. Turns out the routing table and DNS config were the
# culprit — not the app. This script walks through the same checks I'd run
# during a real networking debug session.

set -u

echo "=== Network Interface and Routing Inspection ==="
echo ""

# --- Show all interfaces with state ---
echo "--- Interfaces ---"
if command -v ip >/dev/null 2>&1; then
    ip -o link show | awk -F': ' '{printf "  %-14s state=%s\n", $2, $9}'
else
    echo "  (ip command not available)"
fi
echo ""

# --- IPv4 addresses ---
echo "--- IPv4 addresses ---"
if command -v ip >/dev/null 2>&1; then
    ip -o -4 addr show | awk '{printf "  %-14s %s\n", $2, $4}'
else
    echo "  (cannot determine IPv4 addresses)"
fi
echo ""

# --- Default route ---
echo "--- Default route ---"
if command -v ip >/dev/null 2>&1; then
    DEFAULT=$(ip route show default 2>/dev/null)
    if [ -n "$DEFAULT" ]; then
        echo "  $DEFAULT"
    else
        echo "  (no default route)"
    fi
else
    echo "  (ip route not available)"
fi
echo ""

# --- Full routing table ---
echo "--- Routing table ---"
if command -v ip >/dev/null 2>&1; then
    ip route show | while IFS= read -r line; do
        echo "  $line"
    done
else
    echo "  (ip route not available)"
fi
echo ""

# --- DNS resolvers from /etc/resolv.conf ---
echo "--- DNS resolvers ---"
if [ -f /etc/resolv.conf ]; then
    grep '^nameserver' /etc/resolv.conf | awk '{printf "  %s\n", $2}'
else
    echo "  (/etc/resolv.conf not found)"
fi
echo ""

# --- Neighbor/ARP table ---
echo "--- Neighbor table ---"
if command -v ip >/dev/null 2>&1; then
    ip neigh show 2>/dev/null | while IFS= read -r line; do
        echo "  $line"
    done
else
    echo "  (ip neigh not available)"
fi
echo ""

# --- Quick port check (useful when debugging service reachability) ---
echo "--- Listening ports ---"
if command -v ss >/dev/null 2>&1; then
    ss -tlnp 2>/dev/null | awk 'NR>1 {printf "  %s %s\n", $4, $6}'
else
    echo "  (ss not available)"
fi
echo ""

# --- TCP connection summary ---
echo "--- TCP connection states ---"
if command -v ss >/dev/null 2>&1; then
    ss -tan | awk 'NR>1 {state[$1]++} END {for (s in state) printf "  %-12s %d\n", s, state[s]}'
else
    echo "  (ss not available)"
fi
echo ""

# --- Interface error/drop counters ---
echo "--- Interface stats (errors/drops) ---"
if command -v ip >/dev/null 2>&1; then
    ip -s link show 2>/dev/null | grep -E '^\s+(RX|TX)' | while IFS= read -r line; do
        echo "  $line"
    done
else
    echo "  (ip -s not available)"
fi
echo ""

echo "=== Done ==="
echo ""
echo "What I'd try next: check DNS resolution with 'dig' or 'nslookup',"
echo "then test specific ports with 'nc -zv <host> <port>'."
