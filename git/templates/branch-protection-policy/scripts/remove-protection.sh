#!/usr/bin/env bash
# last_verified: 2026-10-15 · git n/a
# remove-protection.sh: rollback helper that deletes the protection policy
# from the given branches. Branch names are always explicit arguments — the
# script never derives them from the policy file, so removing a branch from
# the JSON cannot silently unprotect it. Asks for confirmation unless --yes
# is passed. usage: remove-protection.sh [--repo OWNER/REPO] [--yes] branch...
set -Eeuo pipefail

REPO=""
ASSUME_YES=false
BRANCHES=()

while [ "$#" -gt 0 ]; do
    case "$1" in
        --repo) REPO="$2"; shift 2 ;;
        --yes) ASSUME_YES=true; shift ;;
        -h|--help)
            sed -n '2,6p' "$0"
            echo "usage: $(basename "$0") [--repo OWNER/REPO] [--yes] branch..."
            exit 0 ;;
        --*) echo "ERROR: unknown flag '$1'" >&2; exit 2 ;;
        *) BRANCHES+=("$1"); shift ;;
    esac
done

[ "${#BRANCHES[@]}" -gt 0 ] || { echo "ERROR: pass at least one branch name to unprotect" >&2; exit 2; }

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || { echo "ERROR: required command '$1' not found" >&2; exit 2; }
}
require_cmd gh

if [ -z "$REPO" ]; then
    REPO="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"
    [ -n "$REPO" ] || { echo "ERROR: could not resolve the current repository; pass --repo OWNER/REPO" >&2; exit 1; }
fi

if [ "$ASSUME_YES" != true ]; then
    echo "About to REMOVE branch protection from ${#BRANCHES[@]} branch(es) on $REPO: ${BRANCHES[*]}"
    printf 'Type the repository name to confirm: '
    read -r answer
    [ "$answer" = "$REPO" ] || { echo "aborted: confirmation did not match" >&2; exit 1; }
fi

for branch in "${BRANCHES[@]}"; do
    if gh api -X DELETE "repos/$REPO/branches/$branch/protection" --silent >/dev/null 2>&1; then
        echo "removed protection from $REPO/$branch"
    else
        echo "WARN: no protection to remove on $REPO/$branch (already unprotected or branch missing)" >&2
    fi
done
