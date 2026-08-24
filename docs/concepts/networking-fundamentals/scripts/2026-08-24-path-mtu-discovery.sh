#!/usr/bin/env bash
# last_verified: 2026-08-24 · bash n/a

# Practice: Path MTU discovery — finding the largest packet a network path carries.
# I was debugging a slow VPN tunnel and learned oversized packets get fragmented
# or silently dropped. This uses ping with the Don't-Fragment (DF) bit to binary-
# search for the max payload that traverses the path without fragmentation.
# DevOps role: Docker bridge networks and VPNs often advertise a smaller MTU than
# 1500; checking path MTU explains why some remote hosts are slow or timing out.

set -u

DEST="${1:-google.com}"
echo "=== Path MTU Discovery — target: $DEST ==="

# Step 1: find the local interface and its MTU for the route to the destination.
# `ip route get` shows which interface the kernel would use, so we can tell
# whether the MTU we discover is the local link or a remote path limitation.
echo "--- Local interface MTU ---"
DEV=$(ip route get "$DEST" 2>/dev/null | grep -oP 'dev \K\S+' | head -1)
if [ -n "$DEV" ]; then
    MTU=$(ip -d link show "$DEV" 2>/dev/null | grep -oP 'mtu \K\d+')
    echo "  Interface: $DEV, MTU: ${MTU:-unknown}"
fi

# Step 2: binary search with the DF bit. -M do sets Don't-Fragment; if the
# payload is too big, the packet is dropped and ping reports 100% loss.
# We search payloads from 0 to 1472 (1500 minus 28-byte IP+ICMP header).
echo "--- Path MTU (DF-bit binary search) ---"
lo=0; hi=1472; best=0
while [ "$lo" -le "$hi" ]; do
    mid=$(( (lo + hi) / 2 ))
    if ping -M "do" -c 1 -W 1 -s "$mid" "$DEST" >/dev/null 2>&1; then
        best="$mid"; lo=$(( mid + 1 ))
    else
        hi=$(( mid - 1 ))
    fi
done

# The max payload + 28 bytes = the actual path MTU in bytes.
if [ "$best" -gt 0 ]; then
    echo "  Path MTU ≈ $(( best + 28 )) bytes"
else
    echo "  Could not determine path MTU (ping failed to all sizes)"
fi
echo ""
echo "If path MTU < 1500, a tunnel or VPN is likely fragmenting packets."
echo "=== Done ==="
