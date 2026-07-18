#!/usr/bin/env bash
# last_verified: 2026-07-18 · Bash 5.2.37

name="Bash"
echo "Hello, $name!"

if [ -n "$1" ]; then
  echo "You passed an argument: $1"
else
  echo "No argument passed"
fi
