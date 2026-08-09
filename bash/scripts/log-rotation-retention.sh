#!/usr/bin/env bash
# last_verified: 2026-08-09 · bash 5.3
#
# Log rotation and retention script.
# Compresses log files older than --compress days with gzip, then removes
# any log file older than --retention days (covering both .log and .log.gz).
#
# This is one way to do log rotation in Bash; logrotate remains the
# standard tool for complex setups. This script covers the common case:
# flat log directories on Linux with GNU find/coreutils.
set -euo pipefail

# ── defaults ──
readonly DEFAULT_RETENTION=14
readonly DEFAULT_COMPRESS=7

retention_days="$DEFAULT_RETENTION"
compress_days="$DEFAULT_COMPRESS"
verbose=false
log_dir=""

usage() {
    cat <<EOF
Usage: $(basename "$0") <log_dir> [OPTIONS]

Rotate (gzip) and prune log files in a directory.

Options:
  -r, --retention DAYS   Delete logs older than DAYS (default: $DEFAULT_RETENTION)
  -c, --compress DAYS    Gzip logs older than DAYS first (default: $DEFAULT_COMPRESS)
  -v, --verbose          Print each file as it is processed
  -h, --help             Show this help and exit

Examples:
  $(basename "$0") /var/log/nginx
  $(basename "$0") /var/log/nginx -r 30 -c 7 -v
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -r|--retention)
            retention_days="$2"
            shift 2
            ;;
        -c|--compress)
            compress_days="$2"
            shift 2
            ;;
        -v|--verbose)
            verbose=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Error: unknown option '$1'" >&2
            usage >&2
            exit 1
            ;;
        *)
            if [[ -z "$log_dir" ]]; then
                log_dir="$1"
                shift
            else
                echo "Error: unexpected argument '$1'" >&2
                usage >&2
                exit 1
            fi
            ;;
    esac
done

# ── validation ──
if [[ -z "$log_dir" ]]; then
    echo "Error: log directory is required" >&2
    usage >&2
    exit 1
fi

if [[ ! -d "$log_dir" ]]; then
    echo "Error: '$log_dir' is not a directory or does not exist" >&2
    exit 1
fi

# Numeric guards — [[ ]] with regex confirms digits, arithmetic test ensures > 0.
# $(( ... )) is used for increments to avoid the (( x++ )) pitfall where
# exit code 1 on zero-value aborts a set -e script [source: https://www.devopsroles.com/using-bash-scripts-for-devops-automation].
if ! [[ "$retention_days" =~ ^[0-9]+$ ]] || [[ "$retention_days" -eq 0 ]]; then
    echo "Error: --retention must be a positive integer" >&2
    exit 1
fi

if ! [[ "$compress_days" =~ ^[0-9]+$ ]] || [[ "$compress_days" -eq 0 ]]; then
    echo "Error: --compress must be a positive integer" >&2
    exit 1
fi

if [[ "$compress_days" -ge "$retention_days" ]]; then
    echo "Error: --compress days must be less than --retention days" >&2
    exit 1
fi

# Absolute path so find works regardless of CWD.
abs_log_dir="$(cd "$log_dir" && pwd)"

if $verbose; then
    echo "Log directory: $abs_log_dir"
    echo "Retention: $retention_days days | Compress: $compress_days days"
fi

# ── Phase 1: compress old logs ──
# `find -mtime +N` matches files modified more than N*24h ago.
# The -print0 / read -d '' pattern safely handles paths with spaces or
# newlines — never use `for f in $(find …)` [source: https://tutorials.technology/tutorials/bash-scripting-devops-production-2026.html].
compress_count=0
while IFS= read -r -d '' file; do
    if $verbose; then
        echo "  compressing: $file"
    fi
    gzip -f "$file"
    compress_count=$((compress_count + 1))
done < <(find "$abs_log_dir" -maxdepth 1 -type f -name '*.log' -mtime +"$compress_days" -print0)

echo "Compressed $compress_count log file(s) older than $compress_days day(s)."

# ── Phase 2: delete logs past retention ──
# Match both uncompressed (.log) and compressed (.log.gz) files so that
# logs that were never gzipped still get cleaned up.
delete_count=0
while IFS= read -r -d '' file; do
    if $verbose; then
        echo "  deleting: $file"
    fi
    rm -f "$file"
    delete_count=$((delete_count + 1))
done < <(
    find "$abs_log_dir" -maxdepth 1 -type f \
        \( -name '*.log' -o -name '*.log.gz' \) \
        -mtime +"$retention_days" -print0
)

echo "Deleted $delete_count log file(s) older than $retention_days day(s)."
