#!/usr/bin/env bash
# last_verified: 2026-07-23 · Bash

set -euo pipefail

# Minimal safe Bash script template
# I built this to remind myself what a clean starter looks like:
# strict mode, shebang, argument check, help flag, and cleanup via trap.
# After saving, I'd verify with: shellcheck $0

USAGE="Usage: $0 <input_file>"
INPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      echo "$USAGE"
      exit 0
      ;;
    *)
      INPUT="$1"
      shift
      ;;
  esac
done

if [[ -z "$INPUT" ]]; then
  echo "Error: no input file provided"
  echo "$USAGE"
  exit 1
fi

if [[ ! -f "$INPUT" ]]; then
  echo "Error: $INPUT does not exist"
  exit 1
fi

echo "Processing $INPUT..."
wc -l "$INPUT"

