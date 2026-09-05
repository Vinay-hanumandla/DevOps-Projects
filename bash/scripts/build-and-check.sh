#!/usr/bin/env bash
# last_verified: 2026-09-05 · Bash 5.3

# build-and-check.sh — CI-safe wrapper that validates scripts with ShellCheck,
# then runs a build command with retry logic. Designed for pipelines where
# flaky builds or transient network failures need automatic recovery.

set -Eeuo pipefail

PROG="$(basename "$0")"
readonly PROG
readonly DEFAULT_RETRY_MAX=3
readonly DEFAULT_RETRY_DELAY=5

# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------

log()  { printf '[%s] %s\n' "$PROG" "$*" >&2; }
warn() { log "WARN: $*"; }
die()  { log "ERROR: $*"; exit 1; }

# ---------------------------------------------------------------------------
# with_retry — execute a command with configurable retries
# ---------------------------------------------------------------------------

with_retry() {
    local max_attempts="$1" delay="$2"
    shift 2
    local cmd=("$@")
    local attempt=0

    until "${cmd[@]}"; do
        attempt=$((attempt + 1))
        if (( attempt >= max_attempts )); then
            die "Command failed after ${attempt} attempt(s): ${cmd[*]}"
        fi
        warn "Attempt ${attempt} failed, retrying in ${delay}s..."
        sleep "$delay"
    done
}

# ---------------------------------------------------------------------------
# ShellCheck gate — validate a list of files before proceeding
# ---------------------------------------------------------------------------

shellcheck_gate() {
    local -a files=("$@")

    if [[ ${#files[@]} -eq 0 ]]; then
        return 0
    fi

    if ! command -v shellcheck >/dev/null 2>&1; then
        warn "shellcheck not found on PATH — skipping gate"
        return 0
    fi

    log "Running ShellCheck on ${#files[@]} file(s)..."
    if shellcheck -x -s bash "${files[@]}"; then
        log "ShellCheck passed"
    else
        die "ShellCheck found issues — fix before proceeding"
    fi
}

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------

usage() {
    cat <<EOF
Usage: $PROG [OPTIONS] -- <command> [args...]

CI-safe wrapper: optionally gate scripts through ShellCheck, then execute
the given command with automatic retries.

Options:
  -c, --check <file>     Run ShellCheck on <file> before executing (repeatable)
  -r, --retries <N>      Max retry attempts (default: ${DEFAULT_RETRY_MAX})
  -d, --delay <seconds>  Delay between retries (default: ${DEFAULT_RETRY_DELAY})
  -h, --help             Show this help message

Examples:
  $PROG -c lib/*.sh -- make build
  $PROG --retries 5 --delay 10 -- docker compose up --build
  $PROG -c scripts/deploy.sh -r 2 -- ./deploy.sh staging
EOF
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

main() {
    local -a check_files=()
    local retry_max="${DEFAULT_RETRY_MAX}"
    local retry_delay="${DEFAULT_RETRY_DELAY}"

    while (( $# > 0 )); do
        case "$1" in
            -c|--check)
                [[ -n "${2:-}" ]] || die "--check requires a file argument"
                check_files+=("$2")
                shift 2
                ;;
            -r|--retries)
                [[ -n "${2:-}" ]] || die "--retries requires a numeric argument"
                retry_max="$2"
                shift 2
                ;;
            -d|--delay)
                [[ -n "${2:-}" ]] || die "--delay requires a numeric argument"
                retry_delay="$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            *)
                die "Unknown option: $1 (use -- before the command)"
                ;;
        esac
    done

    (( $# > 0 )) || die "No command provided (use -- <command> [args...])"

    # Phase 1: ShellCheck gate
    if [[ ${#check_files[@]} -gt 0 ]]; then
        shellcheck_gate "${check_files[@]}"
    fi

    # Phase 2: Execute with retries
    log "Executing: $*"
    with_retry "$retry_max" "$retry_delay" "$@"

    log "Completed successfully"
}

main "$@"
