---
last_verified: 2026-07-19
tool_version: n/a
---

# Observability & Monitoring Concepts — quick primer

> First-day notes on observability and monitoring. What they are, why they matter, and the key ideas to know.

## What is it?

Monitoring is the practice of collecting and tracking metrics, logs, and alerts from your systems so you know when something breaks. Observability is a step beyond — it's the ability to understand what's happening inside a system just by asking questions about its external outputs, without having to add new instrumentation each time.

Think of monitoring as a dashboard with gauges: CPU at 80%, disk at 90%, memory at 70%. You set thresholds, and when a gauge goes over its threshold, you get an alert. Observability is the difference between knowing the gauge is at 90% and being able to answer "why?" — which process is using the memory, what request triggered it, and whether it's a new deploy or a gradual leak.

## Why does it matter for DevOps?

When you deploy code, you need to know if it's working. Not just "is the server up?" but "is the application responding within normal time? Are error rates rising? Did the new release introduce a memory leak?" Without monitoring, you're flying blind — users will tell you something is broken before you know it.

In DevOps, monitoring is built into the deployment pipeline. A canary release sends 5% of traffic to the new version; if error rates spike, it rolls back automatically. That's only possible if metrics are streaming in real time and alerts are wired up. Observability turns deployments from "push and pray" into "push and verify."

## Key terminology

- **Metric** — A numeric value measured over time. Examples: CPU usage, request latency (p99), error rate, memory consumption. Stored in a time-series database like Prometheus.
- **Log** — A timestamped event record. Usually text with a severity level (INFO, WARN, ERROR). Centralized in tools like Loki, Elasticsearch, or CloudWatch.
- **Trace** — A record of a single request as it travels through multiple services. Shows where time is spent in a distributed system. Tools: Jaeger, Zipkin, OpenTelemetry.
- **Alert** — A notification triggered when a metric crosses a threshold for a certain duration. "CPU > 90% for 5 minutes" triggers a page. Alert fatigue happens when thresholds are too sensitive.
- **Dashboard** — A visual display of metrics, often in real time. Grafana is the most common dashboard tool — you build panels for CPU, memory, request rate, error rate, etc.
- **SLI / SLO / SLA** — Service Level Indicator (what you measure, like latency), Service Level Objective (the target, like "p99 latency < 200ms"), Service Level Agreement (the contract with consequences if the objective is missed).
- **Pull vs push** — Prometheus pulls metrics from targets (scraping). Some agents push metrics to a collector. Pull is simpler for discovery; push is better for short-lived jobs.
- **Cardinality** — The number of unique label combinations on a metric. High cardinality (like adding `user_id` as a label) can crash a time-series database. A common beginner mistake.

## A concrete example

```bash
# Simulate a simple health check that logs response time
start=$(date +%s%N)
curl -so /dev/null -w "%{http_code}" http://localhost:8080/health
end=$(date +%s%N)
elapsed=$(( (end - start) / 1000000 ))
echo "[$(date +%H:%M:%S)] Health check returned in ${elapsed}ms"
```

This is not production monitoring — it's the idea in miniature. Measure something (response time), report it, and later you'd send that number to a metric collector, compare it against a threshold, and trigger an alert if it spikes.

## How this connects to what's next

Observability is what makes Prometheus, Grafana, and Loki meaningful tools. Without understanding what metrics matter and how alerting works, those tools are just empty dashboards. Once you know what you want to measure, you can set up Prometheus to scrape it, Grafana to display it, and alerts to tell you when something needs attention.
