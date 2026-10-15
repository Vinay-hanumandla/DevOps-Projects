#!/usr/bin/env bash
# last_verified: 2026-10-15 · git n/a
# verify-protection.sh: compare the live branch protection on each policy
# branch against policy/branch-protection.json and report drift field by
# field. Exits 0 when every listed branch matches, 1 on any drift or on a
# branch with no protection at all. Read-only: never changes the policy.
# usage: verify-protection.sh [--policy FILE] [--repo OWNER/REPO] [branch...]
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

if [ -z "$REPO" ]; then
    REPO="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"
    [ -n "$REPO" ] || { echo "ERROR: could not resolve the current repository; pass --repo OWNER/REPO" >&2; exit 1; }
fi

if [ "${#BRANCHES[@]}" -eq 0 ]; then
    mapfile -t BRANCHES < <(jq -r '.branches | keys[]' "$POLICY")
fi

# Field paths compared, in live-response form on the left and policy form
# on the right. Kept to the paths the apply step reads back so the two
# scripts cannot disagree about what "matching" means.
FIELDS="required_status_checks.strict
required_status_checks.contexts
enforce_admins.enabled
required_pull_request_reviews.required_approving_review_count
required_pull_request_reviews.dismiss_stale_reviews
required_signatures.enabled
required_linear_history.enabled
allow_force_pushes.enabled
allow_deletions.enabled"

failures=0
for branch in "${BRANCHES[@]}"; do
    expected="$(jq -c --arg b "$branch" '.branches[$b] // empty' "$POLICY")"
    [ -n "$expected" ] || { echo "ERROR: branch '$branch' is not defined in $POLICY" >&2; exit 2; }
    # The apply call sends these four rules as bare booleans, but the read
    # endpoint returns each wrapped as {"enabled": ...}. Normalize the policy
    # side to the read form so the comparison below cannot disagree with
    # what apply just wrote.
    expected="$(printf '%s' "$expected" | jq -c '
        (.enforce_admins | select(type == "boolean")) |= {enabled: .} |
        (.required_linear_history | select(type == "boolean")) |= {enabled: .} |
        (.allow_force_pushes | select(type == "boolean")) |= {enabled: .} |
        (.allow_deletions | select(type == "boolean")) |= {enabled: .}')" 
    live="$(gh api "repos/$REPO/branches/$branch/protection" 2>/dev/null)" || {
        echo "DRIFT: $REPO/$branch has no protection policy at all" >&2
        failures=$((failures + 1))
        continue
    }
    while IFS= read -r field; do
        want="$(printf '%s' "$expected" | jq -c --arg f "$field" 'getpath($f | split("."))')"
        got="$(printf '%s' "$live" | jq -c --arg f "$field" 'getpath($f | split("."))')"
        if [ "$want" = "$got" ]; then
            echo "OK: $branch $field = $got"
        else
            echo "DRIFT: $branch $field: policy has $want, live has $got" >&2
            failures=$((failures + 1))
        fi
    done <<< "$FIELDS"
done

if [ "$failures" -gt 0 ]; then
    echo "FAIL: $failures drifted field(s); re-run apply-protection.sh to converge" >&2
    exit 1
fi
echo "PASS: all policy branches match $POLICY"
