---
last_verified: 2026-08-23
tool_version: n/a
---

# Combining Networking with Observability: Distributed Tracing and Network Metrics Correlation

## Purpose

When a service mesh or microservice architecture grows beyond a single host, failures stop being "the server is down" and become "request 7a3f took 4.2 s across three services, two regions, and a load balancer." Distributed tracing and network metrics correlation are the two practices that let you reconstruct that path. This document explains how they fit together and why both are necessary.

Distributed tracing gives you a per-request timeline; network metrics give you the health of the links between services. Neither is sufficient alone: a trace tells you where time was spent, but not whether a link was saturated. Metrics tell you a link is saturated, but not which request caused it. Correlating the two turns a vague "latency spike" into a specific "this service-to-service call is retrying because the TCP backlog is full."

## Prerequisites

- Basic familiarity with TCP/IP, DNS, and HTTP request flow.
- Understanding of observability as the combination of metrics, logs, and traces.
- A mental model of a multi-service deployment (at least two services communicating over a network).

## Steps

### 1. Instrument services for distributed tracing

The goal is to assign every inbound request a unique trace ID and propagate that ID across service boundaries. In practice this means:

- Generate or accept a trace ID at the edge (API gateway, load balancer, or first service).
- Inject the trace ID into the outgoing request headers (e.g., `X-Trace-Id`, `traceparent`).
- Ensure each service logs the trace ID alongside its own span ID and parent span ID.

This creates a causal chain: if Service A calls Service B, the span for Service B carries Service A's span ID as its parent. When you look at the trace, you see the exact call tree.

### 2. Collect network metrics alongside traces

Network metrics are typically gathered at the host or mesh layer. The most useful signals for correlation are:

- **Connection state counts** — `ESTABLISHED`, `TIME_WAIT`, `SYN_RECV` on each interface. A sudden rise in `SYN_RECV` suggests a SYN flood or a service not completing handshakes.
- **Retransmission rate** — TCP retransmits indicate packet loss. A spike in retransmits aligned with a latency spike in a specific trace points to a network-level problem rather than application slowness.
- **DNS resolution time** — If a service depends on dynamic service discovery, DNS latency can appear as random 100–500 ms pauses in traces that have no application-level cause.
- **Flow statistics** — Bytes and packets per second per socket. A flow with high bytes but low throughput indicates congestion or rate limiting.

Collect these metrics at a fixed interval (e.g., 15 s) and tag them with the same labels you use for traces: service name, namespace, and region.

### 3. Correlate traces with network signals

Correlation is the step most tutorials skip. The practical workflow is:

1. Start from an anomalous trace — a single request with an unexpectedly long span.
2. Note the timestamp window of that span (e.g., 14:32:10 to 14:32:18 UTC).
3. Query network metrics for the same service pair and timestamp window.
4. Look for alignment: did retransmits rise? Did `TIME_WAIT` accumulate? Did DNS latency spike?

If the network metrics show no anomaly during the trace window, the problem is inside the service (database lock, garbage collection, serialization bottleneck). If the network metrics do show an anomaly, the problem is on the link (congestion, firewall rule, MTU mismatch).

### 4. Build a feedback loop

The first correlation is manual, but you can automate the loop:

- Export trace spans and network metrics to the same time-series store.
- Define a correlation query: "Find all traces where span duration > 2 s and retransmit rate > 1% during the same 30-second window."
- Alert on the correlation, not on either signal alone.

This is the core insight: network metrics explain *why* a trace is slow; traces explain *which* request was affected by a network event.

## Verify

After implementing the four steps above, verify each piece independently before combining them:

- **Trace propagation test** — Send a request through two instrumented services. Confirm both logs contain the same trace ID and that the parent-child relationship is correct.
- **Metric collection test** — Run `ss -s` or check your exporter's `/metrics` endpoint. Confirm connection state counts and retransmit counters are updating.
- **Correlation test** — Introduce a known delay (e.g., `tc qdisc add dev eth0 root netem delay 200ms`). Send a request and verify the trace shows increased span duration while the network metrics show elevated RTT or retransmits in the same window.
- **Alert test** — Fire a synthetic anomaly and confirm the correlated alert fires. Verify the alert payload includes both the trace ID and the network metric values.

## Common errors

- **Propagating only the trace ID, not the span ID.** Without the parent span ID, the backend reconstructs the call tree as a flat list of independent spans. You lose causality.
- **Sampling traces but expecting 100% coverage for correlation.** If you sample at 1%, 99% of your network metrics have no matching trace. Either sample at a higher rate for the services you care about, or correlate on aggregates (percentiles) rather than individual requests.
- **Collecting metrics at the wrong layer.** Host-level `ss` output tells you nothing about a Kubernetes NetworkPolicy silently dropping packets between pods. Collect metrics at the mesh or CNI layer for pod-to-pod traffic.
- **Ignoring DNS in the correlation.** DNS issues look like random latency because they only affect some requests. If your correlation window is too narrow, you miss them.
