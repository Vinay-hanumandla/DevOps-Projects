#!/usr/bin/env bash
# last_verified: 2026-09-16 · bash n/a
#
# Practice: hands-on network interface and routing inspection.
# I wrote this to drill the inspection commands I'll actually reach for when a
# service can't be reached — interfaces, IPs, routing, DNS, and a quick TCP
# connectivity probe. DevOps role: run this on the box that's failing before
# you start guessing about firewalls.

set -u

TARGET="${1:-localhost}"
PORT="${2:-80}"

echo "=== Network Interface & Routing Inspection ==="
echo "Target for connectivity check: ${TARGET}:${PORT}"
echo ""

# --- Interfaces ---
echo "--- Network interfaces ---"
if command -v ip >/dev/null 2>&1; then
    ip -o link show | awk -F': ' '{print "  " $2 " -> state=" $9}'
elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig -a 2>/dev/null | grep -E '^[a-z]' | awk '{print "  " $1}'
else
    echo "  (neither 'ip' nor 'ifconfig' available)"
fi
echo ""

# --- IPv4 addresses ---
echo "--- IPv4 addresses ---"
if command -v ip >/dev/null 2>&1; then
    ip -o -4 addr show | awk '{print "  " $2 " -> " $4}'
elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig -a 2>/dev/null | grep 'inet ' | awk '{print "  " $1 " -> " $2}'
else
    echo "  (cannot determine IP addresses)"
fi
echo ""

# --- Routing table + default gateway ---
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

# --- DNS resolvers ---
echo "--- DNS resolvers ---"
if [ -f /etc/resolv.conf ]; then
    grep '^nameserver' /etc/resolv.conf | awk '{printf "  %s\n", $2}'
else
    echo "  (/etc/resolv.conf not found)"
fi
echo ""

# --- TCP connectivity probe ---
echo "--- TCP connectivity probe to ${TARGET}:${PORT} ---"
if command -v nc >/dev/null 2>&1; then
    if nc -z -w 3 "${TARGET}" "${PORT}" 2>/dev/null; then
        echo "  OPEN: ${TARGET}:${PORT}"
    else
        echo "  CLOSED/FILTERED: ${TARGET}:${PORT}"
    fi
elif command -v bash >/dev/null 2>&1; then
    # bash /dev/tcp is a builtin — works even when nc is missing
    if (exec 3<>"/dev/tcp/${TARGET}/${PORT}") 2>/dev/null; then
        echo "  OPEN: ${TARGET}:${PORT}"
        exec 3>&- 3<&- 2>/dev/null
    else
        echo "  CLOSED/FILTERED: ${TARGET}:${PORT}"
    fi
else
    echo "  (no TCP probe available)"
fi
echo ""

echo "=== Done ==="