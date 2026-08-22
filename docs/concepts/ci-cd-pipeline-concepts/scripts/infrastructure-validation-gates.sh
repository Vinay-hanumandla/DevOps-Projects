#!/usr/bin/env bash
# last_verified: 2026-08-22 · bash n/a
#
# Pattern: CI/CD + IaC — infrastructure validation gates in pipelines
#
# This script demonstrates how to wire infrastructure validation into a
# CI/CD pipeline as a gate that blocks deployment when configs are invalid.
# It validates Terraform and Ansible configurations, then reports results
# in a structured format suitable for CI log aggregation.
#
# In practice, you'd call this from a GitHub Actions workflow step or a
# Jenkins pipeline stage before any `terraform apply` or `ansible-playbook`
# run. The script exits non-zero if any validation fails, which causes the
# CI system to halt the pipeline.

set -Eeuo pipefail

# --- Config ---
TERRAFORM_DIR="${TERRAFORM_DIR:-.}"
ANSIBLE_DIR="${ANSIBLE_DIR:-.}"
ANSIBLE_PLAYBOOK="${ANSIBLE_PLAYBOOK:-site.yml}"

# --- Helpers ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

log()   { printf '[%s] %s\n' "$(date -u +%H:%M:%S)" "$*"; }
ok()    { printf '%s[PASS]%s %s\n' "$GREEN" "$RESET" "$*"; }
warn()  { printf '%s[WARN]%s %s\n' "$YELLOW" "$RESET" "$*"; }
fail()  { printf '%s[FAIL]%s %s\n' "$RED" "$RESET" "$*"; }

errors=0

# --- Terraform validation ---
validate_terraform() {
  log "Validating Terraform configuration in $TERRAFORM_DIR"

  if [ ! -d "$TERRAFORM_DIR" ]; then
    warn "Terraform directory $TERRAFORM_DIR not found — skipping"
    return 0
  fi

  if ! command -v terraform >/dev/null 2>&1; then
    warn "terraform not installed — skipping validation"
    return 0
  fi

  # terraform init is required before validate in most cases
  if ! terraform -chdir="$TERRAFORM_DIR" init -backend=false -input=false >/dev/null 2>&1; then
    fail "terraform init failed in $TERRAFORM_DIR"
    errors=$((errors + 1))
    return 1
  fi

  if terraform -chdir="$TERRAFORM_DIR" validate >/dev/null 2>&1; then
    ok "terraform validate passed"
  else
    fail "terraform validate failed"
    terraform -chdir="$TERRAFORM_DIR" validate 2>&1 | head -20
    errors=$((errors + 1))
    return 1
  fi

  # terraform fmt check — ensure formatting is consistent
  if terraform -chdir="$TERRAFORM_DIR" fmt -check -diff >/dev/null 2>&1; then
    ok "terraform fmt check passed"
  else
    fail "terraform fmt check failed — run 'terraform fmt' to fix"
    errors=$((errors + 1))
    return 1
  fi
}

# --- Ansible validation ---
validate_ansible() {
  log "Validating Ansible playbook in $ANSIBLE_DIR"

  if [ ! -d "$ANSIBLE_DIR" ]; then
    warn "Ansible directory $ANSIBLE_DIR not found — skipping"
    return 0
  fi

  if ! command -v ansible-playbook >/dev/null 2>&1; then
    warn "ansible-playbook not installed — skipping validation"
    return 0
  fi

  local playbook_path="$ANSIBLE_DIR/$ANSIBLE_PLAYBOOK"
  if [ ! -f "$playbook_path" ]; then
    warn "Playbook $playbook_path not found — skipping"
    return 0
  fi

  # Syntax check catches YAML errors and undefined variables at parse time
  if ansible-playbook --syntax-check "$playbook_path" >/dev/null 2>&1; then
    ok "ansible-playbook --syntax-check passed"
  else
    fail "ansible-playbook --syntax-check failed"
    ansible-playbook --syntax-check "$playbook_path" 2>&1 | head -20
    errors=$((errors + 1))
    return 1
  fi

  # Dry-run to surface issues without applying changes
  if ansible-playbook --check --diff "$playbook_path" >/dev/null 2>&1; then
    ok "ansible-playbook --check passed"
  else
    fail "ansible-playbook --check failed"
    errors=$((errors + 1))
    return 1
  fi
}

# --- Docker Compose validation ---
validate_docker_compose() {
  log "Validating Docker Compose files"

  local compose_files
  compose_files=$(find . -maxdepth 2 -name 'docker-compose*.yml' -o -name 'docker-compose*.yaml' -o -name 'compose*.yml' -o -name 'compose*.yaml' 2>/dev/null)

  if [ -z "$compose_files" ]; then
    warn "No Docker Compose files found — skipping"
    return 0
  fi

  if ! command -v docker >/dev/null 2>&1; then
    warn "docker not installed — skipping compose validation"
    return 0
  fi

  while IFS= read -r f; do
    if docker compose -f "$f" config >/dev/null 2>&1; then
      ok "docker compose config passed for $f"
    else
      fail "docker compose config failed for $f"
      errors=$((errors + 1))
    fi
  done <<< "$compose_files"
}

# --- Main ---
main() {
  log "=== Infrastructure Validation Gates ==="
  echo ""

  validate_terraform
  echo ""
  validate_ansible
  echo ""
  validate_docker_compose

  echo ""
  if [ "$errors" -gt 0 ]; then
    fail "Validation failed with $errors error(s) — pipeline blocked"
    exit 1
  else
    ok "All validations passed — pipeline can proceed"
    exit 0
  fi
}

main "$@"
