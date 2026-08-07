#!/usr/bin/env bash
# last_verified: 2026-08-07 · Observability & Monitoring Concepts n/a

# observability-cicd-pipeline-metric-collection-probes.sh
#
# Collects CI/CD pipeline metrics (run duration, pass/fail status, artifact size)
# and exports them to a Prometheus pushgateway or compatible metrics endpoint.
# Demonstrates how observability probes fit into a pipeline automation pattern.

set -o pipefail

if [[ -z "${METRICS_ENDPOINT:-}" ]]; then
  log "ERROR: METRICS_ENDPOINT is required"
  exit 1
fi

PIPELINE_ID="${PIPELINE_ID:-local}"
ARTIFACT_DIR="${ARTIFACT_DIR:-./artifacts}"

log() {
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*"
}

collect_duration() {
  local start_file="$1"
  local end_file="$2"
  if [[ -f "$start_file" && -f "$end_file" ]]; then
    local start_ts end_ts
    start_ts=$(stat -c %Y "$start_file" 2>/dev/null) || return 1
    end_ts=$(stat -c %Y "$end_file" 2>/dev/null) || return 1
    if [[ -n "$start_ts" && -n "$end_ts" ]]; then
      echo "pipeline_duration_seconds $(( end_ts - start_ts ))"
    fi
  fi
}

collect_artifact_size() {
  if [[ -d "$ARTIFACT_DIR" ]]; then
    local total_size
    total_size=$(du -sb "$ARTIFACT_DIR" 2>/dev/null | cut -f1)
    if [[ -n "$total_size" ]]; then
      echo "pipeline_artifact_bytes $total_size"
    fi
  fi
}

main() {
  if [[ -z "${PIPELINE_STATUS:-}" ]]; then
    log "WARN: PIPELINE_STATUS is unset; defaulting to unknown"
  fi

  log "Starting metric collection for pipeline ${PIPELINE_ID}"

  local metrics_payload
  metrics_payload=$(mktemp)
  trap 'rm -f "$metrics_payload"' EXIT

  {
    echo "# HELP pipeline_duration_seconds Total duration of the CI/CD pipeline run"
    echo "# TYPE pipeline_duration_seconds gauge"
    collect_duration ".pipeline_start" ".pipeline_end" || true

    echo "# HELP pipeline_artifact_bytes Total size of pipeline artifacts"
    echo "# TYPE pipeline_artifact_bytes gauge"
    collect_artifact_size || true

    echo "# HELP pipeline_status Pipeline pass (1) or fail (0)"
    echo "# TYPE pipeline_status gauge"
    if [[ "${PIPELINE_STATUS:-}" == "success" ]]; then
      echo "pipeline_status 1"
    else
      echo "pipeline_status 0"
    fi
  } > "$metrics_payload"

  if [[ -s "$metrics_payload" ]]; then
    if command -v curl >/dev/null 2>&1; then
      curl -s --post-data "$(cat "$metrics_payload")" "$METRICS_ENDPOINT" \
        || log "WARN: failed to push metrics to ${METRICS_ENDPOINT}"
    else
      log "WARN: curl not found; metrics payload retained at ${metrics_payload}"
    fi
  else
    log "WARN: no metrics collected"
  fi

  log "Metric collection complete"
}

main "$@"
