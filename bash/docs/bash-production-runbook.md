---
last_verified: 2026-10-20
tool_version: n/a
sources: []
---

# Bash production runbook: strict mode, cleanup-once traps, and correlation-ID logging

## Purpose

This runbook is the copy-pasteable starting point for a Bash script that has to
survive unattended execution: strict mode that fails loudly, signal handling
that cleans up exactly once, and structured logs that can be traced across a
multi-script run by a single correlation id.

It also pins down three behaviours that the sibling docs in this directory
leave open:

1. What `set -e` actually aborts on — in particular that a plain assignment
   from a command substitution aborts the script, and that `local` hides it.
2. Why a `trap … EXIT` handler combined with a signal trap runs the cleanup
   twice, and the guard that makes it run once.
3. The application log contract — one JSON key set, one level filter, one
   correlation id — and how a child process inherits it. (The sibling
   strict-mode runbook covers a different record shape: one telemetry record
   per pipeline, carrying the `PIPESTATUS` array.)

The strict-mode header guard, trap-based cleanup, `PIPESTATUS` telemetry and
the ShellCheck CI gate are covered by the sibling docs listed under References.
They are not repeated here on purpose; this document owns the consolidated
template and the three behaviours above.

## When to Use

Apply this runbook when authoring or reviewing a Bash script that:

- Runs unattended (CI job, cron entry, service unit, container entrypoint)
  where a silent failure is expensive.
- Performs a multi-step operation (deploy, migration, backup, sync) that must
  release locks, remove temporary state, or close connections on the way out.
- Acts as a parent of other scripts and needs one trace identifier across the
  whole run.
- Is being audited: the Verify section is a checklist that runs unchanged
  against a candidate script.

A one-off command that is typed and read in the same terminal does not need
this machinery. `set -euo pipefail` on its own is enough for it.

## Prerequisites

- A Bash with associative arrays (`help declare`). The template uses them for
  the level table and nothing more exotic.
- `jq` for JSON encoding of log messages and for the log-shape gate in the
  Verify section. The template falls back to a pure-Bash escaper when `jq` is
  not installed.
- `shellcheck` for the static gate in the Verify section.
- `uuidgen` for correlation ids. The template falls back to
  `/proc/sys/kernel/random/uuid` and then to a random hex string, so the id
  is never empty.

## Steps

### 1. Strict mode: what aborts the script, and what does not

`set -euo pipefail` is the header of the template:

```bash
set -euo pipefail
```

| Flag | Effect | Why it matters |
|------|--------|----------------|
| `-e` (errexit) | Abort on a command that returns non-zero | Stops a failed step from being papered over by the next one |
| `-u` (nounset) | Treat an unset variable as an error | Catches typos in variable names before they cause damage |
| `-o pipefail` | A pipeline returns the status of the rightmost failing stage | `cmd1 \| cmd2` fails when `cmd1` fails, not only when `cmd2` fails |

`errexit` does not fire in every position, and the exceptions are the part
that is usually misremembered. The table below was verified by running each
case, not by reading the manual.

| Construct | Aborts the script? | Reason |
|-----------|--------------------|--------|
| `cmd` | Yes | The status is not consumed by anything else |
| `result=$(cmd)` | Yes | A plain assignment takes the exit status of the substitution |
| `local value=$(cmd)` | No | `local` returns 0 and masks the substitution's status |
| `local value; value=$(cmd)` | Yes | Splitting declaration from assignment restores the abort |
| `if cmd; then … fi` | No | The status is tested, not fatal |
| `cmd \|\| fallback` | No | The fallback handles the failure |
| `cmd1 \| cmd2` under `pipefail` | Yes, if any stage fails | The pipeline status is the rightmost failing stage |
| Body of a trap handler | Yes | `errexit` is still in force inside the handler |

Two consequences follow directly. A command substitution that is expected to
fail has to be moved into a tested context rather than assigned blindly:

```bash
set -euo pipefail
result=$(false)          # aborts here: the script exits 1
echo "not reached"       # never printed
```

And a function that assigns from a command substitution must not hide the
status behind `local`:

```bash
set -euo pipefail
collect() {
    local value=$(false)   # `local` masks the failure: the script continues
    echo "still running, value='$value'"
}
collect                    # prints "still running", exits 0
```

Declare first, assign on the next line, and the failure is fatal again:

```bash
collect() {
    local value
    value=$(false)         # aborts: the substitution's status is the assignment's status
    echo "not reached"
}
```

The template relies on this behaviour deliberately: `CORRELATION_ID="$(generate_correlation_id)"`
aborts the run if the id generator fails, because an untraceable run is worse
than a stopped one.

### 2. Cleanup that runs exactly once

A cleanup handler registered on `EXIT` also fires when the script exits from a
signal handler, because the handler's own `exit` triggers the `EXIT` trap
again. Registering the same handler for both `EXIT` and `TERM` therefore runs
the registered cleanup actions twice on a `SIGTERM`.

The fix is a guard flag, plus `set +e` inside the handler so that a failing
cleanup step cannot replace the exit code the caller asked for:

```bash
CLEANUP_DONE=0
declare -a CLEANUP_ACTIONS=()

register_cleanup() {
    CLEANUP_ACTIONS+=("$1")
}

cleanup() {
    local exit_code="$1"
    if (( CLEANUP_DONE )); then
        return 0
    fi
    CLEANUP_DONE=1

    # errexit stays on inside a trap handler, so disable it here: a failing
    # cleanup step is reported and the original status is still returned.
    set +e

    local action
    for action in "${CLEANUP_ACTIONS[@]}"; do
        if ! eval "$action"; then
            printf 'warning: cleanup action failed: %s\n' "$action" >&2
        fi
    done

    exit "$exit_code"
}

trap 'cleanup $?' EXIT
trap 'cleanup 130' INT
trap 'cleanup 143' TERM
```

The exit statuses the handler is asked to preserve:

| Situation | Trap | Status returned |
|-----------|------|-----------------|
| Normal completion | `cleanup $?` | 0 |
| A step failed | `cleanup $?` | the failing step's status |
| `SIGINT` (Ctrl+C) | `cleanup 130` | 130 |
| `SIGTERM` (polite stop) | `cleanup 143` | 143 |
| `SIGKILL` | none — the handler never runs | the process is removed, cleanup does not happen |

The signal handlers are installed before the work starts, and every function
the handlers call is defined above the `trap` lines: a handler that calls an
undefined function fails with `command not found` at the worst possible
moment.

### 3. Structured logging with a correlation id

The template emits one JSON object per line, and every line uses the same key
set. A single schema is the point: a log parser, a gate and a dashboard all
have to agree on the field names, and a second key set silently breaks every
consumer that was written against the first.

| Key | Meaning |
|-----|---------|
| `timestamp` | UTC time with millisecond precision |
| `level` | `DEBUG`, `INFO`, `WARN`, `ERROR` or `CRITICAL` |
| `script` | Name of the script that emitted the line |
| `pid` | Process id of the emitter |
| `correlation_id` | Trace identifier shared by every line of one run |
| `message` | The human-readable text, JSON-escaped |

Levels are compared numerically, so filtering is an integer test:

| Level | Value | Typical use |
|-------|-------|-------------|
| `DEBUG` | 10 | Diagnostic detail, off by default |
| `INFO` | 20 | Normal operational events |
| `WARN` | 30 | Unexpected but handled situations |
| `ERROR` | 40 | Failures needing attention |
| `CRITICAL` | 50 | Immediate intervention required |

A line is emitted when its level is greater than or equal to the configured
threshold. `LOG_LEVEL=WARN` therefore keeps `WARN`, `ERROR` and `CRITICAL` and
drops `DEBUG` and `INFO`.

The correlation id is created once by the parent and exported, so every child
process inherits it without extra wiring:

```bash
if [[ -z "${CORRELATION_ID:-}" ]]; then
    CORRELATION_ID="$(generate_correlation_id)"
fi
export CORRELATION_ID LOG_LEVEL
export LOG_THRESHOLD="${LOG_LEVEL_NUM[$LOG_LEVEL]}"
```

`LOG_LEVEL` and `LOG_THRESHOLD` are exported for the same reason: a child
step that logged `INFO` lines while the parent was running at `WARN` would
break the verbosity the operator asked for. With the threshold in the
environment, a child applies the same filter and the whole run stays
consistent.

An operator-set `CORRELATION_ID` wins over the generated one, which is what
makes a trace reproducible:

```bash
CORRELATION_ID=run-4711 ./runbook.sh | jq -r '.correlation_id' | sort -u
# run-4711
```

### 4. Consolidated runbook template

Save this as `runbook.sh` and replace the work phase with the real workload.
Everything around it — the header, the logging contract, the cleanup guard and
the argument parsing — is ready to use as is.

```bash
#!/usr/bin/env bash
# last_verified: 2026-10-20 · bash n/a
#
# Consolidated runbook template: strict mode, cleanup-once traps, and
# correlation-ID structured logging.

set -euo pipefail

# ===========================================================================
# CONFIGURATION
# ===========================================================================
SCRIPT_NAME="${0##*/}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOG_LEVEL="${LOG_LEVEL:-INFO}"
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/$SCRIPT_NAME.conf}"
CORRELATION_ID="${CORRELATION_ID:-}"

readonly SCRIPT_NAME SCRIPT_DIR

# ===========================================================================
# LOGGING
# ===========================================================================
declare -A LOG_LEVEL_NUM=(
    [DEBUG]=10
    [INFO]=20
    [WARN]=30
    [ERROR]=40
    [CRITICAL]=50
)

json_escape() {
    local text="$1"
    text=${text//\\/\\\\}
    text=${text//\"/\\\"}
    text=${text//$'\n'/\\n}
    text=${text//$'\r'/\\r}
    text=${text//$'\t'/\\t}
    printf '%s' "$text"
}

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")

    if (( ${LOG_LEVEL_NUM[$level]:-0} < ${LOG_LEVEL_NUM[$LOG_LEVEL]:-20} )); then
        return 0
    fi

    local encoded
    if command -v jq >/dev/null 2>&1; then
        encoded=$(jq -n --arg msg "$message" '$msg')
    else
        encoded="\"$(json_escape "$message")\""
    fi

    printf '{"timestamp":"%s","level":"%s","script":"%s","pid":%d,"correlation_id":"%s","message":%s}\n' \
        "$timestamp" "$level" "$SCRIPT_NAME" "$$" "$CORRELATION_ID" "$encoded"
}

log_debug() { log DEBUG "$@"; }
log_info() { log INFO "$@"; }
log_warn() { log WARN "$@"; }
log_error() { log ERROR "$@"; }
log_critical() { log CRITICAL "$@"; }

# ===========================================================================
# CLEANUP
# ===========================================================================
CLEANUP_DONE=0
RUN_STATE="starting"
declare -a CLEANUP_ACTIONS=()

register_cleanup() {
    CLEANUP_ACTIONS+=("$1")
}

cleanup() {
    local exit_code="$1"
    if (( CLEANUP_DONE )); then
        return 0
    fi
    CLEANUP_DONE=1

    # The handler must not change the exit code the caller asked for, so
    # errexit is disabled inside it: a failing cleanup step is reported and
    # the original status is still returned.
    set +e

    local action
    for action in "${CLEANUP_ACTIONS[@]}"; do
        if ! eval "$action"; then
            printf 'warning: cleanup action failed: %s\n' "$action" >&2
        fi
    done

    if [[ "$RUN_STATE" == "running" ]]; then
        log_info "Cleanup finished (exit code: $exit_code)"
    fi
    exit "$exit_code"
}
trap 'cleanup $?' EXIT
trap 'cleanup 130' INT
trap 'cleanup 143' TERM

# ===========================================================================
# HELPERS
# ===========================================================================
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]
Options:
  -h, --help       Show this help and exit
  -v, --verbose    Enable DEBUG logging
  -c, --config     Configuration file (default: $CONFIG_FILE)
EOF
}

parse_args() {
    while (($# > 0)); do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                LOG_LEVEL=DEBUG
                ;;
            -c|--config)
                if (($# < 2)); then
                    printf 'error: --config requires a path\n' >&2
                    exit 2
                fi
                CONFIG_FILE="$2"
                shift
                ;;
            *)
                printf 'error: unknown option: %s\n' "$1" >&2
                usage >&2
                exit 2
                ;;
        esac
        shift
    done
}

generate_correlation_id() {
    if command -v uuidgen >/dev/null 2>&1; then
        uuidgen
    elif [[ -r /proc/sys/kernel/random/uuid ]]; then
        cat /proc/sys/kernel/random/uuid
    else
        printf '%04x%04x%04x' "$RANDOM" "$RANDOM" "$RANDOM"
    fi
}

# ===========================================================================
# MAIN
# ===========================================================================
main() {
    parse_args "$@"
    RUN_STATE="running"

    if [[ -z "${CORRELATION_ID:-}" ]]; then
        CORRELATION_ID="$(generate_correlation_id)"
    fi

    if [[ -z "${LOG_LEVEL_NUM[$LOG_LEVEL]+set}" ]]; then
        printf 'error: unknown LOG_LEVEL: %s\n' "$LOG_LEVEL" >&2
        exit 2
    fi

    # Exported so that child steps inherit the same trace identifier and the
    # same verbosity as the parent.
    export CORRELATION_ID LOG_LEVEL
    export LOG_THRESHOLD="${LOG_LEVEL_NUM[$LOG_LEVEL]}"

    log_info "Starting $SCRIPT_NAME (correlation id: $CORRELATION_ID)"

    if [[ -f "$CONFIG_FILE" ]]; then
        # shellcheck source=/dev/null
        source "$CONFIG_FILE"
        log_info "Loaded configuration from $CONFIG_FILE"
    else
        log_warn "No configuration file at $CONFIG_FILE, continuing with defaults"
    fi

    local work_dir
    work_dir="$(mktemp -d)"
    register_cleanup "rm -rf '$work_dir'"
    log_debug "Work directory: $work_dir"

    log_info "Work phase started"
    # Optional delay, used by the signal-handling check in the Verify section.
    sleep "${WORK_DELAY:-0}"
    log_info "Work phase completed"

    # A child step inherits the exported correlation id and log threshold, so
    # every line of a multi-script run carries the same trace identifier and
    # the same verbosity. The child reuses the same key set as the parent.
    bash -c '
        set -euo pipefail
        if (( 20 < ${LOG_THRESHOLD:-20} )); then
            exit 0
        fi
        printf "{\"timestamp\":\"%s\",\"level\":\"INFO\",\"script\":\"child-step.sh\",\"pid\":%d,\"correlation_id\":\"%s\",\"message\":\"child step finished\"}\n" \
            "$(date -u "+%Y-%m-%dT%H:%M:%S.%3NZ")" "$$" "$CORRELATION_ID"
    '

    log_info "Script completed successfully"
}

main "$@"
```

## Verify

Run these against the script under review. Every expected value below was
produced by executing the template.

### Static gate

```bash
bash -n runbook.sh          # syntax check
shellcheck -x runbook.sh    # static analysis; must exit 0
```

### Strict-mode semantics

```bash
# A plain assignment from a failing substitution aborts the script.
bash -c 'set -euo pipefail; result=$(false); echo "not reached"'
echo "exit=$?"    # exit=1, and "not reached" was not printed

# `local` masks the same failure.
bash -c 'set -euo pipefail; f() { local v=$(false); echo "still running"; }; f'
echo "exit=$?"    # prints "still running", exit=0
```

### Cleanup runs exactly once

```bash
# Normal completion: one cleanup line.
./runbook.sh | grep -c 'Cleanup finished'
# 1

# SIGTERM: the script exits 143 and the cleanup still runs only once.
WORK_DELAY=5 ./runbook.sh > /tmp/run.log 2>&1 &
pid=$!
sleep 1
kill -TERM "$pid"
wait "$pid"
echo "exit=$?"                          # exit=143
grep -c 'Cleanup finished' /tmp/run.log
# 1
```

### Log contract

```bash
# Every line is a JSON object with the agreed key set.
./runbook.sh | jq -e 'has("timestamp") and has("level") and has("correlation_id") and has("message")' >/dev/null \
  && echo "shape ok"
# shape ok

# One correlation id for the whole run, including the child step.
./runbook.sh | jq -r '.correlation_id' | sort -u | wc -l
# 1

# The threshold filters the levels.
LOG_LEVEL=WARN ./runbook.sh | jq -r '.level' | sort -u
# WARN

# Verbose mode raises the threshold to DEBUG.
./runbook.sh --verbose | jq -r '.level' | sort -u | tr '\n' ' '
# DEBUG INFO WARN
```

### Argument handling

```bash
./runbook.sh --help          # usage text, exit 0
./runbook.sh --nope          # "error: unknown option: --nope", exit 2
./runbook.sh --config        # "error: --config requires a path", exit 2
LOG_LEVEL=TRACE ./runbook.sh # "error: unknown LOG_LEVEL: TRACE", exit 2
```

## Rollback

1. **Stop the run**: send `SIGTERM`. The cleanup handler removes the temporary
   work directory and the script exits 143.
2. **Recover state after a hard kill**: `SIGKILL` never runs the handler
   (`SIGSTOP` only suspends the process), so the work directory can survive a
   hard kill. Its path is in the `DEBUG` line `Work directory: …`; remove it
   manually.
3. **Fall back to plain strict mode**: delete the `trap` lines, the
   `CLEANUP_DONE`/`RUN_STATE` state and the `cleanup` function. The remaining
   script still runs with `set -euo pipefail`; it just stops cleaning up.
4. **Reduce the noise**: `LOG_LEVEL=INFO` (the default) or `LOG_LEVEL=WARN`
   drops the `DEBUG` lines without touching the code.

## Common Errors

| Symptom | Cause | Resolution |
|---------|-------|------------|
| Script exits 1 on a line that looks harmless | `errexit` aborts on any unhandled non-zero status, including a plain assignment from a command substitution | Put the command in a tested context (`if`, `\|\|`) or handle the status explicitly |
| A failure disappears inside a function | `local value=$(cmd)` — `local` returns 0 and masks the substitution's status | Declare first, assign on the next line |
| Cleanup actions run twice | The `EXIT` trap and the signal trap call the same handler, and the handler's `exit` fires the `EXIT` trap again | Guard the handler with a "done" flag, as in the template |
| The exit code is not the one the step failed with | `errexit` is still in force inside the trap handler, so a failing cleanup step aborts it | `set +e` at the top of the handler and report failures on stderr |
| Log lines are not valid JSON | The message was interpolated without escaping | Build the value with `jq -n --arg`, or use the `json_escape` fallback |
| The log gate rejects the script's own output | The script emits a different key set than the gate expects | Keep one key set and change the producer and the gate together |
| Child steps log under a different trace id | The correlation id was generated but not exported | `export CORRELATION_ID` in the parent; children inherit it |
| `LOG_LEVEL=WARN` still shows `INFO` lines from a child | The child applies its own threshold | Export `LOG_LEVEL` and `LOG_THRESHOLD` so the child inherits the parent's verbosity |
| The timestamp contains a literal `%3N` | The millisecond format needs GNU `date` | Use `date -u +%FT%TZ` where GNU `date` is unavailable |
| The script ignores `SIGTERM` | The signal went to a wrapper process that does not forward it | `exec` the script in the entrypoint so the script itself receives the signal |

## References

- [production-reference-patterns](production-reference-patterns.md) — shell
  options, variable validation, dependency checks, signal traps, process
  substitution, coprocesses and an idempotency guard.
- [strict-mode-trap-patterns](strict-mode-trap-patterns.md) — strict mode and
  trap-based cleanup wired into a real script, including the subshell and
  arithmetic-comparison gotchas.
- [production-runbook-strict-mode-pipestatus-shellcheck-ci-gate](production-runbook-strict-mode-pipestatus-shellcheck-ci-gate.md)
  — `PIPESTATUS` capture patterns and the ShellCheck CI gate.
- [2026-07-23-robust-bash-scripts](2026-07-23-robust-bash-scripts.md) — a
  personal checklist of everyday Bash mistakes.
