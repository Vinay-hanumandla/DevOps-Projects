#!/usr/bin/env bash
# last_verified: 2026-08-13 · bash (concept practice: CI/CD failure detection + observability)
#
# Combines CI/CD Pipeline Concepts (stages, fail-fast gates, exit codes,
# retries) with Observability (structured, timestamped records) into one
# small helper: it runs a pipeline stage command, captures its exit code,
# retries transient failures, and writes machine-parseable log lines so a
# human or a monitoring tool can see why the stage failed and in how long.

set -Eeuo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: pipeline-failure-detection.sh "<stage name>" <command> [args...]

Runs <command> as a pipeline stage. On failure it retries up to RETRIES more
times (default 2) and exits non-zero with a final structured record once the
stage keeps failing. Each attempt emits a timestamped line like:

  stage=deploy event=stage_failed attempt=1 exit_code=3

Environment variables:
  RETRIES      max retries after the first attempt (default 2)
  RETRY_DELAY  seconds to wait between attempts (default 2)
EOF
  exit 2
}

# Structured, timestamped record: stage= event= key=value...
log_record() {
  local stage="$1" event="$2"
  shift 2
  printf '%s stage=%s event=%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$stage" "$event" "$*"
}

# Runs the stage command once and reports its duration plus exit code.
run_stage() {
  local stage="$1"
  shift
  local start end rc
  start=$(date +%s)
  if "$@"; then
    rc=0
  else
    rc=$?
  fi
  end=$(date +%s)
  log_record "$stage" attempt_done "exit_code=$rc" "duration_s=$((end - start))"
  return "$rc"
}

main() {
  [ "$#" -ge 2 ] || usage
  local stage="$1"
  shift
  local attempts=0 rc=1
  local max_attempts=$(( ${RETRIES:-2} + 1 ))
  while [ "$attempts" -lt "$max_attempts" ]; do
    attempts=$((attempts + 1))
    log_record "$stage" attempt_start "attempt=$attempts"
    if run_stage "$stage" "$@"; then
      log_record "$stage" stage_passed "attempt=$attempts"
      exit 0
    else
      rc=$?
      log_record "$stage" stage_failed "attempt=$attempts" "exit_code=$rc"
      [ "$attempts" -lt "$max_attempts" ] || break
      sleep "${RETRY_DELAY:-2}"
    fi
  done
  log_record "$stage" pipeline_aborted "attempts=$max_attempts"
  exit "$rc"
}

main "$@"