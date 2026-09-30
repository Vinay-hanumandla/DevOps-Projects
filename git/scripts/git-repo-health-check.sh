#!/usr/bin/env bash
# last_verified: 2026-09-30 · Git 2.56.0
#
# git-repo-health-check.sh — fsck integrity, deprecated-config audit,
# and partial-clone adoption report. Read-only; does not modify the repo.
#
# Purpose:
#   Wrap three Git maintenance diagnostics into a single pre-flight gate:
#   (1) fsck integrity check for corrupt or missing objects, (2) deprecated-
#   configuration audit for the Git 3.0 migration (grafts, shallow clones,
#   legacy remote shorthands, deprecated extensions), and (3) partial-clone
#   adoption report (promisor remote, clone filter, promisor objects, and the
#   blob limit carried by the clone filter for 'git repack --drop-filtered').
#   Run before migrating a Git server to Git 3.0 or before cutting over to a
#   partial-clone workflow on a large repository.
#
# When to use:
#   Before migrating a Git server to Git 3.0. As a pre-flight check before
#   enabling partial-clone on a large repo. As a periodic health gate in
#   CI for mirrored or bare repositories.
#
# Prerequisites:
#   Git 2.56.0 (the version this script was written against). Run from within
#   a checkout or a bare repository. This version is read-only: it never writes
#   to the repository.
#
# Steps:
#   Run with no arguments to execute all three checks. Pass --check <name>
#   to run a single check: fsck | deprecated | partial-clone.
#
# Verify:
#   $ bash git-repo-health-check.sh
#   Expect: exit 0 with "[OK] All checks completed." on a healthy repo,
#   or exit 1 with specific [FAIL]/[WARN] lines if issues are found.
#
# Common errors:
#   - Not in a repository: exits 2. Run from a checkout or set GIT_DIR.
#   - fsck finds corruption: fix dangling/missing objects before migrating.
#   - info/grafts present: migrates to 'git replace' refs before Git 3.0.
#   - Remote-URL shorthand dirs present: migrate to git remote add before
#     Git 3.0 (these are removed in favor of config).
#   - Clone filter without a blob:limit= component: nothing to compare against
#     when running 'git repack --drop-filtered'; pass --filter=blob:limit=<n>.
#
# References:
#   Git 2.56.0 release notes:
#   https://raw.githubusercontent.com/git/git/v2.56.0/Documentation/RelNotes/2.56.0.adoc

set -euo pipefail
IFS=$'\n\t'

PROG="$(basename "$0")"
readonly PROG

ok()   { printf '  [OK]   %s\n' "$*"; }
warn() { printf '  [WARN] %s\n' "$*"; }
fail() { printf '  [FAIL] %s\n' "$*"; }
info() { printf '  %s\n' "$*"; }
section() { printf '\n== %s ==\n' "$*"; }
log() { printf '[%s] %s\n' "$PROG" "$*" >&2; }
die() { log "ERROR: $*"; exit 2; }

require_git() {
  command -v git >/dev/null 2>&1 || die "git not found in PATH"
  git rev-parse --show-toplevel >/dev/null 2>&1 \
    || git rev-parse --absolute-git-dir >/dev/null 2>&1 \
    || die "not inside a git repository"
}

git_dir() { git rev-parse --absolute-git-dir 2>/dev/null || git rev-parse --git-dir; }

# ── Check 1/3: fsck integrity ─────────────────────────────────────────────────
# git fsck --full --strict --unreachable detects corrupt, missing, or
# dangling objects and broken links. Git 2.56 also hardens the ort merge
# backend to abort on corrupt trees instead of proceeding silently.

check_fsck() {
  section "1/3  Repository integrity (git fsck)"
  info "Running: git fsck --full --strict --unreachable"

  local output rc=0
  if ! output=$(git fsck --full --strict --unreachable 2>&1); then
    rc=1
  fi

  if [[ -n "$output" ]]; then
    printf '%s\n' "$output" | sed 's/^/  /'
  else
    info "no corrupt, missing, or dangling objects"
  fi

  if [[ $rc -eq 0 ]]; then
    ok "fsck passed — no corruption detected"
  else
    fail "fsck reported issues — investigate before migrating"
  fi
  return "$rc"
}

# ── Check 2/3: Deprecated configuration audit ───────────────────────────────────
# Git 3.0 removes commit grafts (replaced by git replace refs) and remote-URL
# shorthands in branches/ and remotes/ (replaced by repository config).
# Shallow clones are a partial-clone precursor.

check_deprecated() {
  section "2/3  Deprecated configuration audit"
  local issues=0
  local gd
  gd="$(git_dir)"

  # Commit grafts — removed in Git 3.0
  if [[ -f "$gd/info/grafts" ]]; then
    fail "info/grafts present — removed in Git 3.0; migrate to 'git replace'"
    issues=$((issues + 1))
  else
    ok "no info/grafts file"
  fi

  # Remote-URL shorthand dirs — removed in Git 3.0 (replaced by config)
  local has_shorthand
  has_shorthand=0
  [[ -d "$gd/branches" ]] && { warn "branches/ shorthand dir present — removed in Git 3.0"; has_shorthand=1; }
  if [[ -d "$gd/remotes" ]]; then
    warn "remotes/ shorthand dir present — removed in Git 3.0"
    has_shorthand=1
  fi
  if [[ $has_shorthand -eq 1 ]]; then
    issues=$((issues + 1))
  fi

  # Shallow clone state — precursor to partial-clone
  if [[ -f "$gd/shallow" ]]; then
    warn ".git/shallow present — consider converting to partial-clone"
  else
    ok "no shallow clone state"
  fi

  # Deprecated extensions.* keys (everything except extensions.partial which
  # is the current partial-clone mechanism)
  local ext_keys
  ext_keys="$(git config --name-only --get-regexp '^extensions\.' 2>/dev/null \
    | grep -vE '^extensions\.partial$' || true)"
  if [[ -n "$ext_keys" ]]; then
    warn "Non-partial extensions.* config keys detected:"
    printf '%s\n' "$ext_keys" | sed 's/^/    /'
    issues=$((issues + 1))
  else
    ok "no deprecated extensions.* config keys"
  fi

  if [[ $issues -gt 0 ]]; then
    fail "$issues deprecated configuration issue(s) found"
    return 1
  fi
  ok "no deprecated configuration detected"
  return 0
}

# ── Check 3/3: Partial-clone adoption report ───────────────────────────────────
# Reports on promisor remote, clone filter, promisor objects, and the blob limit
# carried by the clone filter. There is no config key for that limit: it lives in
# the partialclonefilter value (e.g. blob:limit=1m) and is passed to
# 'git repack --drop-filtered' on the command line as --filter=blob:limit=<n>.
# Git 2.56 adds pack-objects --path-walk for path-scoped pack generation.

report_partial_clone() {
  section "3/3  Partial-clone adoption report"
  local gd
  gd="$(git_dir)"

  # Promisor remote (client.partialClone)
  local promisor="" filter=""
  promisor="$(git config --get client.partialClone 2>/dev/null || true)"
  if [[ -n "$promisor" ]]; then
    ok "promisor remote configured: $promisor"
    filter="$(git config --get "remote.${promisor}.partialclonefilter" 2>/dev/null || true)"
    if [[ -n "$filter" ]]; then
      ok "clone filter: $filter"
    else
      warn "no partialclonefilter set for remote '$promisor'"
    fi
  else
    info "no promisor remote configured (partial-clone not active)"
  fi

  # Promisor object files (.promisor files in objects/)
  if [[ -d "$gd/objects" ]]; then
    local promisor_count
    promisor_count="$(find "$gd/objects" -name '*.promisor' -type f 2>/dev/null | wc -l)"
    if [[ "$promisor_count" -gt 0 ]]; then
      ok "$promisor_count .promisor file(s) present"
    else
      info "no .promisor files found"
    fi
  fi

  # Blob limit for 'git repack --drop-filtered'. The limit is the blob:limit=
  # component of the clone filter — there is no gc.* config key for it — and it
  # is handed to repack on the command line as --filter=blob:limit=<n>.
  local blob_limit="" filter_spec=""
  if [[ -n "$filter" ]]; then
    for filter_spec in ${filter//,/ }; do
      if [[ "$filter_spec" == blob:limit=* ]]; then
        blob_limit="${filter_spec#blob:limit=}"
        break
      fi
    done
  fi

  if [[ -n "$blob_limit" ]]; then
    ok "effective blob limit (from clone filter): $blob_limit"
    info "  'git repack --drop-filtered --filter=blob:limit=$blob_limit'"
  else
    info "no blob:limit= component in the clone filter"
    info "  pass the limit on the command line:"
    info "    'git repack --drop-filtered --filter=blob:limit=<n>'"
  fi

  echo ""
  info "Git 2.56.0 migration notes:"
  info "  - 'git repack --drop-filtered --filter=blob:limit=<n>' deletes local"
  info "    promisor blobs over that limit to reclaim space"
  info "  - 'git pack-objects --path-walk <paths>' combines reachability"
  info "    bitmaps and delta-islands for path-scoped pack generation"
  info "  - Git 3.0 will default SHA-256 for new repos; grafts and"
  info "    remote-URL shorthands will be removed"
}

# ── Main ──────────────────────────────────────────────────────────────────────

usage() {
  cat <<EOF
Usage: $PROG [--check fsck|deprecated|partial-clone]
       $PROG                      (run all checks)

Exit codes: 0 = all passed, 1 = issues found, 2 = usage/not-in-repo error
EOF
}

main() {
  require_git

  printf 'Repository: %s\n' "$(git rev-parse --show-toplevel 2>/dev/null || git rev-parse --absolute-git-dir)"
  printf 'Git version: %s\n' "$(git --version)"
  printf 'HEAD: %s\n' "$(git rev-parse --short HEAD 2>/dev/null || echo 'empty (no commits)')"

  local overall=0
  local mode="all"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --check)
        mode="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "unknown argument: $1 (use --help for usage)"
        ;;
    esac
  done

  case "$mode" in
    all)
      check_fsck || overall=1
      check_deprecated || overall=1
      report_partial_clone
      ;;
    fsck)
      check_fsck || overall=1
      ;;
    deprecated)
      check_deprecated || overall=1
      ;;
    partial-clone)
      report_partial_clone
      ;;
    *)
      die "unknown check '$mode' (use: fsck|deprecated|partial-clone)"
      ;;
  esac

  section "Summary"
  if [[ $overall -eq 0 ]]; then
    ok "All checks completed."
  else
    fail "Issues found — review output above."
  fi
  exit "$overall"
}

main "$@"
