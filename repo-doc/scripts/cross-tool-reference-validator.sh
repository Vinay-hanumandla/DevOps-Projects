#!/usr/bin/env bash
# last_verified: 2026-10-20 · repo-doc n/a
#
# cross-tool-reference-validator.sh
#
# Purpose: one runnable check that answers "do the references this kit
# publishes still resolve". It follows the cross-tool reference graph:
# the task IDs recorded in the changelog, the coverage manifest in
# README.md, the primer inventory, and the relative links that point from
# one tool folder into another. Folder layout and naming rules are covered
# by project-validator.py and the task-entry schema by
# kit-conformance-checker.py; this script stays on the question of what
# the kit claims exists versus what is actually on disk.
#
# Steps: point it at a kit checkout root (defaults to the checkout that
# holds this script). It reads the changelog for task IDs and resolves
# each ID prefix to a tool folder, parses the coverage table in README.md
# and compares its rows and per-category counts with the folders on disk,
# checks that every tool folder able to hold a primer has one, that the
# primers advertised in the navigation index exist on disk, and that every
# relative link and changelog path in the kit resolves.
#
# Verify: run `bash repo-doc/scripts/cross-tool-reference-validator.sh`
# from the kit root. Exit 0 means no broken reference was found, exit 1
# means at least one was reported, exit 2 means an input could not be
# read. Counts follow the README convention: files nested inside a
# template tree are counted, and the primer counts towards notes. Count
# drift is reported as a notice; pass --strict to treat it as a failure.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash repo-doc/scripts/cross-tool-reference-validator.sh [options]

Options:
  --kit-root PATH   Kit checkout to validate (default: the checkout holding this script).
  --strict          Treat count-drift notices as failures.
  -h, --help        Show this message.
EOF
}

kit_root=""
strict=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --kit-root)
      if [[ $# -lt 2 ]]; then
        printf 'error: --kit-root needs a path\n' >&2
        exit 2
      fi
      kit_root="$2"
      shift 2
      ;;
    --strict)
      strict=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      printf 'error: unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -z "$kit_root" ]]; then
  kit_root="$(cd "$script_dir/../.." && pwd)"
fi
if [[ ! -d "$kit_root" ]]; then
  printf 'error: kit root not found: %s\n' "$kit_root" >&2
  exit 2
fi

failures=0
notices=0

fail() {
  failures=$((failures + 1))
  printf 'FAIL: %s\n' "$1" >&2
}

notice() {
  notices=$((notices + 1))
  printf 'notice: %s\n' "$1"
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

categories=(notes docs scripts snippets configs manifests notebooks dockerfiles templates src hooks)

# The coverage manifest prints human-readable area names; this maps them
# back to the folder that holds the files.
area_to_folder() {
  case "$1" in
    "AWX") printf 'awx\n' ;;
    "GitHub Actions") printf 'gha\n' ;;
    "Helm Charts") printf 'hchart\n' ;;
    "Kube-Prometheus") printf 'kprom\n' ;;
    "Kubernetes") printf 'k8s\n' ;;
    "Prometheus") printf 'prom\n' ;;
    "Repo-doc") printf 'repo-doc\n' ;;
    "Terraform") printf 'tf\n' ;;
    "Terraform Cloud") printf 'tfc\n' ;;
    *) printf '%s\n' "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" ;;
  esac
}

# A task ID prefix names the folder that holds the deliverable. Older
# entries carry a compound prefix (helm-doc, tf-doc) and concept entries
# carry a concept slug, so the prefix is resolved in that order.
resolve_prefix() {
  local prefix="$1" segment
  if [[ -d "$kit_root/$prefix" ]]; then
    printf '%s\n' "$prefix"
    return 0
  fi
  if [[ "$prefix" == "con" || -d "$kit_root/docs/concepts/$prefix" ]]; then
    printf 'docs/concepts\n'
    return 0
  fi
  for segment in $(tool_folders); do
    if [[ "$prefix" == "$segment-"* ]]; then
      printf '%s\n' "$segment"
      return 0
    fi
  done
  return 1
}

count_files() {
  local dir="$1" category="$2"
  if [[ ! -d "$dir/$category" ]]; then
    printf '0\n'
    return
  fi
  find "$dir/$category" -type f | wc -l | tr -d '[:space:]'
}

# A tool folder is any top-level directory that holds at least one
# category subdirectory.
tool_folders() {
  local entry name category
  for entry in "$kit_root"/*/; do
    [[ -d "$entry" ]] || continue
    name="$(basename "$entry")"
    case "$name" in
      docs | 00_index | .*) continue ;;
    esac
    for category in "${categories[@]}"; do
      if [[ -d "$entry/$category" ]]; then
        printf '%s\n' "$name"
        break
      fi
    done
  done
}

printf '=== Cross-tool reference validation ===\n'
printf 'Kit root: %s\n\n' "$kit_root"

# --------------------------------------------------------------------------
# 1. Task IDs recorded in the changelog must resolve to a tool folder.
# --------------------------------------------------------------------------
printf -- '--- Task IDs ---\n'
changelog="$kit_root/CHANGELOG.md"
if [[ ! -f "$changelog" ]]; then
  printf 'error: changelog not found: %s\n' "$changelog" >&2
  exit 2
fi

task_ids="$(
  {
    grep -oE '\([a-z][a-z0-9]*(-[a-z0-9]+)*-[0-9]+\)$' "$changelog" | tr -d '()' || true
    grep -E '^- Passed \(\[[^]]*\]' "$changelog" | awk '{print $4}' || true
  } | sort -u
)"

if [[ -z "$task_ids" ]]; then
  notice "no task IDs found in the changelog"
else
  while IFS= read -r task_id; do
    [[ -n "$task_id" ]] || continue
    prefix="${task_id%-*}"
    if ! resolved="$(resolve_prefix "$prefix")"; then
      fail "task ID $task_id: prefix '$prefix' has no folder in the kit"
      continue
    fi
    if [[ "$resolved" == "docs/concepts" && ! -d "$kit_root/docs/concepts" ]]; then
      fail "task ID $task_id: prefix '$prefix' resolves to no concept folder"
    fi
  done <<<"$task_ids"
  printf '  checked %s task IDs\n' "$(printf '%s\n' "$task_ids" | wc -l | tr -d '[:space:]')"
fi
printf '\n'

# --------------------------------------------------------------------------
# 2. The coverage manifest in README.md must match the folders on disk.
# --------------------------------------------------------------------------
printf -- '--- Coverage manifest ---\n'
readme="$kit_root/README.md"
if [[ ! -f "$readme" ]]; then
  printf 'error: readme not found: %s\n' "$readme" >&2
  exit 2
fi

manifest_rows="$(awk -F'|' '
  /^\|[[:space:]]*Area[[:space:]]*\|/ { inside = 1; next }
  inside && /^\|[[:space:]]*[-:]+/ { next }
  inside && /^\|/ { print; next }
  inside { exit }
' "$readme")"

if [[ -z "$manifest_rows" ]]; then
  fail "no coverage table found in $readme"
else
  manifest_folders=()
  while IFS= read -r row; do
    [[ -n "$row" ]] || continue
    IFS='|' read -r -a cells <<<"$row"
    area="$(trim "${cells[1]}")"
    [[ -n "$area" ]] || continue
    folder="$(area_to_folder "$area")"
    if [[ ! -d "$kit_root/$folder" ]]; then
      fail "coverage manifest row '$area' has no folder in the kit (looked for '$folder')"
      continue
    fi
    manifest_folders+=("$folder")
    drift=""
    for index in "${!categories[@]}"; do
      stated="$(trim "${cells[$((2 + index))]}")"
      [[ "$stated" == "—" ]] && stated="0"
      disk="$(count_files "$kit_root/$folder" "${categories[$index]}")"
      if [[ "$stated" != "$disk" ]]; then
        drift="${drift}${drift:+, }${categories[$index]} $stated vs $disk"
      fi
    done
    if [[ -n "$drift" ]]; then
      notice "coverage manifest row '$area' differs from disk: $drift"
    fi
  done <<<"$manifest_rows"

  for folder in $(tool_folders); do
    listed=0
    for known in ${manifest_folders[@]+"${manifest_folders[@]}"}; do
      if [[ "$known" == "$folder" ]]; then
        listed=1
        break
      fi
    done
    if [[ "$listed" -eq 0 ]]; then
      notice "tool folder '$folder' has no row in the coverage manifest"
    fi
  done
fi
printf '\n'

# --------------------------------------------------------------------------
# 3. Primer coverage: every tool folder that can hold a primer has one,
#    and every primer advertised in the navigation index exists on disk.
# --------------------------------------------------------------------------
printf -- '--- Primer coverage ---\n'
for folder in $(tool_folders); do
  notes_dir="$kit_root/$folder/notes"
  if [[ ! -d "$notes_dir" ]]; then
    notice "tool folder '$folder' has no notes/ directory, so it cannot hold a primer"
    continue
  fi
  primers=()
  while IFS= read -r primer; do
    [[ -n "$primer" ]] && primers+=("$primer")
  done < <(find "$notes_dir" -maxdepth 1 -type f -name '0000-primer-*.md' | sort)
  if [[ ${#primers[@]} -eq 0 ]]; then
    fail "tool folder '$folder' has a notes/ directory but no primer"
  elif [[ ${#primers[@]} -gt 1 ]]; then
    fail "tool folder '$folder' has ${#primers[@]} primers: ${primers[*]}"
  fi
done

index_file="$kit_root/00_index/topics.md"
if [[ -f "$index_file" ]]; then
  advertised=()
  while IFS= read -r link; do
    [[ -n "$link" ]] || continue
    target="$(trim "$link")"
    advertised+=("$target")
    if [[ ! -e "$kit_root/00_index/$target" ]]; then
      fail "navigation index advertises a primer that is not on disk: $target"
    fi
  done < <(grep -oE '\*\*primer:\*\* \[[^][]*\]\([^)]*\)' "$index_file" |
    sed -E 's/.*\]\(([^)]*)\)/\1/' || true)

  while IFS= read -r primer; do
    [[ -n "$primer" ]] || continue
    relative="${primer#"$kit_root/"}"
    listed=0
    for link in ${advertised[@]+"${advertised[@]}"}; do
      if [[ "$link" == "../$relative" ]]; then
        listed=1
        break
      fi
    done
    if [[ "$listed" -eq 0 ]]; then
      notice "primer '$relative' is not advertised in the navigation index"
    fi
  done < <(find "$kit_root" -mindepth 3 -maxdepth 3 -type f -path '*/notes/0000-primer-*.md' | sort)
fi
printf '\n'

# --------------------------------------------------------------------------
# 4. Cross-tool references: relative links and changelog paths must exist.
# --------------------------------------------------------------------------
printf -- '--- Cross-tool references ---\n'
while IFS= read -r file; do
  links="$(awk '/^[[:space:]]*```/ { inside = !inside; next } !inside { print }' "$file" |
    grep -oE '\[[^][]*\]\([^)]*\)' || true)"
  while IFS= read -r link; do
    [[ -n "$link" ]] || continue
    target="$(printf '%s' "$link" | sed -E 's/^\[[^][]*\]\((.*)\)$/\1/')"
    target="$(trim "${target%% *}")"
    target="${target%%#*}"
    case "$target" in
      "" | http:* | https:* | mailto:* | tel:* | /*) continue ;;
    esac
    if [[ ! -e "$(dirname "$file")/$target" ]]; then
      fail "broken link in ${file#"$kit_root"/}: $target"
    fi
  done <<<"$links"
done < <(find "$kit_root" -type f -name '*.md' -not -path '*/.git/*' | sort)

while IFS= read -r line; do
  entry="$(printf '%s' "$line" | awk '{print $2}')"
  [[ "$entry" =~ ^[A-Za-z0-9._-]+/ ]] || continue
  while IFS= read -r part; do
    [[ -n "$part" ]] || continue
    candidate="$kit_root/${part%/}"
    if [[ ! -e "$candidate" ]]; then
      fail "changelog entry references a path that is not on disk: ${part%/}"
    fi
  done < <(printf '%s\n' "$entry" | sed 's/ + /\n/g')
done < <(grep -E '^- ' "$changelog" || true)
printf '\n'

# --------------------------------------------------------------------------
# Summary
# --------------------------------------------------------------------------
printf '=== done ===\n'
printf '%s failure(s), %s notice(s)\n' "$failures" "$notices"

if [[ "$failures" -gt 0 ]]; then
  exit 1
fi
if [[ "$notices" -gt 0 && "$strict" -eq 1 ]]; then
  exit 1
fi
exit 0
