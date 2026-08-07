---
last_verified: 2026-08-07
tool_version: n/a
sources:
  - https://aws.amazon.com/blogs/mt/deploy-opentelemetry-gateway-on-aws-monitoring-your-observability-pipeline/
---

# Combining Observability with Containerization: monitoring containerized apps

## Purpose
Containerized applications move fast, scale dynamically, and replace long-lived hosts with short-lived instances. Traditional monitoring tools built for static infrastructure struggle to keep up. This guide shows how to adapt the three pillars of observability — logs, metrics, and traces — so they work reliably across Docker and Kubernetes environments.

## Prerequisites
- A containerized application running in Docker or Kubernetes
- An observability backend that can ingest metrics and traces (for example, Prometheus, Grafana, or an OpenTelemetry collector)
- Basic familiarity with container networking, image builds, and runtime configuration

## Steps

### 1. Instrument the application container
Add an observability SDK or agent inside the container image. For language-specific services, use the native OpenTelemetry SDK; for generic workloads, run a collector as a sidecar. The agent needs network access to the observability backend, and the backend address should be passed via environment variables or service discovery rather than hard-coded.

### 2. Export container runtime metrics
Container runtimes expose CPU, memory, network I/O, and restart counts through their own metrics endpoints. In Docker, enable daemon-level metrics and expose them on a dedicated port. In Kubernetes, the kubelet already exposes `/metrics`, and the `cAdvisor` endpoint provides per-container resource usage. Configure a Prometheus scrape job to collect these endpoints at the same interval as application metrics.

### 3. Aggregate container logs
Container logs are stdout/stderr streams captured by the runtime. In Docker, configure a log driver (`json-file`, `syslog`, or `fluentd`) to ship logs to a centralized backend. In Kubernetes, run a DaemonSet with a log collector such as Fluent Bit or Filebeat. Tag every log entry with the container ID, image name, pod name, and namespace so you can filter and correlate events during an incident.

### 4. Propagate trace context across containers
When a request traverses multiple containers — frontend, backend, cache — each hop should carry the same trace ID. Propagate this context through HTTP headers, gRPC metadata, or message-queue properties. This lets you reconstruct the full request path in a distributed trace viewer rather than seeing isolated spans.

## Verify
1. Deploy the instrumented container and confirm the application starts without errors.
2. Query the observability backend and verify that metrics from both the application and the container runtime are present.
3. Send a request that crosses multiple containers and check that a single trace spans all services.
4. Search the log backend for a recent container event and confirm the entry includes the expected container and pod metadata.
