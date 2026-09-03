#!/usr/bin/env bash
# last_verified: 2026-09-03 · prometheus n/a

# prom-query.sh — Reusable Prometheus query helper
# Fetches PromQL results via the HTTP API and formats them for terminal or pipe.
#
# Usage:
#   ./prom-query.sh 'up'
#   ./prom-query.sh 'rate(http_requests_total[5m])' --format table
#   ./prom-query.sh 'up' --server http://prometheus:9090 --output json
#   PROMQL='up' ./prom-query.sh

PROM_SERVER="${PROM_SERVER:-http://localhost:9090}"
OUTPUT_FORMAT="table"

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [QUERY]

Fetch PromQL results from Prometheus HTTP API.

Arguments:
  QUERY              PromQL query string (or set PROMQL env var)

Options:
  -s, --server URL   Prometheus server URL (default: \$PROM_SERVER or http://localhost:9090)
  -f, --format FMT   Output format: table (default), json, csv
  -t, --time  TS     Evaluation timestamp (RFC 3339 or Unix seconds)
  -h, --help         Show this help
EOF
  exit 0
}

log_info()  { echo "[INFO]  $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }

# Parse arguments
QUERY=""
EVAL_TIME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--server) PROM_SERVER="$2"; shift 2 ;;
    -f|--format) OUTPUT_FORMAT="$2"; shift 2 ;;
    -t|--time)   EVAL_TIME="$2"; shift 2 ;;
    -h|--help)   usage ;;
    -*)          log_error "Unknown option: $1"; usage ;;
    *)           QUERY="$1"; shift ;;
  esac
done

QUERY="${QUERY:-${PROMQL:-}}"

if [[ -z "$QUERY" ]]; then
  log_error "No query provided. Pass a PromQL string or set PROMQL."
  usage
fi

# Make the request
log_info "Querying ${PROM_SERVER} ..."

EXTRA_ARGS=()
if [[ -n "$EVAL_TIME" ]]; then
  EXTRA_ARGS+=("--data-urlencode" "time=${EVAL_TIME}")
fi

RESPONSE=$(curl -sf --data-urlencode "query=${QUERY}" \
  "${EXTRA_ARGS[@]}" \
  "${PROM_SERVER}/api/v1/query" 2>/dev/null) || {
  log_error "Failed to reach Prometheus at ${PROM_SERVER}"
  exit 1
}

# Check API status
STATUS=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status',''))" 2>/dev/null || echo "")
if [[ "$STATUS" != "success" ]]; then
  ERROR=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('error','unknown error'))" 2>/dev/null || echo "unknown error")
  log_error "API returned error: ${ERROR}"
  exit 1
fi

# Format output
format_table() {
  echo "$RESPONSE" | python3 -c "
import sys, json

data = json.load(sys.stdin)
results = data.get('data', {}).get('result', [])

if not results:
    print('No results found.')
    sys.exit(0)

# Print header
labels = set()
for r in results:
    labels.update(r.get('metric', {}).keys())
labels.discard('__name__')
labels = sorted(labels)

if labels:
    print(f'{'Labels':<40} {'Value':>20}  Timestamp')
    print('-' * 80)
else:
    print(f'{'Value':>20}  Timestamp')
    print('-' * 40)

for r in results:
    metric = r.get('metric', {})
    value = r.get('value', [None, ''])[1]
    ts = r.get('value', [None, ''])[0]

    if labels:
        label_str = ', '.join(f'{k}={metric.get(k, \"\")}' for k in labels)
        if len(label_str) > 38:
            label_str = label_str[:35] + '...'
        print(f'{label_str:<40} {value:>20}  {ts}')
    else:
        print(f'{value:>20}  {ts}')
"
}

format_json() {
  echo "$RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
results = data.get('data', {}).get('result', [])
print(json.dumps(results, indent=2))
"
}

format_csv() {
  echo "$RESPONSE" | python3 -c "
import sys, json, csv

data = json.load(sys.stdin)
results = data.get('data', {}).get('result', [])

if not results:
    sys.exit(0)

labels = set()
for r in results:
    labels.update(r.get('metric', {}).keys())
labels.discard('__name__')
labels = sorted(labels)

writer = csv.writer(sys.stdout)
writer.writerow(['metric'] + labels + ['value', 'timestamp'])

for r in results:
    metric = r.get('metric', {})
    name = metric.get('__name__', '')
    value = r.get('value', [None, ''])[1]
    ts = r.get('value', [None, ''])[0]
    label_vals = [metric.get(l, '') for l in labels]
    writer.writerow([name] + label_vals + [value, ts])
"
}

case "$OUTPUT_FORMAT" in
  json) format_json ;;
  csv)  format_csv ;;
  *)    format_table ;;
esac
