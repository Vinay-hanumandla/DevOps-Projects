#!/usr/bin/env bash
# last_verified: 2026-09-10 · repo-doc n/a
#
# Minimal task automation for the repo-doc tooling.
# Combines the common one-off steps I keep doing by hand:
#   1. Regenerate coverage tables from the filesystem
#   2. List new/changed files since last commit
#   3. Print a summary of what needs attention
#
# Usage: bash repo-doc/scripts/<this-file>.sh [kit-root]
#   kit-root defaults to the current directory.

root="${1:-.}"
scripts_dir="$(cd "$(dirname "$0")" && pwd)"

echo "=== repo-doc task automation ==="
echo "Kit root: $root"
echo ""

# Step 1 — coverage tables
echo "--- Coverage tables ---"
if [[ -f "$scripts_dir/2026-09-01-regenerate-coverage-tables.sh" ]]; then
  bash "$scripts_dir/2026-09-01-regenerate-coverage-tables.sh" "$root"
else
  echo "(coverage script not found — skipping)"
fi
echo ""

# Step 2 — files changed since last commit
echo "--- Files changed since last commit ---"
if git -C "$root" rev-parse --is-inside-work-tree &>/dev/null; then
  changed=$(git -C "$root" diff --name-only HEAD 2>/dev/null || echo "")
  if [[ -n "$changed" ]]; then
    echo "$changed"
  else
    echo "(no uncommitted changes)"
  fi
else
  echo "(not a git repo — skipping)"
fi
echo ""

# Step 3 — per-tool file counts (quick glance)
echo "--- Tool file counts ---"
tools=(ansible bash docker gha git grafana helm jenkins k8s prom python tf repo-doc)
for tool in "${tools[@]}"; do
  if [[ ! -d "$root/$tool" ]]; then
    continue
  fi
  count=$(find "$root/$tool" -type f -not -path '*/\.*' | wc -l)
  printf "  %-12s %s files\n" "$tool" "$count"
done
echo ""

echo "=== done ==="
