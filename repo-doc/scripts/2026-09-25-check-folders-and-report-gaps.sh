#!/usr/bin/env bash
# last_verified: 2026-09-25 · repo-doc n/a
#
# I kept running the repo task workflow by hand (coverage tables, folder
# check, gap hunt), so I glued the three steps into one script following
# the quickstart notes. Here's what worked and where it broke:
#   1. regenerate coverage tables by reusing the 2026-09-01 script
#   2. validate each tool folder only holds known category subdirs
#   3. report gaps — tools with no files in a category they should have
#
# Usage: bash repo-doc/scripts/2026-09-25-check-folders-and-report-gaps.sh [kit-root]
# I ran it from the kit root with no args and it worked. Got stuck on
# nothing this time — the companion coverage script already existed, so
# step 1 just calls it. What I'd try next: fail loudly when gaps grow.

root="${1:-.}"
scripts_dir="$(cd "$(dirname "$0")" && pwd)"

echo "=== repo task workflow ==="
echo "Kit root: $root"
echo ""

# Step 1 — regenerate coverage tables via the companion script.
echo "--- Coverage tables ---"
if [[ -f "$scripts_dir/2026-09-01-regenerate-coverage-tables.sh" ]]; then
  bash "$scripts_dir/2026-09-01-regenerate-coverage-tables.sh" "$root"
else
  echo "(coverage script not found — skipping)"
fi
echo ""

# Step 2 — validate tool folder structure. Only these subdirs are legit;
# anything else sitting directly under a tool dir gets flagged.
echo "--- Folder structure ---"
known="notes docs scripts snippets configs templates manifests dockerfiles notebooks"
tools=(ansible bash docker gha git grafana helm jenkins k8s prom python tf repo-doc)
bad=0
for tool in "${tools[@]}"; do
  if [[ ! -d "$root/$tool" ]]; then
    echo "  MISSING dir: $tool"
    bad=$((bad + 1))
    continue
  fi
  for entry in "$root/$tool"/*; do
    [[ -e "$entry" ]] || continue
    name=$(basename "$entry")
    if [[ -f "$entry" ]]; then
      echo "  stray file: $tool/$name (I expected only subdirs here)"
      bad=$((bad + 1))
      continue
    fi
    ok=0
    for k in $known; do
      if [[ "$name" == "$k" ]]; then
        ok=1
        break
      fi
    done
    if [[ "$ok" -eq 0 ]]; then
      echo "  unknown subdir: $tool/$name"
      bad=$((bad + 1))
    fi
  done
done
if [[ "$bad" -eq 0 ]]; then
  echo "  (all tool folders look clean)"
fi
echo ""

# Step 3 — report gaps: categories with zero files per tool.
echo "--- Gaps ---"
gaps=0
for tool in "${tools[@]}"; do
  if [[ ! -d "$root/$tool" ]]; then
    continue
  fi
  for k in $known; do
    if [[ -d "$root/$tool/$k" ]]; then
      n=$(find "$root/$tool/$k" -maxdepth 1 -type f | wc -l)
      if [[ "$n" -eq 0 ]]; then
        echo "  gap: $tool/$k exists but is empty"
        gaps=$((gaps + 1))
      fi
    fi
  done
  if [[ ! -d "$root/$tool/notes" ]]; then
    echo "  gap: $tool has no notes dir at all"
    gaps=$((gaps + 1))
  fi
done
if [[ "$gaps" -eq 0 ]]; then
  echo "  (no gaps found)"
fi
echo ""

echo "=== done ==="
