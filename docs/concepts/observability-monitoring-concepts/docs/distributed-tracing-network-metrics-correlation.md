---
last_verified: 2026-08-29
tool_version: n/a
sources: []
---

# Combining Observability with Networking: distributed tracing and network metrics correlation

## Purpose

Modern infrastructure incidents rarely respect tool boundaries. A latency spike in an application trace can originate from a network-layer event that the tracing system never observes. Correlating distributed traces with network metrics closes that visibility gap, letting operators confirm whether a root cause lives in application code, service configuration, or the network path between services.

## When to use

- Debugging cross-service latency where traces show high inter-service duration but the services themselves appear healthy.
- Investigating intermittent connectivity failures that traces alone cannot explain.
- Validating that network changes (routing updates, firewall rules, load-balancer reconfiguration) produce the expected effect on application behavior.
- Building dashboards that bridge application and network telemetry for on-call review.

## Prerequisites

- A tracing backend that exports spans with network-attributed metadata (source and destination addresses, protocol, TLS handshake status).
- Network telemetry accessible as time-series metrics: flow records, interface counters, BGP session state, or synthetic-probe results.
- A common notion of service identity across both data sets (DNS name, Kubernetes service name, or a shared tag key).
- A query or visualization layer that can join on time and service identity.

## Steps

1. **Tag traces with network context.** Instrument the client and server SDKs so that spans carry source IP, destination IP, port, protocol, and TLS status. OpenTelemetry auto-instrumentation for HTTP, gRPC, and database clients captures most of this without code changes.

2. **Export network metrics to the same backend.** Configure the network metrics source to use labels or tags that match the trace service identifiers. For example, if traces use `service.name = checkout-api`, configure the network flow exporter to tag flows with `service_name = "checkout-api"`.

3. **Align time windows.** Network metrics and traces operate on different clock models. Use a synchronization protocol such as NTP or PTP across all hosts and set trace and metric queries to a shared resolution (e.g., 15-second scrape interval) to keep join windows meaningful.

4. **Build correlation queries.** Start with a trace-aware filter (e.g., `duration > 200ms` for traces, `interface_errors > 0` for network metrics) and join on `(service, time_bucket)`. A spike in `http.server.duration` that coincides with a spike in `node_network_receive_drop_total` on the same service points to a receive-queue overflow rather than application slowness.

5. **Validate with a controlled change.** Deploy a known network condition (inject latency with `tc` on a test node or drain a backend in a staging environment) and verify that the correlation query surfaces the change within one metric scrape interval.

## Verify

- A trace with elevated `http.route.duration` should have a matching network-metric anomaly for the same service within the query window.
- Dropping one data source (traces or network metrics) should make the anomaly harder to isolate, confirming the two data sets add independent signal.
- Controlled injection in staging surfaces in dashboards within one scrape interval of the change.

## Common errors

- **Mismatched service identifiers.** Traces use Kubernetes pod names while network metrics use hostnames or IP addresses. Normalize to a shared tag before joining.
- **Clock skew across hosts.** Traces and metrics that are not time-synchronized produce phantom correlations or miss real ones. Verify NTP/PTP before troubleshooting correlation gaps.
- **Over-filtering on trace attributes.** Filtering traces to only error spans removes the latency context needed to find slow-but-successful requests that correlate with network queue pressure.
- **Ignoring metric cardinality.** Joining on high-cardinality network dimensions (individual flow tuples) can overwhelm the query engine; aggregate to service-level counters first.

## References

- OpenTelemetry documentation on span attributes and semantic conventions for network traffic.
- Prometheus documentation on network interface and node exporter metrics.
- W3C Trace Context specification for distributed-trace propagation across service boundaries.
