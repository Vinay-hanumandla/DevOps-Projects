#!/usr/bin/env bash
# last_verified: 2026-07-21 - infrastructure-as-code-principles L2
#
# Track file state to decide whether infrastructure needs applying.
#
# IaC idempotency means running the same script twice produces the same
# result — the second run should be a no-op if nothing changed.
# This script saves a checksum of a "desired state" file and compares
# it with the current state on subsequent runs.

STATE_DIR="${HOME}/.iac-state"
mkdir -p "$STATE_DIR"

DESIRED="$1"
if [ -z "$DESIRED" ]; then
    echo "Usage: $0 <desired-state-file>"
    exit 1
fi

# Compute a hash of the desired state so we can detect drift later.
# sha256sum is available on every Linux system.
CURRENT_HASH=$(sha256sum "$DESIRED" | awk '{print $1}')

STATE_FILE="${STATE_DIR}/$(basename "$DESIRED").hash"

if [ -f "$STATE_FILE" ]; then
    PREV_HASH=$(cat "$STATE_FILE")
    if [ "$CURRENT_HASH" = "$PREV_HASH" ]; then
        echo "Idempotent — state hasn't changed. Nothing to do."
        exit 0
    else
        echo "State changed — applying update..."
    fi
else
    echo "First run — no previous state recorded. Applying..."
fi

# Record the new hash so the next run knows whether to apply again.
echo "$CURRENT_HASH" > "$STATE_FILE"
echo "Done. State hash saved to $STATE_FILE"
