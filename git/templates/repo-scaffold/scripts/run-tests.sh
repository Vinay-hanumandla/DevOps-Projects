#!/usr/bin/env bash
# last_verified: 2026-10-15 · git n/a
# run-tests.sh — self-tests for the repo-scaffold template.
#
# What it checks:
#   1. syntax — `bash -n` parses every script and hook.
#   2. commit-msg hook — accepts a conventional message, rejects a
#      non-conventional message and an empty message.
#   3. changelog generator idempotency — running scripts/update-changelog.sh
#      twice over the same commit range leaves a scratch copy of the
#      changelog byte-identical (the contract README.md documents).
#
# Prerequisites: git, bash, awk, mktemp. Invoked as `./scripts/run-tests.sh`
# from the repository root, or via `make test`.
# Exit status: 0 when every check passes, 1 otherwise.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

pass() { printf 'PASS: %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; failures=$((failures + 1)); }

MSG="$(mktemp)"
SCRATCH_DIR="$(mktemp -d)"
SCRATCH="$SCRATCH_DIR/CHANGELOG.md"
trap 'rm -f "$MSG"; rm -rf "$SCRATCH_DIR"' EXIT

# 1. Every script and hook must at least parse.
for f in "$ROOT"/scripts/*.sh "$ROOT"/hooks/pre-commit "$ROOT"/hooks/commit-msg; do
    if bash -n "$f"; then
        pass "bash -n ${f##*/}"
    else
        fail "bash -n ${f##*/}"
    fi
done

# 2. The commit-msg hook enforces the conventional-commit format.
printf 'feat(api): add endpoint\n' >"$MSG"
if "$ROOT/hooks/commit-msg" "$MSG" >/dev/null 2>&1; then
    pass "commit-msg accepts a conventional message"
else
    fail "commit-msg rejects a conventional message"
fi

printf 'wip stuff\n' >"$MSG"
if "$ROOT/hooks/commit-msg" "$MSG" >/dev/null 2>&1; then
    fail "commit-msg accepts a non-conventional message"
else
    pass "commit-msg rejects a non-conventional message"
fi

: >"$MSG"
if "$ROOT/hooks/commit-msg" "$MSG" >/dev/null 2>&1; then
    fail "commit-msg accepts an empty message"
else
    pass "commit-msg rejects an empty message"
fi

# 3. The changelog generator must be idempotent over a scratch copy, so the
# workflow that commits its output never sees phantom diffs.
if ! git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
    fail "not inside a git repository; cannot exercise the changelog generator"
else
    cp "$ROOT/CHANGELOG.md" "$SCRATCH"
    if (cd "$ROOT" && CHANGELOG_FILE="$SCRATCH" bash scripts/update-changelog.sh >/dev/null 2>&1); then
        cp "$SCRATCH" "$SCRATCH_DIR/first.md"
        if (cd "$ROOT" && CHANGELOG_FILE="$SCRATCH" bash scripts/update-changelog.sh >/dev/null 2>&1); then
            if cmp -s "$SCRATCH_DIR/first.md" "$SCRATCH"; then
                pass "changelog generator is idempotent"
            else
                fail "changelog generator changed output on the second run"
            fi
        else
            fail "changelog generator errored on the second run"
        fi
    else
        fail "changelog generator errored on the first run"
    fi
fi

if [ "$failures" -ne 0 ]; then
    printf '%d check(s) failed\n' "$failures" >&2
    exit 1
fi

printf 'All scaffold self-tests passed.\n'
