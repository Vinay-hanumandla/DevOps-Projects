#!/usr/bin/env bash
# last_verified: 2026-07-27 · Bash 5.2.37

# This is the companion hello.sh for the Bash primer (0000-primer-bash.md).
# The primer shows a tiny example with a variable and an if check.
# This script expands on that by looping over arguments so you can
# greet more than one person from the command line.

name="${1:-world}"

echo "Hello, $name!"

if [ "$name" = "world" ]; then
  echo "Default greeting used — pass a name as an argument to customize it."
fi