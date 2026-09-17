#!/usr/bin/env bash
# last_verified: 2026-09-17 · ansible-playbook (wrapper is flag-level; no pinned version)
# ansible-playbook-gated-run.sh — gate an ansible-playbook apply behind
# syntax-check, check-diff, and an idempotency rerun, then parse the recap
# into a short per-host summary a CI job can archive or grep.
#
# Purpose: catch playbook errors before they touch hosts. The same three
# validation steps the CI sequencing guidance recommends — a syntax check,
# a check-mode dry run, and ansible-lint — run first; only then does the
# playbook apply, followed by a rerun that must report changed=0.
#
# Steps:
#   1. ansible-playbook --syntax-check
#   2. ansible-playbook --check --diff (dry run, no host changes)
#   3. ansible-lint (only with --lint; skipped with a warning if not installed)
#   4. ansible-playbook (real apply) + recap parsing
#   5. ansible-playbook again; every host must show changed=0 (idempotent)
#
# Verify: run with --check-only for a check-mode gate, or --syntax-only for the
# cheapest gate. Inspect the summary file for per-host ok/changed/failed counts.
#
# Usage:
#   ./ansible-playbook-gated-run.sh -i inventory/hosts site.yml [-- extra args]
#   ./ansible-playbook-gated-run.sh -i inventory/hosts site.yml --check-only
#   ./ansible-playbook-gated-run.sh -i inventory/hosts site.yml --lint --summary-out result.txt
#
# Exit codes:
#   0  all gates passed and the rerun is idempotent
#   1  a gate failed, the apply failed, or the rerun still reports changes
#   2  usage error (missing inventory/playbook, unreadable files)

set -uo pipefail

INVENTORY=""
PLAYBOOK=""
MODE="full"          # full | check-only | syntax-only
WANT_LINT=0
SUMMARY_OUT=""
EXTRA_ARGS=()

usage() {
  cat <<EOF
Usage: $0 -i <inventory> <playbook> [--syntax-only] [--check-only] [--lint]
          [--summary-out <file>] [-- extra ansible-playbook args]

Gates a playbook apply: --syntax-check, --check --diff, optional ansible-lint,
then apply + idempotency rerun (second run must report changed=0 per host).
A per-host recap summary is printed and, with --summary-out, written to a file.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -i)
      [[ $# -lt 2 ]] && { echo "✗ -i needs a value" >&2; usage >&2; exit 2; }
      INVENTORY="$2"; shift 2 ;;
    -i*)
      INVENTORY="${1#-i}"; shift ;;
    --syntax-only)
      MODE="syntax-only"; shift ;;
    --check-only)
      MODE="check-only"; shift ;;
    --lint)
      WANT_LINT=1; shift ;;
    --summary-out)
      [[ $# -lt 2 ]] && { echo "✗ --summary-out needs a value" >&2; usage >&2; exit 2; }
      SUMMARY_OUT="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    --)
      shift; while [[ $# -gt 0 ]]; do EXTRA_ARGS+=("$1"); shift; done ;;
    -*)
      echo "✗ unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)
      if [[ -z "${PLAYBOOK:-}" ]]; then PLAYBOOK="$1"; else EXTRA_ARGS+=("$1"); fi
      shift ;;
  esac
done

if [[ -z "$INVENTORY" || -z "${PLAYBOOK:-}" ]]; then
  echo "✗ inventory (-i) and playbook are both required" >&2
  usage >&2
  exit 2
fi
if [[ ! -f "$PLAYBOOK" ]]; then
  echo "✗ playbook not found: $PLAYBOOK" >&2
  exit 2
fi

# recap_lines: print only the per-host "host : ok=N changed=N ..." recap rows.
recap_lines() {
  grep -E '^[^[:space:]]+[[:space:]]+: ok=[0-9]+' || true
}

# field_of <recap-line> <field>: extract the numeric value of ok/changed/failed/unreachable.
field_of() {
  echo "$1" | sed -n "s/.*\b$2=\([0-9][0-9]*\).*/\1/p"
}

# summarize <label> <playbook-output>: print per-host counts; return 1 on
# any failed/unreachable host, 0 otherwise. Appends to SUMMARY_OUT when set.
SUMMARY_TMP=""
summarize() {
  local label="$1" out="$2" rows row host failed unreachable failed_any=0
  rows="$(echo "$out" | recap_lines)"
  if [[ -z "$rows" ]]; then
    echo "✗ $label: no PLAY RECAP found in ansible-playbook output" >&2
    return 1
  fi
  echo "--- $label recap ---"
  while IFS= read -r row; do
    host="$(echo "$row" | awk -F: '{gsub(/^[ \t]+|[ \t]+$/, "", $1); print $1}')"
    failed="$(field_of "$row" failed)"
    unreachable="$(field_of "$row" unreachable)"
    echo "host=$host ok=$(field_of "$row" ok) changed=$(field_of "$row" changed) failed=${failed:-?} unreachable=${unreachable:-?}"
    if [[ "${failed:-0}" != "0" || "${unreachable:-0}" != "0" ]]; then
      failed_any=1
    fi
  done <<< "$rows"
  if [[ -n "$SUMMARY_OUT" ]]; then
    { echo "--- $label recap ---"; echo "$rows"; } >> "$SUMMARY_TMP"
  fi
  [[ "$failed_any" == "0" ]]
}

# non_idempotent_hosts <playbook-output>: print hosts whose recap row shows changed!=0.
non_idempotent_hosts() {
  local row host changed
  while IFS= read -r row; do
    [[ -z "$row" ]] && continue
    changed="$(field_of "$row" changed)"
    if [[ "${changed:-0}" != "0" ]]; then
      host="$(echo "$row" | awk -F: '{gsub(/^[ \t]+|[ \t]+$/, "", $1); print $1}')"
      echo "$host (changed=$changed)"
    fi
  done <<< "$(echo "$1" | recap_lines)"
  return 0
}

if [[ -n "$SUMMARY_OUT" ]]; then
  SUMMARY_TMP="$(mktemp)"
  trap 'rm -f "$SUMMARY_TMP"' EXIT
fi

echo "=== Gate 1: syntax-check ==="
if ! ansible-playbook -i "$INVENTORY" "$PLAYBOOK" --syntax-check; then
  echo "✗ syntax-check FAILED" >&2
  exit 1
fi
[[ "$MODE" == "syntax-only" ]] && { echo "✓ syntax-check passed (--syntax-only)"; exit 0; }

echo "=== Gate 2: check --diff (dry run) ==="
if ! ansible-playbook -i "$INVENTORY" "$PLAYBOOK" --check --diff "${EXTRA_ARGS[@]}"; then
  echo "✗ check-diff FAILED" >&2
  exit 1
fi
[[ "$MODE" == "check-only" ]] && { echo "✓ check-diff passed (--check-only)"; exit 0; }

if [[ "$WANT_LINT" == "1" ]]; then
  echo "=== Gate 3: ansible-lint ==="
  if ! command -v ansible-lint >/dev/null 2>&1; then
    echo "⚠ ansible-lint not installed; skipping lint gate" >&2
  elif ! ansible-lint "$PLAYBOOK"; then
    echo "✗ ansible-lint FAILED" >&2
    exit 1
  fi
fi

echo "=== Gate 4: apply ==="
apply_out="$(ansible-playbook -i "$INVENTORY" "$PLAYBOOK" "${EXTRA_ARGS[@]}" 2>&1)"
apply_rc=$?
echo "$apply_out"
if [[ "$apply_rc" -ne 0 ]]; then
  echo "✗ apply FAILED (exit $apply_rc)" >&2
  exit 1
fi
if ! summarize "apply" "$apply_out"; then
  echo "✗ apply had failed or unreachable hosts" >&2
  exit 1
fi

echo "=== Gate 5: idempotency rerun (expect changed=0) ==="
rerun_out="$(ansible-playbook -i "$INVENTORY" "$PLAYBOOK" "${EXTRA_ARGS[@]}" 2>&1)"
rerun_rc=$?
echo "$rerun_out"
if [[ "$rerun_rc" -ne 0 ]]; then
  echo "✗ rerun FAILED (exit $rerun_rc)" >&2
  exit 1
fi
if ! summarize "rerun" "$rerun_out"; then
  echo "✗ rerun had failed or unreachable hosts" >&2
  exit 1
fi
offenders="$(non_idempotent_hosts "$rerun_out")"
if [[ -n "$offenders" ]]; then
  echo "✗ NOT IDEMPOTENT — hosts still reporting changes on rerun:" >&2
  echo "$offenders" >&2
  exit 1
fi

if [[ -n "$SUMMARY_OUT" ]]; then
  echo "✓ all gates passed: syntax ok, check-diff ok, idempotent on rerun" >> "$SUMMARY_TMP"
  mv "$SUMMARY_TMP" "$SUMMARY_OUT"
  trap - EXIT
fi
echo "✓ all gates passed: syntax ok, check-diff ok, idempotent on rerun"
exit 0
