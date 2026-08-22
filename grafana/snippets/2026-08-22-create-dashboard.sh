#!/usr/bin/env bash
# last_verified: 2026-08-22 · grafana n/a
# Creates a basic Grafana dashboard via the HTTP API using curl.
# Following the Grafana quickstart — wanted to see the API actually work.

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
API_KEY="${GRAFANA_API_KEY:-}"

if [[ -z "$API_KEY" ]]; then
    echo "Set GRAFANA_API_KEY env var first (Admin API key from Grafana UI)"
    exit 1
fi

# Create a dashboard with a single stat panel
curl -s -X POST "${GRAFANA_URL}/api/dashboards/db" \
    -H "Authorization: Bearer ${API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
        "dashboard": {
            "title": "My First Dashboard",
            "panels": [
                {
                    "type": "stat",
                    "title": "Uptime",
                    "gridPos": { "h": 8, "w": 12, "x": 0, "y": 0 },
                    "targets": [
                        {
                            "expr": "process_uptime_seconds",
                            "legendFormat": "{{job}}"
                        }
                    ]
                }
            ],
            "time": { "from": "now-1h", "to": "now" }
        },
        "overwrite": true
    }' | python3 -m json.tool 2>/dev/null || cat

echo ""
echo "Dashboard created — check ${GRAFANA_URL}/dashboards"
