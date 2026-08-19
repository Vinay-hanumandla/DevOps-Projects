#!/usr/bin/env bash
# last_verified: 2026-08-19 · git n/a

# changelog-from-conventional-commits.sh
# Purpose: reusable helper that turns conventional commit messages into a
# Markdown changelog. It reads commit subjects from `git log`, buckets them
# by type (feat, fix, docs, chore, other), and writes a grouped list to a
# CHANGELOG-style markdown file. This is one way to automate release notes;
# the docs also suggest such tools typically support scopes, bump levels,
# and body-text extraction, which this helper deliberately keeps simple.

set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<EOF
Usage: $0 [from-ref] [to-ref]

  from-ref   Start of the commit range (default: earliest tag reachable from HEAD).
  to-ref     End of the commit range (default: HEAD).

Writes the changelog markdown to stdout. Refs follow git rev-parse syntax.
EOF
}

die() {
  echo "error: $*" >&2
  exit 1
}

find_from_ref() {
  local tag
  tag="$(git describe --tags --abbrev=0 2>/dev/null || true)"
  if [[ -n "$tag" ]]; then
    echo "$tag"
  else
    git rev-list --max-parents=0 HEAD | tail -n 1
  fi
}

bucket_commit() {
  # Echo the conventional-commit type for one subject line; lowercase it.
  local subject="$1"
  local type
  type="$(printf '%s' "$subject" | sed -E 's/^([a-z]+)(\([a-zA-Z0-9 _-]+\))?!?:.*/\1/')"
  case "$type" in
    feat|fix|docs|chore) echo "$type" ;;
    *) echo "other" ;;
  esac
}

emit_changelog() {
  local from="$1" to="$2"
  local line bucket
  declare -A grouped

  while read -r line; do
    [[ -n "$line" ]] || continue
    bucket="$(bucket_commit "$line")"
    grouped["$bucket"]+="  - $line"$'\n'
  done < <(git log --pretty=format:%s "$from..$to" 2>/dev/null)

  [[ "${#grouped[@]}" -gt 0 ]] || die "no commits found in range $from..$to"

  echo "## Changelog"
  echo ""
  echo "Commits from \`$from\` to \`$to\`:"
  echo ""
  for bucket in feat fix docs chore other; do
    if [[ -v "grouped[$bucket]" ]]; then
      echo "### $bucket"
      echo ""
      printf '%s' "${grouped[$bucket]}"
      echo ""
    fi
  done
}

main() {
  local from="${1:-}"
  local to="${2:-HEAD}"

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || die "not inside a git work tree"
  [[ "$to" =~ ^-- ]] && { usage; die "to-ref must come before options"; }

  from="${from:-$(find_from_ref)}"
  git rev-parse --verify --quiet "$from" >/dev/null 2>&1 \
    || die "cannot resolve ref '$from'"
  git rev-parse --verify --quiet "$to" >/dev/null 2>&1 \
    || die "cannot resolve ref '$to'"

  emit_changelog "$from" "$to"
}

main "$@"