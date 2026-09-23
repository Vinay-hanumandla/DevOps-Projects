#!/usr/bin/env bash
# last_verified: 2026-09-23 · Bash n/a
#
# parallel-execution-patterns.sh — Run shell work in parallel three ways.
#
# Purpose:
#   Compare three parallel-execution patterns for shell workloads so a
#   pipeline author can pick the right one: xargs with process slots,
#   GNU parallel for per-job logging, and a named-pipe pool for strict
#   concurrency control without extra dependencies.
#
# When to use:
#   Use xargs -P when the tool is already installed everywhere and the
#   jobs are uniform. Use GNU parallel when each job needs its own
#   tagged output and retry semantics. Use the named-pipe pool when
#   parallel is not installed and the job count must stay bounded.
#
# Prerequisites:
#   bash, xargs. GNU parallel only for the parallel path.
#   Demo jobs use sleep and printf only.
#
# Steps:
#   Run one of the three functions below against a list of work items.
#   Each function takes work items as arguments and runs a per-item
#   handler with bounded concurrency.
#
# Verify:
#   Run: bash parallel-execution-patterns.sh --demo
#   Expect interleaved START/DONE lines and exit code 0. Run with
#   --jobs 1 to confirm serial ordering.
#
# Common errors:
#   - Unquoted {} placeholders split filenames with spaces; always quote.
#   - Forgetting `wait` in the fifo pool leaves the pipe behind; the
#     cleanup trap removes it.
#   - Mixing stdout/stderr across jobs garbles logs; redirect per-job
#     output to a file when ordering matters.

set -euo pipefail

PROG="$(basename "$0")"
readonly PROG
JOBS=4

log() { printf '[%s] %s\n' "$PROG" "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

# Simulated unit of work. Replace with the real command.
do_work() {
  local item="$1"
  printf 'START %s\n' "$item"
  sleep 1
  printf 'DONE %s\n' "$item"
}

# Pattern 1: xargs with process slots. No extra dependencies.
run_xargs() {
  require_cmd xargs
  # shellcheck disable=SC2016 # $1 is expanded inside the child bash, not here
  printf '%s\n' "$@" | xargs -P "$JOBS" -I {} bash -c 'printf "START %s\n" "$1"; sleep 1; printf "DONE %s\n" "$1"' _ {}
}

# Pattern 2: GNU parallel with per-job tagged output.
run_parallel() {
  require_cmd parallel
  printf '%s\n' "$@" | parallel -j "$JOBS" --tag 'printf "START %s\n" {}; sleep 1; printf "DONE %s\n" {}'
}

# Pattern 3: named-pipe (fifo) token pool. Bounds concurrency to $JOBS
# without GNU parallel. Tokens are newlines sitting in the pipe.
run_fifo_pool() {
  local fifo
  fifo="$(mktemp -u)"
  mkfifo "$fifo"
  exec 9<>"$fifo"
  rm -f "$fifo"
  cleanup() { exec 9>&-; }
  trap cleanup EXIT

  local i
  for ((i = 0; i < JOBS; i++)); do printf '\n' >&9; done

  for item in "$@"; do
    read -r -u 9 _ || true
    {
      do_work "$item"
      printf '\n' >&9
    } &
  done
  wait
  trap - EXIT
  cleanup
}

usage() {
  cat <<EOF
Usage: $PROG [--jobs N] [--mode xargs|parallel|fifo] [--demo] [item ...]

Examples:
  $PROG --mode xargs --jobs 4 a b c d
  $PROG --mode fifo --jobs 2 job1 job2 job3
  $PROG --demo
EOF
}

main() {
  local mode="xargs"
  local -a items=()
  while (($# > 0)); do
    case "$1" in
      --jobs) JOBS="${2:?--jobs needs a number}"; shift 2 ;;
      --mode) mode="${2:?--mode needs a value}"; shift 2 ;;
      --demo) items=(alpha bravo charlie delta); shift ;;
      -h|--help) usage; exit 0 ;;
      --) shift; while (($# > 0)); do items+=("$1"); shift; done ;;
      -*) die "unknown option: $1" ;;
      *) items+=("$1"); shift ;;
    esac
  done
  [[ "${JOBS}" =~ ^[0-9]+$ ]] || die "--jobs must be a positive integer"
  ((JOBS >= 1)) || die "--jobs must be >= 1"
  ((${#items[@]} > 0)) || die "no work items given (try --demo)"

  case "$mode" in
    xargs) run_xargs "${items[@]}" ;;
    parallel) run_parallel "${items[@]}" ;;
    fifo) run_fifo_pool "${items[@]}" ;;
    *) die "unknown --mode: $mode (xargs|parallel|fifo)" ;;
  esac
  log "completed ${#items[@]} item(s) via $mode with $JOBS slot(s)"
}

main "$@"
