#!/usr/bin/env bash
# last_verified: 2026-09-20 · Bash 5.3

# trap-library-template — reusable production trap library plus run() wrapper.
#
# Purpose: drop-in starting point for Bash 5.3 scripts that must fail fast,
# clean up temp state on every exit path, and report where they failed.
# When to use: any non-trivial automation script (CI job, deploy step,
# cron task) where silent continuation after an error is worse than aborting.
# Prerequisites: bash 5.3, standard coreutils. Source it or copy the
# guarded blocks into a new script.
# Verify: bash -n <script> for syntax, then run with ShellCheck (v0.11.0
# covers Bash 5.3 constructs) and exercise each trap with the demo main
# at the bottom of this file.

set -euo pipefail
set -E
IFS=$'\n\t'

# --- logging ---------------------------------------------------------------

# log <level> <message...>: timestamped line to stderr.
log() {
    local level="$1"
    shift
    printf '[%s] %-5s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S')" "$level" "$*" >&2
}

# --- error handling ----------------------------------------------------------

# on_error <lineno> <command>: ERR-trap handler. set -E above makes it
# inherit into functions and subshells so failures are reported with context.
on_error() {
    local lineno="${1:-?}"
    local cmd="${2:-unknown command}"
    log "ERROR" "failed at line ${lineno}: ${cmd} (exit $?)"
}

# cleanup: EXIT-trap handler. Runs on success, error, and INT/TERM, so temp
# state is never left behind.
cleanup() {
    local rc=$?
    if [[ -n "${TMP_DIR:-}" && -d "${TMP_DIR:-}" ]]; then
        rm -rf "$TMP_DIR"
        log "INFO" "removed temp dir $TMP_DIR"
    fi
    if [[ $rc -ne 0 ]]; then
        log "ERROR" "exiting with status $rc"
    fi
    return "$rc"
}

# on_interrupt: INT/TERM handler. Logs the signal, then exits so the EXIT
# trap still runs cleanup.
on_interrupt() {
    log "WARN" "interrupted; cleaning up"
    exit 130
}

trap 'on_error $LINENO "$BASH_COMMAND"' ERR
trap cleanup EXIT
trap on_interrupt INT TERM

# --- guards ------------------------------------------------------------------

# require_cmd <name>...: abort early with a clear message when a dependency
# is missing. Call before doing any real work.
require_cmd() {
    local missing=()
    local cmd
    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        log "ERROR" "missing required commands: ${missing[*]}"
        return 1
    fi
}

# run <command> [args...]: log a step, execute it, and return its status.
# Keeps output readable when a script chains many steps.
run() {
    log "INFO" "running: $*"
    "$@"
}

# --- template main (replace with real steps) ---------------------------------

main() {
    require_cmd "mktemp" "curl"
    TMP_DIR="$(mktemp -d)"
    log "INFO" "working in $TMP_DIR"

    run touch "$TMP_DIR/marker"
    log "INFO" "done"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
