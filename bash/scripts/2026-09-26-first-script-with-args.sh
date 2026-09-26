#!/usr/bin/env bash
# last_verified: 2026-09-26 · Bash n/a
# Tried the "what next" idea from my install note:
# take an argument and check if a file exists.

echo "Hello, ${1:-stranger}!"
# not sure why :- works here yet, copied the shape from my hello script

if [ -f "$1" ]; then
  echo "$1 exists"
else
  echo "$1 not found"
fi
