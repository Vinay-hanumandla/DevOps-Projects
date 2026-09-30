#!/usr/bin/env bash
# last_verified: 2026-09-30 · Bash n/a
# coproc-fifo-and-named-variables.sh — coproc producer/consumer, a FIFO
# worker pool, and named-variable tricks.
#
# Purpose:
#   Show three ways to stop re-spawning a helper per item and to move data
#   around without hard-coding variable names:
#     1. coproc_request_response - one long-lived worker addressed by name,
#        with its descriptors copied out before another coproc is started.
#     2. fifo_worker_pool - a named pipe with several workers reading it, so
#        jobs are handed out by the kernel and each worker pays its startup
#        cost once instead of once per job.
#     3. named_variable_dispatch - namerefs and indirect expansion for
#        dispatching without eval and without globals.
#
# When to use:
#   Use the coproc when a helper has expensive startup or holds state worth
#   keeping between calls, and use the FIFO pool when the same work must be
#   spread over a fixed number of processes. Use namerefs when a helper has
#   to read or extend a caller's variable or array by name.
#
# Prerequisites:
#   bash with coproc support and declare -n namerefs, plus mkfifo, sort and
#   cat from coreutils. Check them with: bash --version && command -v mkfifo
#
# Steps:
#   Run the file directly. Each section prints its own labelled output and
#   the script exits 0 once all three have run.
#
# Verify:
#   Run: bash coproc-fifo-and-named-variables.sh
#   Expect three sections; acknowledgements arrive in request order in
#   section 1, section 2's replies are sorted so the output is stable, and
#   the exit status is 0.
#
# Common errors:
#   - Starting a second `coproc` without saving the first one's array first:
#     the array is overwritten and the original worker becomes unreachable.
#   - Reading from the worker's read end while the write end is still open
#     in the same shell: the read blocks waiting for a line that never comes.
#   - Backgrounding a worker without closing the inherited write end of the
#     FIFO first: the child holds it open and never receives EOF.
#   - `local -n ref="$1"` naming the very variable the caller passed, which
#     Bash rejects as a circular name reference.

set -euo pipefail

# --- 1. coproc producer/consumer --------------------------------------------
#
# `coproc NAME` puts the worker's descriptors in NAME[0] (read) and NAME[1]
# (write) rather than in the COPROC array, so later coprocs cannot clobber
# them.

coproc_request_response() {
  printf 'section 1: coproc round trip\n'

  coproc ack_worker {
    while IFS= read -r line; do
      printf 'ack:%s\n' "$line"
    done
  }

  local -a worker=( "${ack_worker[@]}" )
  local read_fd="${worker[0]}" write_fd="${worker[1]}"

  printf 'request a\n' >&"$write_fd"
  printf 'request b\n' >&"$write_fd"
  printf 'request c\n' >&"$write_fd"

  # Closing the write end is what delivers EOF, so the worker loop exits.
  # The read loop below only ends once the worker has closed its own end.
  exec {write_fd}>&-

  local response
  while IFS= read -r response <&"$read_fd"; do
    printf 'received %s\n' "$response"
  done
}

# --- 2. FIFO worker pool ----------------------------------------------------
#
# Opening the FIFO read/write in this shell first means the workers and the
# producer attach at their own pace instead of racing each other's open().

fifo_worker_pool() {
  printf 'section 2: FIFO worker pool\n'

  local job_fifo reply_dir job reply
  job_fifo="$(mktemp -u)"
  reply_dir="$(mktemp -d)"
  mkfifo "$job_fifo"

  exec {job_fd}<>"$job_fifo"

  # $1 is the worker id, $2 the file it appends replies to.
  line_echo() {
    local id="$1" out="$2" line
    while IFS= read -r line; do
      printf 'done:%s by worker%s\n' "$line" "$id" >>"$out"
    done
  }

  local worker_id
  for worker_id in 1 2 3; do
    # A backgrounded child inherits job_fd through the fork. Closing it in
    # the child is what lets the parent's close deliver EOF to the pool.
    # Each worker also owns its reply file: a shared file would interleave
    # partial lines, because append redirection is not atomic per printf.
    ( exec {job_fd}>&-; line_echo "$worker_id" "$reply_dir/w$worker_id" ) <"$job_fifo" &
  done

  for job in build test deploy docs release; do
    printf '%s\n' "$job" >&$job_fd
  done
  exec {job_fd}>&-

  wait

  # Which worker picks up which job is decided by the kernel, so sort the
  # replies to keep the printed output stable between runs.
  while IFS= read -r reply; do
    printf 'queue replied %s\n' "$reply"
  done < <(cat "$reply_dir"/w* | sort)

  rm -f "$job_fifo"
  rm -rf "$reply_dir"
}

# --- 3. named-variable tricks -----------------------------------------------

named_variable_dispatch() {
  printf 'section 3: named variables\n'

  local -a results=()
  local -A handlers=( [build]=run_build [test]=run_test [deploy]=run_deploy )
  # shellcheck disable=SC2034  # mode is only read indirectly, via ${!target}
  local mode="${MODE:-verbose}"

  # Each handler reports on stdout; the caller decides where it lands.
  run_build()  { printf 'build ran\n'; }
  run_test()   { printf 'test ran\n'; }
  run_deploy() { printf 'deploy ran\n'; }

  # $1 is the caller's array name, not the array itself.
  record() {
    local -n out="$1"
    out+=("$2")
  }

  local stage handler_output
  for stage in build test deploy; do
    # The array holds the handler name, so the call needs no if/elif chain.
    handler_output="$("${handlers[$stage]}")"
    results+=("$handler_output")
    record results "$stage-recorded"
  done

  printf 'results are: %s\n' "${results[*]}"

  # Indirect expansion: read a variable whose name is only known at runtime.
  # It works for a scalar; ${!arr[*]} is not the array's contents, so use a
  # nameref when the target is an array.
  local target=mode
  printf 'indirect read of %s: %s\n' "$target" "${!target}"
}

coproc_request_response
fifo_worker_pool
named_variable_dispatch