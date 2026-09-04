#!/usr/bin/env bash
# last_verified: 2026-09-04 · terraform n/a

# Workflow script that drives a Terraform run end-to-end: init, validate,
# plan, and apply, with explicit handling for the case where a state lock
# is already held (e.g. by a stuck prior run or a concurrent pipeline).
#
# Designed to be called from CI, but readable enough to run by hand.

set -euo pipefail

TF_DIR="${1:-.}"
TF_BIN="${TF_BIN:-terraform}"
LOCK_TIMEOUT_SEC="${LOCK_TIMEOUT_SEC:-300}"
LOCK_POLL_SEC="${LOCK_POLL_SEC:-10}"

cd "$TF_DIR" || { echo "cannot cd into $TF_DIR" >&2; exit 1; }

log() { printf '[tf-01] %s\n' "$*"; }

wait_for_lock() {
  local waited=0
  log "checking for an existing state lock..."
  while [ "$waited" -lt "$LOCK_TIMEOUT_SEC" ]; do
    if "$TF_BIN" plan -input=false -lock-timeout=0s >/dev/null 2>&1; then
      log "lock is free."
      return 0
    fi
    log "lock held - sleeping ${LOCK_POLL_SEC}s (waited ${waited}s of ${LOCK_TIMEOUT_SEC}s)"
    sleep "$LOCK_POLL_SEC"
    waited=$((waited + LOCK_POLL_SEC))
  done
  log "ERROR: lock still held after ${LOCK_TIMEOUT_SEC}s." >&2
  return 1
}

wait_for_lock

log "running terraform init"
"$TF_BIN" init -input=false

log "running terraform validate"
"$TF_BIN" validate

log "running terraform plan"
"$TF_BIN" plan -input=false -out=tfplan

log "running terraform apply"
"$TF_BIN" apply -input=false -auto-approve tfplan

log "done."