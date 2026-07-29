#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="${SCRIPT_DIR}/.."
GIT_HOOKS_DIR="${HOOKS_DIR}/.git/hooks"

if ! command -v git &>/dev/null; then
    echo "Error: git is not installed" >&2
    exit 1
fi

for hook in "${HOOKS_DIR}"/*.sh; do
    [ -f "$hook" ] || continue
    name="$(basename "$hook")"
    ln -sf "$(realpath "$hook")" "${GIT_HOOKS_DIR}/${name}"
    echo "Installed hook: ${name}"
done