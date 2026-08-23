#!/usr/bin/env bash
# last_verified: 2026-08-23 · bash n/a

# Practice: network interface and routing inspection
# I wrote this to practice inspecting local network configuration on Linux —
# checking interfaces, IPs, routing tables, DNS resolvers, and neighbor tables.
# DevOps use case: when a service can't reach another, these are the first
# commands to run before blaming the application.

set -u

echo "=== Network Interface and Routing Inspection Practice ==="
echo ""

# --- List all interfaces ---
echo "--- Network interfaces ---"
if command -v ip >/dev/null 2>&1; then
    ip -o link show | awk -F': ' '{printf "  %-12s state=%s\n", $2, $9}'
else
    echo "  (ip command not available)"
fi
echo ""

# --- IPv4 addresses per interface ---
echo "--- IPv4 addresses ---"
if command -v ip >/dev/null 2>&1; then
    ip -o -4 addr show | awk '{printf "  %-12s %s\n", $2, $4}'
else
    echo "  (cannot determine IPv4 addresses)"
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

# --- Default gateway ---
echo "--- Default gateway ---"
if command -v ip >/dev/null 2>&1; then
    DEFAULT=$(ip route show default 2>/dev/null)
    if [ -n "$DEFAULT" ]; then
        echo "  $DEFAULT"
    else
        echo "  (no default route)"
    fi
else
    echo "  (cannot determine default gateway)"
fi
echo ""

# --- DNS resolvers ---
echo "--- DNS resolvers ---"
if [ -f /etc/resolv.conf ]; then
    grep '^nameserver' /etc/resolv.conf | awk '{printf "  %s\n", $2}'
else
    echo "  (/etc/resolv.conf not found)"
fi
echo ""

# --- Neighbor table (ARP) ---
echo "--- Neighbor/ARP table ---"
if command -v ip >/dev/null 2>&1; then
    ip neigh show 2>/dev/null | while IFS= read -r line; do
        echo "  $line"
    done
else
    echo "  (ip neigh not available)"
fi
echo ""

# --- Interface statistics ---
echo "--- Interface statistics (packet/byte counters) ---"
if command -v ip >/dev/null 2>&1; then
    ip -s link show 2>/dev/null | while IFS= read -r line; do
        echo "  $line"
    done
else
    echo "  (ip -s not available)"
fi
echo ""

# --- TCP connection states ---
echo "--- TCP connection states ---"
if command -v ss >/dev/null 2>&1; then
    ss -tan | awk 'NR>1 {state[$1]++} END {for (s in state) printf "  %-12s %d\n", s, state[s]}'
else
    echo "  (ss not available)"
fi
echo ""

echo "=== Done ==="
