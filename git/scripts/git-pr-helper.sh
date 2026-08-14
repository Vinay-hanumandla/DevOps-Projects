#!/usr/bin/env bash
# last_verified: 2026-08-14 · git n/a

# git-pr-helper.sh
# Purpose: reusable helper for branch management and PR automation.
# Covers creating a feature branch from a base, guarding branch switches
# against a dirty working tree, deleting local and remote branches, and
# opening a pull request with the GitHub CLI. Every destructive action is
# behind an explicit check so a careless invocation can't nuke work.

set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<EOF
Usage: $0 <command> [args]

Commands:
  new <name> [base]   Create a feature branch <name> from [base] (default main).
  delete <name>       Delete branch <name> locally and on the remote, if present.
  clean-check         Exit non-zero if the working tree is dirty.
  pr [base]           Open a PR for the current branch against [base] (default main).
EOF
}

current_branch() {
  git rev-parse --abbrev-ref HEAD
}

ensure_clean() {
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "error: working tree is dirty; commit or stash before switching branches" >&2
    return 1
  fi
}

cmd_new() {
  local name="${1:-}"
  local base="${2:-main}"
  [[ -n "$name" ]] || { echo "error: branch name required" >&2; exit 2; }
  ensure_clean
  if git rev-parse --verify --quiet "refs/heads/$name"; then
    echo "error: branch '$name' already exists" >&2
    exit 1
  fi
  git fetch origin "$base" >/dev/null 2>&1 || true
  git checkout -b "$name" "origin/$base"
  echo "created $name from $base"
}

cmd_delete() {
  local name="${1:-}"
  [[ -n "$name" ]] || { echo "error: branch name required" >&2; exit 2; }
  [[ "$(current_branch)" != "$name" ]] || {
    echo "error: cannot delete the current branch; git checkout main first" >&2
    exit 1
  }
  git branch -d "$name"
  if git ls-remote --exit-code --heads origin "$name" >/dev/null 2>&1; then
    git push origin ":$name"
    echo "deleted remote '$name'"
  fi
}

cmd_clean_check() {
  ensure_clean
  echo "working tree clean"
}

cmd_pr() {
  local base="${1:-main}"
  command -v gh >/dev/null || { echo "error: gh CLI not installed" >&2; exit 1; }
  git push -u origin "$(current_branch)"
  gh pr create --base "$base" --fill
}

main() {
  local cmd="${1:-}"
  [[ -n "$cmd" ]] || { usage; exit 2; }
  shift
  case "$cmd" in
    new) cmd_new "$@" ;;
    delete) cmd_delete "$@" ;;
    clean-check) cmd_clean_check "$@" ;;
    pr) cmd_pr "$@" ;;
    -h|--help|help) usage ;;
    *) usage; exit 2 ;;
  esac
}

main "$@"