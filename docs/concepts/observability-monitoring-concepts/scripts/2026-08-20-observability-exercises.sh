#!/usr/bin/env bash
# last_verified: 2026-08-20 · observability-monitoring-concepts n/a

# Observability exercises — round two.
# The first sheet I wrote checked whether a Prometheus endpoint answers. Today
# I wanted the opposite: get comfortable reading raw log and metric data the
# way a scraper would, without any dashboard in front of me. Small, self
# contained exercises — each one answers a question an on-call person asks.

echo "=== Observability exercises (log + latency) ==="

# Exercise 1: what fraction of requests are failing?
ACCESS_LOG=$(mktemp)
cat > "$ACCESS_LOG" <<'EOF'
10.0.0.1 - - [20/Aug/2026:09:00:01] "GET /api/health" 200 42
10.0.0.2 - - [20/Aug/2026:09:00:02] "GET /api/orders" 500 128
10.0.0.1 - - [20/Aug/2026:09:00:03] "GET /api/items" 200 998
10.0.0.3 - - [20/Aug/2026:09:00:04] "GET /api/orders" 503 0
10.0.0.2 - - [20/Aug/2026:09:00:05] "GET /api/health" 200 41
EOF

TOTAL=$(wc -l < "$ACCESS_LOG")
ERR=$(grep -cE ' (5|4)[0-9][0-9] ' "$ACCESS_LOG")
echo "requests: $TOTAL  non-2xx: $ERR"
# awk does the division so I don't read a decimal as an integer by mistake
awk -v t="$TOTAL" -v e="$ERR" 'BEGIN { printf "error ratio: %.0f%%\n", e*100/t }'
rm -f "$ACCESS_LOG"

# Exercise 2: sample wall-clock latency for a local endpoint with curl.
# timing mode is pure measurement — no state is changed by running it.
echo ""
if command -v curl >/dev/null 2>&1; then
    for i in 1 2 3; do
        curl -s -o /dev/null -w "attempt $i: %{time_total}s\n" \
            http://localhost:9090/-/healthy 2>/dev/null \
            || echo "attempt $i: endpoint not reachable (expected on a dev box)"
    done
else
    echo "curl not installed, skipping the latency probe"
fi

# Exercise 3: correlate two small metric files to answer a question.
echo ""
CPU=$(mktemp)
MEM=$(mktemp)
cat > "$CPU" <<'EOF'
15.2
13.8
16.1
EOF
cat > "$MEM" <<'EOF'
58.0
61.4
59.2
EOF
paste "$CPU" "$MEM" | awk '{ printf "cpu %s%% vs mem %s%%\n", $1, $2 }'
rm -f "$CPU" "$MEM"

echo ""
echo "Done — I'm getting better at reading raw signals, not just dashboards."