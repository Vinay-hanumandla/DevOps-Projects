#!/usr/bin/env bash
# last_verified: 2026-07-30 · bash n/a

set -euo pipefail

usage() {
    printf 'Usage: %s <directory> [options]\n' "$(basename "$0")"
    printf '\nBuild a system report from the contents of a target directory.\n\n'
    printf 'Options:\n'
    printf '  -o, --output FILE    Write report to FILE instead of stdout\n'
    printf '  -f, --format FORMAT  Output format: text (default) or json\n'
    printf '  -h, --help           Show this help message and exit\n'
}

report_format="text"
output_file=""
target_dir=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)
            output_file="$2"
            shift 2
            ;;
        -f|--format)
            report_format="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            if [[ -z "$target_dir" ]]; then
                target_dir="$1"
                shift
            else
                printf 'Error: unexpected argument %s\n' "$1" >&2
                usage >&2
                exit 1
            fi
            ;;
    esac
done

if [[ -z "$target_dir" ]]; then
    printf 'Error: a target directory is required\n' >&2
    usage >&2
    exit 1
fi

if [[ ! -d "$target_dir" ]]; then
    printf 'Error: %s is not a directory\n' "$target_dir" >&2
    exit 1
fi

abs_dir="$(cd "$target_dir" && pwd)"

count_files() {
    find "$1" -type f 2>/dev/null | wc -l
}

count_dirs() {
    find "$1" -type d 2>/dev/null | wc -l
}

total_size() {
    du -sh "$1" 2>/dev/null | cut -f1
}

oldest_file() {
    find "$1" -type f -printf '%T+ %p\n' 2>/dev/null | sort | head -1 | cut -d' ' -f2-
}

newest_file() {
    find "$1" -type f -printf '%T+ %p\n' 2>/dev/null | sort -r | head -1 | cut -d' ' -f2-
}

largest_file() {
    find "$1" -type f -printf '%s %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-
}

generate_text_report() {
    local dir="$1"
    printf '=== System Report: %s ===\n\n' "$dir"
    printf 'Generated: %s\n\n' "$(date -Iseconds)"
    printf 'Directory Summary\n'
    printf '-----------------\n'
    printf 'Total files:      %s\n' "$(count_files "$dir")"
    printf 'Total directories: %s\n' "$(count_dirs "$dir")"
    printf 'Total size:        %s\n' "$(total_size "$dir")"
    printf 'Oldest file:       %s\n' "$(oldest_file "$dir")"
    printf 'Newest file:       %s\n' "$(newest_file "$dir")"
    printf 'Largest file:      %s\n' "$(largest_file "$dir")"
    printf '\nFile Type Breakdown\n'
    printf '-------------------\n'
    find "$dir" -type f -printf '%f\n' 2>/dev/null | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -10 | while read -r count ext; do
        printf '  .%s: %s files\n' "$ext" "$count"
    done
}

generate_json_report() {
    local dir="$1"
    printf '{\n'
    printf '  "directory": "%s",\n' "$dir"
    printf '  "generated": "%s",\n' "$(date -Iseconds)"
    printf '  "total_files": %s,\n' "$(count_files "$dir")"
    printf '  "total_directories": %s,\n' "$(count_dirs "$dir")"
    printf '  "total_size": "%s",\n' "$(total_size "$dir")"
    printf '  "oldest_file": "%s",\n' "$(oldest_file "$dir")"
    printf '  "newest_file": "%s",\n' "$(newest_file "$dir")"
    printf '  "largest_file": "%s"\n' "$(largest_file "$dir")"
    printf '}\n'
}

if [[ "$report_format" == "json" ]]; then
    report="$(generate_json_report "$abs_dir")"
else
    report="$(generate_text_report "$abs_dir")"
fi

if [[ -n "$output_file" ]]; then
    printf '%s\n' "$report" > "$output_file"
    printf 'Report written to %s\n' "$output_file"
else
    printf '%s\n' "$report"
fi