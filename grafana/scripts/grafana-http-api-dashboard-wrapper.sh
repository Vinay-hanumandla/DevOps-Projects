#!/usr/bin/env bash
# last_verified: 2026-09-19 · Grafana n/a

# Grafana dashboard API wrapper — one CLI for list, idempotent create/update,
# and safe delete of dashboards.
#
# Purpose: fold my earlier one-off API snippets (a list-dashboards curl and a
#   create-dashboard curl) into a single reusable command so everyday dashboard
#   chores stop being copy-pasted curl flags. The new behavior versus those
#   snippets is the update path (same uid + overwrite flag) and delete-by-uid
#   that is a no-op when the dashboard is already gone.
# Usage:
#   GRAFANA_API_KEY=<service-account-token> ./grafana-http-api-dashboard-wrapper.sh list
#   GRAFANA_API_KEY=<token> ./grafana-http-api-dashboard-wrapper.sh create ./dashboard.json
#   GRAFANA_API_KEY=<token> ./grafana-http-api-dashboard-wrapper.sh delete <uid>
# Requires: curl, jq, and a token allowed to manage dashboards.

set -euo pipefail

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
API_KEY="${GRAFANA_API_KEY:?Set GRAFANA_API_KEY to a Grafana service-account token.}"

# One -H flag per header. An earlier version of this script kept the headers in
# an array and passed them as -H "${HEADERS[@]}", which gives curl a single -H
# flag and leaves the remaining headers to be parsed as URLs — every authed
# call failed. Expanding the flags inline here keeps each header attached to
# its own -H.
AUTH_FLAGS=(
    -H "Authorization: Bearer ${API_KEY}"
    -H "Content-Type: application/json"
    -H "Accept: application/json"
)

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >&2
}

# Fetch the full dashboard payload for a uid. Exits nonzero (curl -f) on 404,
# which the callers treat as "does not exist".
get_by_uid() {
    local uid="$1"
    curl -sf -X GET "${GRAFANA_URL}/api/dashboards/uid/${uid}" "${AUTH_FLAGS[@]}"
}

dashboard_exists() {
    get_by_uid "$1" >/dev/null 2>&1
}

cmd_list() {
    local response
    response=$(curl -sf -X GET "${GRAFANA_URL}/api/search?type=dash-db" \
        "${AUTH_FLAGS[@]}")

    if [[ "${response}" == "[]" ]]; then
        log "No dashboards found."
        return 0
    fi

    echo "${response}" | jq -r '.[] | "\(.uid)\t\(.title)"' | \
        column -t -s $'\t'
}

# POST the dashboard through the dashboards-db endpoint with overwrite set, so
# re-running create for the same uid updates instead of erroring. Accepts both
# a raw dashboard object and an exported file shaped like {"dashboard": {...}}.
cmd_create() {
    local dashboard_file="$1"

    if [[ ! -f "${dashboard_file}" ]]; then
        log "Dashboard file not found: ${dashboard_file}"
        return 1
    fi

    local payload uid action
    payload=$(jq '{dashboard: (if has("dashboard") then .dashboard else . end),
                   overwrite: true}' "${dashboard_file}")
    uid=$(echo "${payload}" | jq -r '.dashboard.uid // empty')

    if [[ -n "${uid}" ]] && dashboard_exists "${uid}"; then
        action="Updating"
    else
        action="Creating"
    fi

    log "${action} dashboard '${uid:-<no uid — server assigns one>}'."
    echo "${payload}" | curl -sf -X POST "${GRAFANA_URL}/api/dashboards/db" \
        "${AUTH_FLAGS[@]}" -d @- | jq -r '"status: \(.status), uid: \(.uid)"'
}

cmd_delete() {
    local uid="$1"

    if ! dashboard_exists "${uid}"; then
        log "Dashboard '${uid}' does not exist — nothing to delete."
        return 0
    fi

    curl -sf -X DELETE "${GRAFANA_URL}/api/dashboards/uid/${uid}" \
        "${AUTH_FLAGS[@]}" >/dev/null

    log "Dashboard '${uid}' deleted."
}

usage() {
    cat <<EOF
Usage: ${0##*/} {list|create|delete} [args]

Commands:
  list                    List all dashboards (uid + title).
  create <file.json>      Create or update a dashboard from a JSON file (idempotent).
  delete <uid>            Delete a dashboard by its UID (safe — no-op if absent).

Environment:
  GRAFANA_URL     Grafana base URL (default: http://localhost:3000)
  GRAFANA_API_KEY Service-account token allowed to manage dashboards (required)
EOF
}

# Verify (against a local Grafana):
#   GRAFANA_API_KEY=<token> ./grafana-http-api-dashboard-wrapper.sh list
#   GRAFANA_API_KEY=<token> ./grafana-http-api-dashboard-wrapper.sh create ./dashboard.json
#   GRAFANA_API_KEY=<token> ./grafana-http-api-dashboard-wrapper.sh create ./dashboard.json  # second run updates
#   GRAFANA_API_KEY=<token> ./grafana-http-api-dashboard-wrapper.sh delete <uid>
#   GRAFANA_API_KEY=<token> ./grafana-http-api-dashboard-wrapper.sh delete <uid>             # second run is a no-op

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
