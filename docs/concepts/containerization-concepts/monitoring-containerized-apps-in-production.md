---
last_verified: 2026-08-14
tool_version: n/a
---

# Combining Containerization with Observability — monitoring containerized apps in production

> This pattern combines containerization with observability to give visibility into running containers.

## Purpose

This pattern combines containerization concepts with observability concepts to expose metrics, logs, and traces from running containers. Without instrumentation, a containerized application is a black box: it runs, but you cannot see its internal state, resource usage, or request flow. Adding observability turns each container into a reportable unit that feeds dashboards and alert rules.

## Prerequisites

- **Containerization Concepts** — understand what an image, container, and port mapping are, and how a container runtime isolates processes.
- **Observability & Monitoring Concepts** — understand the three pillars (metrics, logs, traces) and why they matter more than traditional monitoring.

## Steps

1. **Instrument the application** to emit metrics, structured logs, and distributed traces. Most languages have client libraries or exporters that push data to a local agent (e.g., Prometheus client, OpenTelemetry SDK).
2. **Expose a metrics endpoint** inside the container on a dedicated port. The Dockerfile adds an `EXPOSE` directive and the container runtime maps the port with `-p` or in the Compose `ports` section.
3. **Configure the scrape target** in Prometheus (or equivalent) to pull metrics from the container's endpoint. Use the container's network alias rather than its ephemeral IP so the target survives restarts.
4. **Attach a logging driver** or sidecar so that the container's stdout/stderr is shipped to a central log store. Docker's `json-file` driver is the default; production setups often replace it with `fluentd` or `gelf`.
5. **Inject trace context** by initializing the OpenTelemetry SDK at application startup. The SDK auto-instruments HTTP and database calls, sending spans to a collector.

## Verify

1. **Metrics** — query the Prometheus UI and confirm the container appears in the targets list with `up == 1`.
2. **Logs** — run `docker logs <container>` and confirm structured log lines contain timestamps and severity fields.
3. **Traces** — open the tracing UI and confirm a recent request produces a span tree with service name, duration, and any downstream calls.
4. **Resource visibility** — check `docker stats` or the cAdvisor dashboard to confirm CPU, memory, and network I/O are visible per container.

## How this connects to what's next

This pattern is the observability layer for every containerized workload. Once metrics and logs are flowing, the next step is setting up alert rules that page on-call staff, then adding dashboards that correlate container health with application-level SLIs. It also feeds into higher-level orchestration: Kubernetes can auto-restart unhealthy containers, but only if the health endpoint reflects real application state rather than a generic process check.
