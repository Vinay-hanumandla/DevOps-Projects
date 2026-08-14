#!/usr/bin/env bash
# last_verified: 2026-08-14 · git n/a
# verify-release.sh: prove the release workflow end-to-end in a disposable repo.
# Creates a scratch repo under mktemp, applies a minor bump, and fails the run
# unless the expected tag v0.2.0 exists. Leaves no trace on the host.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

git init -q "$TMP_DIR"
git -C "$TMP_DIR" config user.email "verify@example.com"
git -C "$TMP_DIR" config user.name "Release Verifier"

mkdir -p "$TMP_DIR/lib" "$TMP_DIR/scripts"
cp "$ROOT/lib/common.sh" "$TMP_DIR/lib/"
cp "$ROOT/scripts/release.sh" "$TMP_DIR/scripts/"

printf '0.1.0\n' > "$TMP_DIR/VERSION"
git -C "$TMP_DIR" add VERSION lib/ scripts/
git -C "$TMP_DIR" commit -qm "chore: scaffold release workflow"

bash "$TMP_DIR/scripts/release.sh" minor

EXPECTED="v0.2.0"
FOUND="$(git -C "$TMP_DIR" tag --list "v*")"
if [ "$FOUND" = "$EXPECTED" ]; then
    printf 'PASS: release minor produced %s\n' "$EXPECTED"
else
    printf 'FAIL: expected tag %s, got %q\n' "$EXPECTED" "$FOUND" >&2
    exit 1
fi