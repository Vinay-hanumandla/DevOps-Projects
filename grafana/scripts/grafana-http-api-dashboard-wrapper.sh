#!/usr/bin/env bash
# last_verified: 2026-09-19 · Grafana n/a

# Grafana HTTP API wrapper — list, create, and delete dashboards idempotently.
# Usage: ./grafana-http-api-dashboard-wrapper.sh {list|create|delete} [args]
# Requires: curl, jq, and a Grafana API key with dashboard admin permissions.

set -euo pipefail

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
API_KEY="${GRAFANA_API_KEY:?GRAFANA_API_KEY must be set}"
HEADERS=(
    "Authorization: Bearer ${API_KEY}"
    "Content-Type: application/json"
    "Accept: application/json"
)

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >&2
}

dashboard_exists() {
    local uid="$1"
    local response
    response=$(curl -sf -X GET "${GRAFANA_URL}/api/dashboards/uid/${uid}" \
        -H "${HEADERS[@]}" 2>/dev/null || echo "")
    if [[ -n "${response}" ]]; then
        echo "${response}" | jq -e '.meta.id' >/dev/null 2>&1
    else
        return 1
    fi
}

cmd_list() {
    local response
    response=$(curl -sf -X GET "${GRAFANA_URL}/api/search" \
        -H "${HEADERS[@]}" \
        -H "X-Grafana-Org-Id: 1" \
        -H "Type: dash-db" || true)

    if [[ -z "${response}" ]]; then
        log "No dashboards found or failed to connect."
        return 0
    fi

    echo "${response}" | jq -r '.[] | "\(.id)\t\(.title)\t\(.uid)"' | \
        column -t -s $'\t'
}

cmd_create() {
    local dashboard_file="$1"

    if [[ ! -f "${dashboard_file}" ]]; then
        log "Dashboard file not found: ${dashboard_file}"
        return 1
    fi

    local uid
    uid=$(jq -r '.uid' "${dashboard_file}")

    if [[ -z "${uid}" || "${uid}" == "null" ]]; then
        log "Dashboard file missing uid field: ${dashboard_file}"
        return 1
    fi

    if dashboard_exists "${uid}"; then
        log "Dashboard with uid '${uid}' already exists — updating."
        local existing_id
        existing_id=$(curl -sf -X GET "${GRAFANA_URL}/api/dashboards/uid/${uid}" \
            -H "${HEADERS[@]}" | jq -r '.dashboard.id')

        curl -sf -X POST "${GRAFANA_URL}/api/dashboards/${existing_id}" \
            -H "${HEADERS[@]}" \
            -d @"${dashboard_file}" >/dev/null

        log "Dashboard '${uid}' updated successfully."
    else
        log "Dashboard with uid '${uid}' does not exist — creating."
        curl -sf -X POST "${GRAFANA_URL}/api/dashboards/uid/${uid}" \
            -H "${HEADERS[@]}" \
            -d @"${dashboard_file}" >/dev/null

        log "Dashboard '${uid}' created successfully."
    fi
}

cmd_delete() {
    local uid="$1"

    if ! dashboard_exists "${uid}"; then
        log "Dashboard with uid '${uid}' does not exist — nothing to delete."
        return 0
    fi

    local dashboard_id
    dashboard_id=$(curl -sf -X GET "${GRAFANA_URL}/api/dashboards/uid/${uid}" \
        -H "${HEADERS[@]}" | jq -r '.dashboard.id')

    curl -sf -X DELETE "${GRAFANA_URL}/api/dashboards/${dashboard_id}" \
        -H "${HEADERS[@]}" >/dev/null

    log "Dashboard '${uid}' (id: ${dashboard_id}) deleted."
}

usage() {
    cat <<EOF
Usage: ${0##*/} {list|create|delete} [args]

Commands:
  list                    List all dashboards.
  create <file.json>      Create or update a dashboard from a JSON file (idempotent).
  delete <uid>            Delete a dashboard by its UID (safe — no-op if absent).

Environment:
  GRAFANA_URL     Grafana base URL (default: http://localhost:3000)
  GRAFANA_API_KEY API key with dashboard admin permissions (required)
EOF
}

main() {
    local action="${1:-}"

    case "${action}" in
        list)
            cmd_list
            ;;
        create)
            cmd_create "${2:?Dashboard file path required}"
            ;;
        delete)
            cmd_delete "${2:?Dashboard UID required}"
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"
