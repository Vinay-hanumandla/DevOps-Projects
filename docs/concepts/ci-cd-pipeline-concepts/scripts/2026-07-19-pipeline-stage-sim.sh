#!/usr/bin/env bash
# last_verified: 2026-07-19 · bash (concept practice: CI/CD stage simulation)
#
# Simulates a CI/CD pipeline with sequential stages (build -> test -> deploy)
# and parallel jobs inside the test stage, using exit codes to gate downstream
# stages (fail-fast). No real CI provider required — pure Bash.

set -euo pipefail

GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; BLUE=$'\033[0;34m'; RESET=$'\033[0m'
log()  { printf '%s[stage]%s %s\n'  "$BLUE"  "$RESET" "$1"; }
ok()   { printf '%s[ ok ]%s %s\n'   "$GREEN" "$RESET" "$1"; }
fail() { printf '%s[FAIL]%s %s\n'   "$RED"   "$RESET" "$1"; }

# Run a single job; prints what it does and returns the given exit code.
run_job() {
  local name="$1"; local code="$2"
  printf '  running %s ...\n' "$name"
  return "$code"
}

# Sequential stage: only proceeds if the previous stage succeeded (set -e).
build_stage() {
  log "build"
  run_job "build-app" 0 && ok "build-app"
}

# Parallel jobs: launch in background, wait, fail the stage if any job fails.
test_stage() {
  log "test (parallel)"
  local pids=()
  run_job "unit-test" 0       & pids+=($!)
  run_job "integration-test" 0 & pids+=($!)
  run_job "lint" 0            & pids+=($!)
  local rc=0
  for pid in "${pids[@]}"; do
    wait "$pid" || rc=1
  done
  if [ "$rc" -eq 0 ]; then ok "all test jobs passed"; else fail "a test job failed"; return 1; fi
}

deploy_stage() {
  log "deploy"
  run_job "deploy-staging" 0 && ok "deploy-staging"
}

main() {
  echo "== simulating pipeline: build -> test -> deploy =="
  build_stage
  test_stage
  deploy_stage
  echo "== pipeline succeeded =="
}

# Flip FAIL_TEST to 1 to see fail-fast: build passes, test fails, deploy is skipped.
FAIL_TEST="${FAIL_TEST:-0}"
if [ "$FAIL_TEST" = "1" ]; then
  test_stage() {
    log "test (parallel)"
    run_job "unit-test" 0 && ok "unit-test"
    if ! run_job "integration-test" 1; then fail "integration-test"; return 1; fi
    ok "integration-test"
    run_job "lint" 0 && ok "lint"
  }
fi

main
