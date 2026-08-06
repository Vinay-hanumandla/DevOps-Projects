#!/usr/bin/env bash
# last_verified: 2026-08-06 · observability-monitoring-concepts n/a

# Observability exercises — L2 practice script
# I wrote this to practice the observability concepts I learned.

echo "=== Observability Exercises ==="
echo ""

# Exercise 1: Check if Prometheus is reachable
echo "--- Exercise 1: Check Prometheus endpoint ---"
if command -v curl >/dev/null; then
  if curl -s -o /dev/null -w "%{http_code}" http://localhost:9090/api/v1/query 2>/dev/null | grep -q "200"; then
    echo "Prometheus is reachable"
  else
    echo "Prometheus is not reachable (expected in local dev)"
  fi
else
  echo "curl not available, skipping Prometheus check"
fi
echo ""

# Exercise 2: Parse a sample metrics file
echo "--- Exercise 2: Parse sample metrics ---"
METRICS_FILE=$(mktemp)
cat > "$METRICS_FILE" <<'EOF'
# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",status="200"} 1423
http_requests_total{method="POST",status="201"} 89
http_requests_total{method="GET",status="500"} 12
# HELP cpu_usage_percent CPU usage percentage
# TYPE cpu_usage_percent gauge
cpu_usage_percent{host="web-1"} 45.2
cpu_usage_percent{host="web-2"} 67.8
EOF

echo "Total HTTP 200 requests:"
grep 'http_requests_total{method="GET",status="200"}' "$METRICS_FILE" | awk '{print $2}'
echo ""

echo "Hosts with CPU > 50%:"
awk '/cpu_usage_percent/ && $NF > 50 {print $1}' "$METRICS_FILE"
echo ""

rm -f "$METRICS_FILE"

# Exercise 3: Simulate a simple alerting rule check
echo "--- Exercise 3: Alert on high error rate ---"
ERROR_RATE=8.5
THRESHOLD=5.0
echo "Error rate: ${ERROR_RATE}%, threshold: ${THRESHOLD}%"
if awk "BEGIN {exit !(${ERROR_RATE} > ${THRESHOLD})}"; then
  echo "ALERT: Error rate exceeds threshold — notify on-call"
else
  echo "OK: Error rate within threshold"
fi
echo ""

echo "=== Exercises complete ==="