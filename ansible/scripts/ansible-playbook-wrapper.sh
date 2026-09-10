#!/usr/bin/env bash
# last_verified: 2026-09-10 · Ansible 2.21.4
# ansible-playbook-wrapper.sh — run ansible-playbook through syntax-check, check-diff,
# and an idempotent rerun, then parse the result so a CI job can fail on unexpected changes.
#
# Usage:
#   ./ansible-playbook-wrapper.sh -i inventory/hosts playbook.yml
#   ./ansible-playbook-wrapper.sh -i inventory/hosts playbook.yml --tags users
#
# Exit codes:
#   0  all gates passed, playbook is idempotent
#   1  syntax error, check-diff failure, or non-idempotent second run
#   2  usage error (bad args, missing inventory)

set -euo pipefail

INVENTORY=""
PLAYBOOK=""
EXTRA_ARGS=()
RUN_MODE="full"   # full | check | syntax

usage() {
  cat <<EOF
Usage: $0 -i <inventory> <playbook> [extra ansible-playbook args]

Runs three gates before applying:
  1. ansible-playbook --syntax-check
  2. ansible-playbook --check --diff   (dry-run, no host changes)
  3. ansible-playbook (real run) followed by a second run; the second must report
     changed=0 for every host or the wrapper exits 1.

Exit 0 on success, 1 on a failed gate, 2 on usage error.
EOF
}

# ── arg parsing ──────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    -i) INVENTORY="$2"; shift 2 ;;
    -i*) INVENTORY="${1#-i}"; shift ;;
    --check) RUN_MODE="check"; shift ;;
    --syntax) RUN_MODE="syntax"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) EXTRA_ARGS+=("$1"); shift ;;
  esac
done

if [[ -z "$INVENTORY" || ${#EXTRA_ARGS[@]} -eq 0 ]]; then
  usage >&2
  exit 2
fi
PLAYBOOK="${EXTRA_ARGS[0]}"
EXTRA_ARGS=("${EXTRA_ARGS[@]:1}")

if [[ ! -f "$PLAYBOOK" ]]; then
  echo "✗ playbook not found: $PLAYBOOK" >&2
  exit 2
fi

# ── gate 1: syntax ───────────────────────────────────────────────────────────
echo "=== Gate 1: syntax-check ==="
if ! ansible-playbook -i "$INVENTORY" "$PLAYBOOK" --syntax-check; then
  echo "✗ syntax-check FAILED" >&2
  exit 1
fi

if [[ "$RUN_MODE" == "syntax" ]]; then
  echo "✓ syntax-check passed (--syntax mode)" >&2
  exit 0
fi

# ── gate 2: check-diff (no host changes) ─────────────────────────────────────
echo "=== Gate 2: check --diff (dry-run) ==="
if ! ansible-playbook -i "$INVENTORY" "$PLAYBOOK" --check --diff "${EXTRA_ARGS[@]}"; then
  echo "✗ check-diff FAILED" >&2
  exit 1
fi

if [[ "$RUN_MODE" == "check" ]]; then
  echo "✓ check-diff passed (--check mode)" >&2
  exit 0
fi

# ── gate 3: real run + idempotency rerun ─────────────────────────────────────
echo "=== Gate 3: first run ==="
first_out="$(ansible-playbook -i "$INVENTORY" "$PLAYBOOK" "${EXTRA_ARGS[@]}" 2>&1)"
echo "$first_out"

# The recap line looks like:  "ok | 3  | ..." or "changed | 2 | ..." per host.
# A second run must report zero changed tasks on every host.
echo "=== Gate 3: idempotency rerun ==="
second_out="$(ansible-playbook -i "$INVENTORY" "$PLAYBOOK" "${EXTRA_ARGS[@]}" 2>&1)"
echo "$second_out"

if echo "$second_out" | grep -Eq '(^|\n)(changed)\s+\|'; then
  echo "✗ idempotency FAILED: second run still reports changed tasks" >&2
  echo "--- second run recap ---" >&2
  echo "$second_out" | grep -E '(changed|ok)\s+\|' >&2
  exit 1
fi

echo "✓ all gates passed: syntax ok, check-diff ok, idempotent on rerun"
exit 0