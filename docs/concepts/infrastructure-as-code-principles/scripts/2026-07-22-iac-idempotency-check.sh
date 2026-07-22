#!/usr/bin/env bash
# last_verified: 2026-07-22 · n/a
#
# Track multiple desired-state files and detect drift.
# I wrote this to practice idempotent IaC: running the same script twice
# with the same inputs should be a no-op the second time around.
#

set -e
STATE_DIR="${HOME}/.iac-state/manifests"
mkdir -p "$STATE_DIR"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <desired-file>..."
    echo "  Pass one or more paths to desired-state files to check."
    exit 1
fi

CHANGED=0

for DESIRED in "$@"; do
    if [ ! -f "$DESIRED" ]; then
        echo "  [SKIP] $(basename "$DESIRED") — file not found"
        continue
    fi

    CURRENT_HASH=$(sha256sum "$DESIRED" | cut -d' ' -f1)
    STATE_FILE="${STATE_DIR}/$(basename "$DESIRED").hash"

    if [ -f "$STATE_FILE" ]; then
        PREV_HASH=$(cat "$STATE_FILE")
        if [ "$CURRENT_HASH" = "$PREV_HASH" ]; then
            echo "  [OK]   $(basename "$DESIRED") — convergent"
            continue
        else
            echo "  [CHG]  $(basename "$DESIRED") — drift detected, needs apply"
        fi
    else
        echo "  [NEW]  $(basename "$DESIRED") — first run, needs apply"
    fi

    echo "$CURRENT_HASH" > "$STATE_FILE"
    CHANGED=$((CHANGED + 1))
done

echo ""
if [ "$CHANGED" -eq 0 ]; then
    echo "All files convergent — no action required."
else
    echo "$CHANGED file(s) were applied or updated."
fi
