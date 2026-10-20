---
last_verified: 2026-10-20
tool_version: n/a
sources: []
---

# Bash Production Runbook

## Purpose

This document provides authoritative reference patterns for writing production-grade Bash scripts. It covers the essential safety flags (`set -euo pipefail`), robust signal handling, and structured logging approaches that distinguish fragile one-off scripts from maintainable automation.

## When to Use

Apply these patterns to any Bash script that:
- Runs unattended in CI/CD pipelines, cron jobs, or systemd services
- Manages infrastructure, deployments, or data processing where silent failures are costly
- Must operate reliably across different environments and Bash versions (4.0+)
- Needs observable, debuggable execution without manual intervention

## Prerequisites

- Bash 4.0 or later (for associative arrays, `mapfile`, and modern parameter expansion)
- Understanding of exit codes, file descriptors, and process signals
- Access to standard Unix utilities (`date`, `printf`, `tee`, `logger`)

## Core Safety Flags

### `set -euo pipefail`

```bash
#!/usr/bin/env bash
set -euo pipefail
```

| Flag | Effect | Why It Matters |
|------|--------|----------------|
| `-e` (errexit) | Exit immediately when a command exits non-zero | Prevents cascading failures from silently ignored errors |
| `-u` (nounset) | Treat unset variables as an error when expanding | Catches typos in variable names before they cause damage |
| `-o pipefail` | Pipeline returns the exit code of the rightmost non-zero command | Ensures `cmd1 | cmd2` fails if `cmd1` fails, not just `cmd2` |

**Placement**: Place at the top of the script, after the shebang, before any other code.

### Scope Limitations

The `errexit` flag does not trigger in these contexts (by design):

```bash
# Command in a conditional — exit code is tested, not fatal
if ! grep -q "pattern" file.txt; then
    echo "Pattern not found"
fi

# Command in a subshell — parent script continues
result=$(false)  # Subshell fails, but assignment succeeds

# Command followed by || or && — explicit handling
risky_command || handle_failure
```

**Best practice**: Avoid relying on these exceptions. Use explicit error handling instead.

## Signal Handling

### Signal Overview

| Signal | Number | Default Action | Typical Use |
|--------|--------|----------------|-------------|
| `SIGHUP` | 1 | Terminate | Terminal closed, reload config |
| `SIGINT` | 2 | Terminate | Ctrl+C, graceful shutdown |
| `SIGTERM` | 15 | Terminate | Polite shutdown request (systemd, Kubernetes) |
| `SIGUSR1` | 10 | Terminate | User-defined (e.g., rotate logs) |
| `SIGUSR2` | 12 | Terminate | User-defined (e.g., dump state) |

### Trap Patterns

#### Minimal Graceful Shutdown

```bash
#!/usr/bin/env bash
set -euo pipefail

cleanup() {
    local exit_code=$?
    log_info "Shutting down (exit code: $exit_code)"
    # Release locks, close connections, remove temp files
    rm -f "${LOCK_FILE:-}"
    exit "$exit_code"
}

trap cleanup EXIT
trap 'cleanup; exit 130' INT   # 128 + SIGINT(2) = 130
trap 'cleanup; exit 143' TERM  # 128 + SIGTERM(15) = 143
```

#### Idempotent Cleanup with State Tracking

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -A CLEANUP_ACTIONS=()

register_cleanup() {
    local name="$1"
    local action="$2"
    CLEANUP_ACTIONS["$name"]="$action"
}

run_cleanup() {
    local exit_code=$1
    for name in "${!CLEANUP_ACTIONS[@]}"; do
        log_debug "Running cleanup: $name"
        eval "${CLEANUP_ACTIONS[$name]}" || log_warn "Cleanup '$name' failed"
    done
    exit "$exit_code"
}

trap 'run_cleanup $?' EXIT
trap 'run_cleanup 130' INT
trap 'run_cleanup 143' TERM

# Usage example
register_cleanup "lock" "rm -f /var/lock/my-script.lock"
register_cleanup "tempdir" "rm -rf /tmp/my-script-$$"
```

#### Reload Configuration on SIGHUP

```bash
reload_config() {
    log_info "Received SIGHUP, reloading configuration"
    # Re-read config file, re-establish connections
    source /etc/my-script/config.conf
    reconnect_services
}

trap reload_config HUP
```

### Signal Safety Rules

1. **Keep trap handlers minimal** — they run asynchronously; avoid complex logic, I/O, or locks
2. **Use async-signal-safe functions only** — `printf`, `exit`, variable assignment are safe; most library calls are not
3. **Re-arm traps if needed** — some signals reset handlers on delivery (not typical in Bash)
4. **Preserve original exit code** — capture `$?` immediately in `EXIT` trap

## Structured Logging

### Log Levels

| Level | Numeric | Use Case |
|-------|---------|----------|
| `DEBUG` | 10 | Verbose diagnostic detail |
| `INFO` | 20 | Normal operational events |
| `WARN` | 30 | Unexpected but handled situations |
| `ERROR` | 40 | Failures requiring attention |
| `CRITICAL` | 50 | Immediate intervention needed |

### JSON Structured Logger

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly LOG_LEVEL="${LOG_LEVEL:-INFO}"
readonly LOG_FORMAT="${LOG_FORMAT:-json}"  # json or text

declare -A LOG_LEVEL_NUM=(
    [DEBUG]=10
    [INFO]=20
    [WARN]=30
    [ERROR]=40
    [CRITICAL]=50
)

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
    local script_name="${0##*/}"
    local pid=$$

    if (( LOG_LEVEL_NUM["$level"] < LOG_LEVEL_NUM["$LOG_LEVEL"] )); then
        return 0
    fi

    if [[ "$LOG_FORMAT" == "json" ]]; then
        printf '{"timestamp":"%s","level":"%s","script":"%s","pid":%d,"message":%s}\n' \
            "$timestamp" "$level" "$script_name" "$pid" "$(jq -n --arg msg "$message" '$msg')"
    else
        printf '[%s] %-8s [%s:%d] %s\n' "$timestamp" "$level" "$script_name" "$pid" "$message"
    fi
}

log_debug() { log DEBUG "$@"; }
log_info()  { log INFO  "$@"; }
log_warn()  { log WARN  "$@"; }
log_error() { log ERROR "$@"; }
log_critical() { log CRITICAL "$@"; }
```

**Dependencies**: Requires `jq` for JSON escaping. For zero-dependency environments, use a pure-Bash escape function:

```bash
json_escape() {
    local str="$1"
    str=${str//\\/\\\\}
    str=${str//\"/\\\"}
    str=${str//$'\n'/\\n}
    str=${str//$'\r'/\\r}
    str=${str//$'\t'/\\t}
    printf '%s' "$str"
}

# In log(): replace jq line with:
# "$(json_escape "$message")"
```

### Contextual Logging with Correlation IDs

```bash
#!/usr/bin/env bash
set -euo pipefail

CORRELATION_ID="${CORRELATION_ID:-$(uuidgen 2>/dev/null || printf '%x' $RANDOM$RANDOM$RANDOM)}"
export CORRELATION_ID

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
    printf '{"timestamp":"%s","level":"%s","correlation_id":"%s","message":%s}\n' \
        "$timestamp" "$level" "$CORRELATION_ID" "$(jq -n --arg msg "$message" '$msg')"
}
```

### Structured Log Output Example

```json
{"timestamp":"2026-10-20T14:32:15.123Z","level":"INFO","correlation_id":"a1b2c3d4","message":"Starting deployment to production"}
{"timestamp":"2026-10-20T14:32:15.456Z","level":"DEBUG","correlation_id":"a1b2c3d4","message":"Validating manifest: /manifests/prod.yaml"}
{"timestamp":"2026-10-20T14:32:16.789Z","level":"WARN","correlation_id":"a1b2c3d4","message":"Resource limit not set for container 'app', using defaults"}
{"timestamp":"2026-10-20T14:32:18.012Z","level":"INFO","correlation_id":"a1b2c3d4","message":"Deployment completed successfully"}
```

## Integrated Runbook Template

```bash
#!/usr/bin/env bash
# Production-grade Bash script template
# last_verified: 2026-10-20 · bash 5.2

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================
readonly SCRIPT_NAME="${0##*/}"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_LEVEL="${LOG_LEVEL:-INFO}"
readonly LOG_FORMAT="${LOG_FORMAT:-json}"
readonly CORRELATION_ID="${CORRELATION_ID:-$(uuidgen 2>/dev/null || printf '%x' $RANDOM$RANDOM$RANDOM)}"
export CORRELATION_ID

# ============================================================================
# LOGGING
# ============================================================================
declare -A LOG_LEVEL_NUM=(
    [DEBUG]=10 [INFO]=20 [WARN]=30 [ERROR]=40 [CRITICAL]=50
)

log() {
    local level="$1"; shift
    local msg="$*"
    local ts; ts=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
    (( LOG_LEVEL_NUM["$level"] < LOG_LEVEL_NUM["$LOG_LEVEL"] )) && return 0
    if [[ "$LOG_FORMAT" == "json" ]]; then
        printf '{"ts":"%s","lvl":"%s","cid":"%s","msg":%s}\n' \
            "$ts" "$level" "$CORRELATION_ID" "$(jq -n --arg m "$msg" '$m')"
    else
        printf '[%s] %-8s [%s] %s\n' "$ts" "$level" "$CORRELATION_ID" "$msg"
    fi
}
log_debug() { log DEBUG "$@"; }
log_info()  { log INFO  "$@"; }
log_warn()  { log WARN  "$@"; }
log_error() { log ERROR "$@"; }
log_critical() { log CRITICAL "$@"; }

# ============================================================================
# STATE & CLEANUP
# ============================================================================
declare -A CLEANUP_ACTIONS=()
register_cleanup() { CLEANUP_ACTIONS["$1"]="$2"; }

cleanup() {
    local ec=$1
    for action in "${CLEANUP_ACTIONS[@]}"; do
        eval "$action" 2>/dev/null || log_warn "Cleanup action failed: $action"
    done
    exit "$ec"
}

trap 'cleanup $?' EXIT
trap 'cleanup 130' INT
trap 'cleanup 143' TERM

# ============================================================================
# HELPERS
# ============================================================================
usage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]
Options:
  -h, --help       Show this help
  -v, --verbose    Enable debug logging
  -c, --config     Config file path (default: /etc/$SCRIPT_NAME.conf)
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) usage; exit 0 ;;
            -v|--verbose) LOG_LEVEL=DEBUG ;;
            -c|--config) CONFIG_FILE="$2"; shift ;;
            *) log_error "Unknown option: $1"; usage; exit 1 ;;
        esac
        shift
    done
}

# ============================================================================
# MAIN
# ============================================================================
main() {
    parse_args "$@"
    log_info "Starting $SCRIPT_NAME"

    # Load configuration
    if [[ -f "${CONFIG_FILE:-/etc/$SCRIPT_NAME.conf}" ]]; then
        # shellcheck source=/dev/null
        source "${CONFIG_FILE:-/etc/$SCRIPT_NAME.conf}"
        log_info "Loaded config from ${CONFIG_FILE:-/etc/$SCRIPT_NAME.conf}"
    fi

    # Acquire lock
    LOCK_FILE="/var/lock/$SCRIPT_NAME.lock"
    if ! mkdir "$LOCK_FILE" 2>/dev/null; then
        log_error "Another instance is running (lock: $LOCK_FILE)"
        exit 1
    fi
    register_cleanup "lock" "rmdir '$LOCK_FILE'"

    # Do work
    log_info "Work phase started"
    # ... your logic here ...
    log_info "Work phase completed"

    log_info "Script completed successfully"
}

main "$@"
```

## Verify

### Static Analysis

```bash
# Syntax check
bash -n script.sh

# ShellCheck (recommended)
shellcheck -x script.sh

# Check for common anti-patterns
grep -n 'set +e' script.sh       # Should not disable errexit
grep -n '|| true' script.sh      # Should not silently ignore failures
grep -n '2>/dev/null' script.sh  # Should not suppress stderr indiscriminately
```

### Runtime Verification

```bash
# Test signal handling
timeout 2s bash -c 'trap "echo SIGTERM received" TERM; sleep 10' &
sleep 1
kill -TERM $!
wait $!  # Should show "SIGTERM received"

# Test errexit behavior
bash -c 'set -e; false; echo "should not print"'
# Exit code should be 1, no output

# Test pipefail
bash -c 'set -o pipefail; false | true; echo $?'
# Should print 1
```

### Log Output Validation

```bash
# Verify JSON structure
./script.sh | jq -e 'has("ts") and has("lvl") and has("cid") and has("msg")'

# Verify log levels filter correctly
LOG_LEVEL=WARN ./script.sh  # Should not show DEBUG/INFO
LOG_LEVEL=DEBUG ./script.sh # Should show all levels
```

## Rollback

If a script using these patterns causes issues in production:

1. **Immediate**: Send `SIGTERM` to the process — the `cleanup` trap will execute registered actions
2. **State recovery**: Check the correlation ID in logs to trace the execution path
3. **Configuration rollback**: If config was modified, restore from version control or backup
4. **Lock cleanup**: If script crashed before `EXIT` trap, manually remove `/var/lock/script.lock`

## Common Errors

| Error | Cause | Resolution |
|-------|-------|------------|
| `unbound variable` | Referencing unset variable with `set -u` | Initialize all variables; use `${VAR:-default}` for optional ones |
| `command not found` in trap | Function defined after `trap` | Define all trap handlers before setting traps |
| `cleanup` runs twice | `trap EXIT` + explicit `cleanup` call | Only use `trap` for cleanup; don't call manually |
| `SIGTERM` ignored in Docker | PID 1 doesn't receive signals by default | Use `exec` in Dockerfile or `tini`/`dumb-init` as entrypoint |
| JSON logs malformed | Unescaped newlines/quotes in messages | Use `jq -n --arg` or pure-Bash escape function |
| `pipefail` masks expected failures | `grep` returns 1 when no match | Use `grep -q || true` or handle explicitly |

## References

- Bash Manual: [The Set Builtin](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)
- Bash Manual: [Signals](https://www.gnu.org/software/bash/manual/html_node/Signals.html)
- ShellCheck: [Automated Shell Script Analysis](https://www.shellcheck.net/)
- Google Shell Style Guide: [Error Handling](https://google.github.io/styleguide/shellguide.html#s4.2-error-handling)
- 12-Factor App: [Logs](https://12factor.net/logs) — structured logging rationale