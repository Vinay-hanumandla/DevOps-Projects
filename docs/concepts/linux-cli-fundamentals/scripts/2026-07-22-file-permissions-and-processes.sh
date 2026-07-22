#!/usr/bin/env bash
# last_verified: 2026-07-22 · Linux & CLI Fundamentals L2

# Practice: Linux file permissions and process management
# I wrote this to get comfortable with chmod, chown, ps, kill, and umask.

set -u

echo "=== 1. Creating a test directory ==="
TESTDIR="/tmp/permissions-lab-$$"
mkdir -p "$TESTDIR"
cd "$TESTDIR" || exit 1

echo "Working in $TESTDIR"

echo ""
echo "=== 2. Creating files with different permissions ==="
touch public.txt private.sh secret.key
chmod 644 public.txt
chmod 700 private.sh
chmod 600 secret.key

echo "File listing:"
ls -la

echo ""
echo "=== 3. Reading current umask ==="
CURRENT_UMASK=$(umask)
echo "Current umask: $CURRENT_UMASK"

echo ""
echo "=== 4. Creating a file with restricted default perms ==="
umask 077
touch restricted.txt
umask "$CURRENT_UMASK"
ls -la restricted.txt
echo "(umask restored to $CURRENT_UMASK)"

echo ""
echo "=== 5. Process management demo ==="
# Start a sleep process in the background
sleep 30 &
SLEEP_PID=$!
echo "Started sleep in background (PID: $SLEEP_PID)"

# Check it's running
ps -p $SLEEP_PID -o pid,state,comm --no-headers && echo "Process $SLEEP_PID is running"

# Kill it
kill $SLEEP_PID 2>/dev/null || true
sleep 0.5
ps -p $SLEEP_PID -o pid,state,comm --no-headers 2>/dev/null && echo "Still running (unexpected)" || echo "Process $SLEEP_PID terminated"

echo ""
echo "=== 6. Cleanup ==="
rm -rf "$TESTDIR"
echo "Removed $TESTDIR"

echo ""
echo "Done."
