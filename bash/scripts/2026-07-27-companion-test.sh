#!/usr/bin/env bash
# last_verified: 2026-07-27 · Bash 5.2.37

# This is the companion test.sh for the Bash install notes
# (2026-07-18-install-bash-and-first-script.md).
# The install notes show a minimal test.sh that prints "Script ran OK".
# This version adds a file-existence check and an exit-code assertion
# so you can use it to verify prerequisites before running a bigger script.

target_file="${1:-/usr/bin/bash}"

if [ -f "$target_file" ]; then
  echo "Test passed: $target_file exists."
else
  echo "Test FAILED: $target_file not found." >&2
  exit 1
fi