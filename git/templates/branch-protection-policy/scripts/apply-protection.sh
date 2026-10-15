#!/usr/bin/env bash
# last_verified: 2026-10-15 · git n/a
# apply-protection.sh: apply the version-controlled branch protection policy
# to every branch listed in policy/branch-protection.json. Validates the
# policy file first, skips branches that do not exist yet, and reads each
# policy back after applying it. Needs a credential with admin on the
# repository (export GH_TOKEN beforehand); usage: apply-protection.sh
# [--policy FILE] [--repo OWNER/REPO] [branch...]
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POLICY="$SCRIPT_DIR/../policy/branch-protection.json"
REPO=""
BRANCHES=()

while [ "$#" -gt 0 ]; do
    case "$1" in
        --policy) POLICY="$2"; shift 2 ;;
        --repo) REPO="$2"; shift 2 ;;
        -h|--help)
            sed -n '2,6p' "$0"
            echo "usage: $(basename "$0") [--policy FILE] [--repo OWNER/REPO] [branch...]"
            exit 0 ;;
        --*) echo "ERROR: unknown flag '$1'" >&2; exit 2 ;;
        *) BRANCHES+=("$1"); shift ;;
    esac
done

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || { echo "ERROR: required command '$1' not found" >&2; exit 2; }
}
require_cmd gh
require_cmd jq

[ -f "$POLICY" ] || { echo "ERROR: policy file not found: $POLICY" >&2; exit 2; }
jq -e 'type == "object" and (.branches | type == "object")' "$POLICY" >/dev/null \
    || { echo "ERROR: $POLICY must be a JSON object with a 'branches' object" >&2; exit 2; }
[ "$(jq -r '.branches | length' "$POLICY")" -gt 0 ] \
    || { echo "ERROR: $POLICY lists no branches under 'branches'" >&2; exit 2; }

if [ -z "$REPO" ]; then
    REPO="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"
    [ -n "$REPO" ] || { echo "ERROR: could not resolve the current repository; pass --repo OWNER/REPO" >&2; exit 1; }
fi

if [ "${#BRANCHES[@]}" -eq 0 ]; then
    mapfile -t BRANCHES < <(jq -r '.branches | keys[]' "$POLICY")
fi

for branch in "${BRANCHES[@]}"; do
    payload="$(jq -c --arg b "$branch" '.branches[$b] // empty' "$POLICY")"
    [ -n "$payload" ] || { echo "ERROR: branch '$branch' is not defined in $POLICY" >&2; exit 2; }
    if ! printf '%s' "$payload" | jq -e '.required_status_checks.contexts | type == "array"' >/dev/null; then
        echo "ERROR: branch '$branch': required_status_checks.contexts must be an array" >&2
        exit 2
    fi
    if [ "$(printf '%s' "$payload" | jq -r '.required_status_checks.contexts | length')" -eq 0 ]; then
        echo "WARN: branch '$branch': contexts is empty — reviews, history and deletion rules apply, but no status check is enforced until real check names are listed" >&2
    fi
    if ! gh api "repos/$REPO/branches/$branch" --silent >/dev/null 2>&1; then
        echo "WARN: branch '$branch' does not exist on $REPO — skipping" >&2
        continue
    fi
    # The endpoint replaces the whole policy, so the stored payload is sent
    # as-is: one PUT carries reviews, checks, signatures, linear history and
    # deletion rules together instead of several partial calls wiping each other.
    printf '%s' "$payload" | gh api -X PUT "repos/$REPO/branches/$branch/protection" --input - --silent
    echo "applied protection to $REPO/$branch"
    gh api "repos/$REPO/branches/$branch/protection" --jq '{
        status_checks: .required_status_checks.contexts,
        reviews: .required_pull_request_reviews.required_approving_review_count,
        linear_history: .required_linear_history.enabled
    }'
done
