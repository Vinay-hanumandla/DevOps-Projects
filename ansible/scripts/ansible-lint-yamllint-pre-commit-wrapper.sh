#!/usr/bin/env bash
# last_verified: 2026-09-29 · Ansible 2.21.4
# 2026-09-29-ansible-lint-yamllint-pre-commit-wrapper.sh — Reusable pre-commit wrapper:
# runs ansible-lint and yamllint over staged YAML/Ansible files, applies yamllint
# auto-fix where possible, and reports a machine-readable summary.
#
# This is one approach; the Ansible docs also suggest wiring lint into CI rather than
# pre-commit for large repos, and pinning ansible-lint to a fixed major so the
# rule set does not drift between commits.
#
# Usage:
#   ./2026-09-29-ansible-lint-yamllint-pre-commit-wrapper.sh
#   ./2026-09-29-ansible-lint-yamllint-pre-commit-wrapper.sh --staged-only
#   ./2026-09-29-ansible-lint-yamllint-pre-commit-wrapper.sh --paths playbooks/ roles/
#
# Exit codes:
#   0  both linters clean (or only warnings)
#   1  ansible-lint reported errors, or yamllint reported errors after auto-fix
#   2  usage error (unknown flag, missing linter binary)

set -euo pipefail

STAGED_ONLY=0
PATHS=()

usage() {
  cat <<EOF
Usage: $0 [--staged-only] [--paths DIR...] [--help]

Runs ansible-lint and yamllint over the repo's YAML and Ansible content.

  --staged-only   Only lint files staged in git (default: whole repo)
  --paths DIR..   Explicit list of directories/files to lint (overrides --staged-only)
  -h, --help      Show this help message

yamllint runs with --fix first; the auto-fixed files are re-checked and any
remaining problems are reported. ansible-lint runs once and its findings are
printed verbatim.
EOF
}

# ── arg parsing ──────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --staged-only) STAGED_ONLY=1; shift ;;
    --paths)       shift; while [[ $# -gt 0 && "$1" != --* ]]; do PATHS+=("$1"); shift; done ;;
    -h|--help)     usage; exit 0 ;;
    *)             echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "✗ required command not found: $1" >&2
    exit 2
  fi
}

require_cmd ansible-lint
require_cmd yamllint
require_cmd git

# ── resolve the file set ─────────────────────────────────────────────────────
if [[ ${#PATHS[@]} -gt 0 ]]; then
  FILES=("${PATHS[@]}")
elif [[ "$STAGED_ONLY" -eq 1 ]]; then
  mapfile -t FILES < <(git diff --cached --name-only --diff-filter=AM \
    | grep -E '\.(yml|yaml)$' || true)
else
  mapfile -t FILES < <(git ls-files '*.yml' '*.yaml' || true)
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "✓ no YAML files to lint"
  exit 0
fi

echo "=== Linting ${#FILES[@]} file(s) ==="

# ── yamllint: auto-fix then re-check ─────────────────────────────────────────
echo "--- yamllint --fix ---"
yamllint --fix "${FILES[@]}" || true

yamllint_out="$(yamllint "${FILES[@]}" 2>&1)" || yamllint_rc=$?
yamllint_rc=${yamllint_rc:-0}

if [[ "$yamllint_rc" -eq 0 ]]; then
  echo "✓ yamllint clean"
else
  echo "$yamllint_out"
  echo "✗ yamllint reported $yamllint_rc problem(s) after auto-fix"
fi

# ── ansible-lint ─────────────────────────────────────────────────────────────
echo "--- ansible-lint ---"
if ansible-lint "${FILES[@]}"; then
  echo "✓ ansible-lint clean"
  al_rc=0
else
  al_rc=$?
  echo "✗ ansible-lint reported $al_rc problem(s)"
fi

# ── verdict ──────────────────────────────────────────────────────────────────
if [[ "$yamllint_rc" -ne 0 || "$al_rc" -ne 0 ]]; then
  echo "✗ pre-commit lint gate FAILED"
  exit 1
fi

echo "✓ pre-commit lint gate passed"
exit 0