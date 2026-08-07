#!/usr/bin/env bash
# last_verified: 2026-08-07 · version-control-git-workflow n/a

# I wrote this to practice the git workflow habits from the concept primer:
# checking repo state, reviewing recent commits, and seeing where my
# branch sits relative to its upstream. Each step is read-only so the
# whole script is safe to re-run.

REPO_DIR="${1:-$(pwd)}"
cd "$REPO_DIR" || { echo "cannot cd to $REPO_DIR"; exit 1; }

# Guard: bail out if we're not actually in a git repo.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not a git repository: $REPO_DIR"
    exit 1
fi

echo "=== Git Workflow Practice Exercises ==="
echo ""

# Exercise 1: what has changed since the last commit?
echo "--- Exercise 1: git status ---"
git status --short
echo ""

# Exercise 2: which branch am I on? This is the one I keep forgetting.
echo "--- Exercise 2: current branch ---"
CURRENT=$(git branch --show-current)
echo "On branch: $CURRENT"
echo ""

# Exercise 3: quick look at recent history — what did we ship?
echo "--- Exercise 3: last 5 commits ---"
git log --oneline -5 --decorate
echo ""

# Exercise 4: what's the diff summary (staged + unstaged)?
echo "--- Exercise 4: change summary ---"
git diff --stat
echo ""

# Exercise 5: am I ahead or behind the remote?
echo "--- Exercise 5: upstream tracking ---"
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-branch "${CURRENT}@{upstream}" 2>/dev/null)
if [ -n "$UPSTREAM" ]; then
    git rev-list --count --left-right "${UPSTREAM}...${CURRENT}" 2>/dev/null \
        | awk '{printf "  behind: %s  ahead: %s\n", $1, $2}'
else
    echo "  No upstream configured for $CURRENT"
fi

echo ""
echo "=== Exercises done — all read-only, safe to re-run ==="
