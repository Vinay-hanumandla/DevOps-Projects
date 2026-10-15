#!/usr/bin/env bash
# last_verified: 2026-10-15 repo-doc n/a
# I wanted one tiny script that answers: which branches are stale,
# do my recent commit messages follow the team pattern, and are there
# leftover dependency pins I should look at. Ran it on a scratch clone first.

# Usage: ./2026-10-15-stale-branch-cleanup.sh [--days 30]
# Prints a short report only; deletes nothing by itself.

DAYS="${1:-30}"
# TODO: I am not sure yet whether --merged or a date check is the better stale signal

echo "== stale branches (merged into main, local only; my cutoff ~$DAYS days) =="
git branch --merged main 2>/dev/null | grep -vE '^\*|main$' || echo "(no merged branches or no main branch here)"

echo "== commit message lint (last 10) =="
# my team pattern is: "<area>: <short summary>", so I just check for the colon
git log --oneline -10 2>/dev/null | while read -r line; do
  case "$line" in
    *:* ) echo "ok: $line" ;;
    * ) echo "needs-fix: $line  # missing '<area>:' prefix" ;;
  esac
done

echo "== dependency pins I should glance at =="
# not sure why grep -r needs the --include flags here but without them it scans .git
grep -r --include='requirements*.txt' --include='package.json' -l -E '==|~=' . 2>/dev/null | head -5 || echo "(no pinned dependency files found)"
