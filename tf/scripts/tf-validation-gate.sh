#!/usr/bin/env bash
# last_verified: 2026-10-13 · terraform n/a
#
# tf-validation-gate.sh — reusable validation gate for a Terraform working
# directory. Runs four checks in order — terraform init, terraform validate,
# tflint, and tfsec — then writes a structured key=value report so CI can read
# pass/fail and per-stage timing without parsing free text.
#
# Usage:
#   ./tf-validation-gate.sh [--dir DIR] [--continue-on-error] [--report FILE]
#
# Options:
#   --dir DIR            Terraform working directory (default: current dir)
#   --continue-on-error  Run every stage even after a failure. Without it the
#                        gate stops at the first failing stage.
#   --report FILE        Write the structured report here
#                        (default: ./tf-validation-report.txt)
#
# Exit status:
#   0  every stage passed
#   1  one or more stages failed
#   2  usage error
#
# Each tool binary is overridable through TF_BIN / TFFLINT_BIN / TFSEC_BIN so
# the wrapper does not break when a tool is absent. A binary that is not
# installed is recorded as a stage failure rather than aborting the script, so a
# missing linter never leaves the run without a report.

set -euo pipefail

TF_DIR="."
TF_BIN="${TF_BIN:-terraform}"
TFFLINT_BIN="${TFFLINT_BIN:-tflint}"
TFSEC_BIN="${TFSEC_BIN:-tfsec}"
CONTINUE=0
REPORT_FILE="tf-validation-report.txt"
OVERALL_RC=0

die() { printf 'error: %s\n' "$*" >&2; exit 2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)               TF_DIR="${2:?--dir needs a value}"; shift 2 ;;
    --continue-on-error) CONTINUE=1; shift ;;
    --report)            REPORT_FILE="${2:?--report needs a value}"; shift 2 ;;
    -h|--help)
      cat <<'USAGE'
Usage: tf-validation-gate.sh [--dir DIR] [--continue-on-error] [--report FILE]
  --dir DIR            Terraform working directory (default: current dir)
  --continue-on-error  run every stage even after a failure
  --report FILE        write the structured report here
Exit status: 0 all stages passed, 1 any failed, 2 usage error
USAGE
      exit 0
      ;;
    *) die "unknown option: $1" ;;
  esac
done

[[ -d "$TF_DIR" ]] || die "directory not found: $TF_DIR"

REPORT_DIR="$(dirname "$REPORT_FILE")"
[[ -d "$REPORT_DIR" ]] || mkdir -p "$REPORT_DIR"

# One key=value line per stage, appended to the report and mirrored to stderr so
# the result is both machine-parseable and visible in CI logs without parsing.
report_stage() {
  local name="$1" status="$2" rc="$3" duration="$4" line
  line="stage=${name} status=${status} rc=${rc} duration_s=${duration}"
  printf '%s\n' "$line" | tee -a "$REPORT_FILE" >&2
}

write_report_header() {
  {
    printf '# tf-validation-gate report\n'
    printf 'started_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'dir=%s\n' "$TF_DIR"
    printf 'continue_on_error=%s\n' "$CONTINUE"
  } > "$REPORT_FILE"
}

write_report_footer() {
  local result="$1"
  {
    printf 'overall=%s\n' "$result"
    printf 'ended_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  } >> "$REPORT_FILE"
}

# Run one stage inside the Terraform directory, capture its exit code and
# wall-clock duration, record a structured line, and propagate the exit code.
# The `|| rc=$?` pair stops set -e from aborting on a stage failure.
run_stage() {
  local name="$1" bin="$2"; shift 2
  local rc=0 start end dur
  if ! command -v "$bin" >/dev/null 2>&1; then
    report_stage "$name" "fail" "127" "0"
    printf '  %s: binary not found: %s\n' "$name" "$bin" >&2
    return 1
  fi
  start="$(date +%s)"
  ( cd "$TF_DIR" && "$bin" "$@" ) || rc=$?
  end="$(date +%s)"
  dur=$(( end - start ))
  if [[ $rc -eq 0 ]]; then
    report_stage "$name" "pass" "$rc" "$dur"
    return 0
  fi
  report_stage "$name" "fail" "$rc" "$dur"
  return 1
}

on_stage_fail() {
  OVERALL_RC=1
  if [[ $CONTINUE -eq 0 ]]; then
    write_report_footer "fail"
    exit 1
  fi
}

# Verify:
#   bash -n tf/scripts/tf-validation-gate.sh
#   lint: shellcheck -x tf/scripts/tf-validation-gate.sh
#   ./tf-validation-gate.sh --dir /path/to/tf/config --report /tmp/tf-report.txt

write_report_header
run_stage "terraform_init"     "$TF_BIN" init -input=false || on_stage_fail
run_stage "terraform_validate" "$TF_BIN" validate || on_stage_fail
run_stage "tflint"             "$TFFLINT_BIN" || on_stage_fail
run_stage "tfsec"              "$TFSEC_BIN" || on_stage_fail

if [[ $OVERALL_RC -eq 0 ]]; then
  write_report_footer "pass"
else
  write_report_footer "fail"
fi
exit "$OVERALL_RC"
