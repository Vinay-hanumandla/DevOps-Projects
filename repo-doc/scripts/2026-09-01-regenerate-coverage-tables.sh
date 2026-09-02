#!/usr/bin/env bash
# last_verified: 2026-09-01 · bash 5.3
#
# regenerate-coverage-tables.sh
# Companion script for repo-doc/docs/2026-08-08-reconcile-coverage-tables.md.
# Walks the kit, counts files per tool per category, and prints a Markdown
# table that I can paste into README.md and the per-tool coverage docs.
#
# I want to keep this at the L1 level — no strict mode, no traps, no defen-
# sive guards. It's a quick scan-and-print tool for my own use.

root="${1:-.}"

# Category directory name -> table column label.
declare -A category_label=(
  [notes]="notes"
  [docs]="docs"
  [scripts]="scripts"
  [snippets]="snippets"
  [configs]="configs"
  [templates]="templates"
  [manifests]="manifests"
  [dockerfiles]="dockerfiles"
  [notebooks]="notebooks"
)

# Tools to scan: every direct child of root that has its own subdir layout.
# Add new tool dirs here as the kit grows.
tools=(ansible bash docker gha git grafana helm jenkins k8s prom python tf repo-doc)

# A file's category is the dir name right under the tool root.
declare -A counts

for tool in "${tools[@]}"; do
  if [[ ! -d "$root/$tool" ]]; then
    continue
  fi
  for cat in "${!category_label[@]}"; do
    if [[ -d "$root/$tool/$cat" ]]; then
      n=$(find "$root/$tool/$cat" -maxdepth 1 -type f | wc -l)
      counts["$tool|$cat"]="$n"
    else
      counts["$tool|$cat"]=0
    fi
  done
done

# Print the table.
printf "| Tool |"
for cat in "${!category_label[@]}"; do
  printf " %s |" "${category_label[$cat]}"
done
printf "\n|------|"
for cat in "${!category_label[@]}"; do
  printf '%s' "------|"
done
printf "\n"

for tool in "${tools[@]}"; do
  if [[ ! -d "$root/$tool" ]]; then
    continue
  fi
  printf "| %s |" "$tool"
  for cat in "${!category_label[@]}"; do
    n="${counts[$tool|$cat]:-0}"
    if [[ "$n" -eq 0 ]]; then
      printf ' — |'
    else
      printf " %s |" "$n"
    fi
  done
  printf "\n"
done
