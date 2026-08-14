#!/usr/bin/env bash
# last_verified: 2026-08-14 · git n/a
# Sourced helper library for the release workflow. Defines functions and
# readonly constants only; never executes on its own. Source it at the top of
# a script with: source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
set -Eeuo pipefail

# repo_root: print the absolute path of the scaffold root (parent of lib/).
repo_root() {
    local dir
    dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    printf '%s\n' "$dir"
}

# current_version: read the <root>/VERSION file, defaulting to 0.0.0.
current_version() {
    local file="$1"
    if [ -f "$file" ]; then
        cat "$file"
    else
        printf '%s\n' "0.0.0"
    fi
}

# next_version: bump a semver string by one step (patch|minor|major).
# usage: next_version <current> <step>
next_version() {
    local current="$1" step="$2"
    local major minor patch
    major="${current%%.*}"
    rest="${current#*.}"
    minor="${rest%%.*}"
    rest="${rest#*.}"
    patch="${rest%%.*}"

    case "$step" in
        patch) patch=$((patch + 1)) ;;
        minor) minor=$((minor + 1)); patch=0 ;;
        major) major=$((major + 1)); minor=0; patch=0 ;;
        *) printf 'error: unknown release step: %s\n' "$step" >&2; return 1 ;;
    esac
    printf '%s.%s.%s\n' "$major" "$minor" "$patch"
}

# require_git: fail with a clear message when git is not on PATH.
require_git() {
    if ! command -v git >/dev/null 2>&1; then
        printf 'error: git is required but not installed\n' >&2
        return 1
    fi
}

# assert_clean_tree: refuse to release when the working tree is dirty.
assert_clean_tree() {
    if [ -n "$(git status --porcelain)" ]; then
        printf 'error: working tree is not clean\n' >&2
        return 1
    fi
}