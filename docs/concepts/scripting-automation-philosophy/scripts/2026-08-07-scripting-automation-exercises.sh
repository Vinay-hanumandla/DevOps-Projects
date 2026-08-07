#!/usr/bin/env bash
# last_verified: 2026-08-07 · scripting-automation-philosophy n/a

# I wrote this script to practice the scripting/automation philosophy habits
# from the concept primer: DRY helper functions, idempotency (check before
# acting so re-runs don't fail), clear exit codes, and breaking work into
# small orchestrated steps.
#
# The job: ensure a project's logs/ directory and .gitkeep exist, then
# count how many stale .log files are sitting around for cleanup.

PROJECT_DIR="${1:-$HOME/projects/demo-app}"
LOG_DIR="$PROJECT_DIR/logs"

# DRY: one log function replaces a dozen copy-pasted echo lines.
log() {
    printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"
}

# Idempotency: mkdir -p won't error if the dir already exists, and I check
# first to log the right message. Either way, re-running is safe.
ensure_log_dir() {
    if [ -d "$LOG_DIR" ]; then
        log "log dir already exists: $LOG_DIR"
    else
        mkdir -p "$LOG_DIR"
        log "created log dir: $LOG_DIR"
    fi
}

# Idempotency: touch won't error if the file is already there. Same idea —
# safe to re-run, no blind append.
ensure_gitkeep() {
    local keep="$LOG_DIR/.gitkeep"
    if [ -f "$keep" ]; then
        log ".gitkeep already present"
    else
        touch "$keep"
        log "added .gitkeep so git tracks the empty dir"
    fi
}

# Read-only inspection: count old logs. find + wc is safe to run anytime.
count_old_logs() {
    local days="${1:-7}"
    local count
    count=$(find "$LOG_DIR" -name '*.log' -type f -mtime +"$days" 2>/dev/null | wc -l)
    log "log files older than ${days}d: ${count}"
}

# --- orchestrate the steps ---
log "starting scripting automation exercises"
ensure_log_dir
ensure_gitkeep
count_old_logs "${2:-7}"
log "all steps done — idempotent, re-run any time"
exit 0
