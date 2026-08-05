#!/usr/bin/env bash
# last_verified: 2026-08-05 · bash n/a

# Practice: network interface and routing inspection
# I wrote this to learn how to inspect local network configuration on a Linux box —
# listing interfaces, their IPs, the routing table, and the default gateway.
# DevOps role: when a service can't be reached, checking the local interface and
# routing state is usually the first step before diving into firewalls or DNS.

set -u

echo "=== Network Interface and Routing Inspection ==="
echo ""

# --- Interfaces ---
# `ip -o link` shows every network interface (virtual and physical).
# I check which tool is available because minimal containers may only have
# one or the other.
echo "--- Network interfaces ---"
if command -v ip >/dev/null 2>&1; then
    ip -o link show | awk -F': ' '{print "  " $2 " -> " $9}'
elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig -a 2>/dev/null | grep -E '^[a-z]' | awk '{print "  " $1}'
else
    echo "  (neither 'ip' nor 'ifconfig' available)"
fi

echo ""

# --- IP addresses ---
# Show the IPv4 addresses assigned to each interface.
echo "--- IPv4 addresses ---"
if command -v ip >/dev/null 2>&1; then
    ip -o -4 addr show | awk '{print "  " $2 " -> " $4}'
elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig -a 2>/dev/null | grep 'inet ' | awk '{print "  " $1 " -> " $2}'
else
    echo "  (cannot determine IP addresses)"
fi

echo ""

# --- Routing table ---
# `ip route` shows the kernel routing table. The default route is what
# sends traffic to the outside world.
echo "--- Routing table ---"
if command -v ip >/dev/null 2>&1; then
    ip route show 2>/dev/null | while IFS= read -r line; do
        echo "  $line"
    done
elif command -v route >/dev/null 2>&1; then
    route -n 2>/dev/null | tail -n +3 | while IFS= read -r line; do
        echo "  $line"
    done
else
    echo "  (neither 'ip' nor 'route' available)"
fi

echo ""

# --- Default gateway ---
# The default route tells us which gateway handles everything not
# covered by a more specific route.
echo "--- Default gateway ---"
if command -v ip >/dev/null 2>&1; then
    DEFAULT=$(ip route show default 2>/dev/null)
    if [ -n "$DEFAULT" ]; then
        echo "  $DEFAULT"
    else
        echo "  (no default route found)"
    fi
elif command -v route >/dev/null 2>&1; then
    DEFAULT=$(route -n 2>/dev/null | grep '^0.0.0.0')
    if [ -n "$DEFAULT" ]; then
        echo "  $DEFAULT"
    else
        echo "  (no default gateway found)"
    fi
else
    echo "  (cannot determine default gateway)"
fi

echo ""

# --- Interface statistics ---
# `ip -s link` shows packet and byte counters for each interface — useful
# for seeing if traffic is actually flowing.
echo "--- Interface statistics ---"
if command -v ip >/dev/null 2>&1; then
    ip -s link show 2>/dev/null
elif command -v netstat >/dev/null 2>&1; then
    netstat -i 2>/dev/null
else
    echo "  (neither 'ip -s' nor 'netstat' available)"
fi

echo ""
echo "=== Done ==="