---
last_verified: 2026-08-23
tool_version: n/a
sources: []
---

# Combining Networking with Observability — distributed tracing across service boundaries

> How network-level signals (latency, packet loss, DNS resolution time) feed into observability systems and how distributed traces cross network boundaries between services.

## Purpose

Modern microservice architectures spread a single user request across dozens of services connected by networks. When something goes wrong — a slow response, a dropped connection, a partial failure — the root cause is almost always at a network boundary: a service can't reach another, DNS resolution is slow, a load balancer is dropping packets, or a firewall rule silently blocks traffic. This doc explains how networking fundamentals map into observability systems and how distributed tracing follows a request as it crosses service boundaries over the network.

## When to use

Use this reference when debugging latency that doesn't appear in any single service's logs, when a trace shows gaps between spans that suggest network-level delays, when DNS resolution time is inflating response times, or when you need to correlate network metrics (packet loss, retransmits, RTT) with application-level traces. This is the intersection where infrastructure monitoring meets application performance monitoring.

## The networking-observability bridge

Three categories of network signals feed into observability:

- **Network latency** — the time a packet takes to travel between two services. Measured as round-trip time (RTT) via ICMP ping or TCP handshake timing. When a trace shows a long gap between "service A sent request" and "service B received request," network latency is the first suspect.
- **DNS resolution time** — the time to resolve a service hostname to an IP address. In containerized environments, DNS lookups happen on every new connection unless connection pooling is in place. Slow DNS (often caused by misconfigured resolvers or overloaded DNS servers) adds invisible latency to every request.
- **Packet loss and retransmission** — TCP retransmits lost packets, which adds latency and throughput degradation. High retransmit counts on an interface correlate with application-level timeouts and connection resets.

These signals show up differently depending on where you measure:

- **Host-level** — `ss`, `ip -s`, `/proc/net/snmp` provide packet counters, retransmit counts, and connection state. These are the ground truth for what the OS network stack is doing.
- **Service-level** — application metrics like request duration histograms, error rates, and connection pool stats reflect how network conditions affect the application.
- **Trace-level** — distributed traces capture the time spent in each network hop between services, making cross-boundary latency visible.

## Distributed tracing across network boundaries

A distributed trace follows a request as it flows through multiple services. Each service creates a span, and the trace context (trace ID, parent span ID) is propagated through HTTP headers or gRPC metadata across network calls.

The key networking concepts that affect tracing:

- **Context propagation** — the trace context travels in-band with the request (usually in HTTP headers like `traceparent` for W3C Trace Context). If a network call fails or times out before the header is read, the downstream span is never created, leaving a gap in the trace.
- **Span timing** — a span's start and end time are recorded by the service. Network latency between services shows up as the gap between service A's "request sent" event and service B's "request received" event. If both services are on the same host, this gap is microseconds; across a data center, it's milliseconds; across regions, it's tens of milliseconds.
- **Sampling** — head-based sampling decides at the edge whether to trace a request. If the sampling rate is too low, you miss the slow requests that are most likely to have network issues. Tail-based sampling (deciding after the fact based on latency or errors) catches these but requires more infrastructure.
- **Baggage** — some tracing systems propagate key-value pairs (baggage) alongside the trace context. Baggage increases header size, which can interact with HTTP/2 SETTINGS_MAX_HEADER_SIZE or nginx's `large_client_header_buffers`.

## Steps

1. **Instrument network-aware metrics at the service level.** Export request duration histograms broken down by target service, DNS resolution time, and connection pool utilization. These metrics answer "how long did this request take?" while traces answer "where did the time go?"
2. **Propagate trace context across all network calls.** Ensure HTTP clients inject the `traceparent` header (or equivalent) on outgoing requests and servers extract it on incoming requests. Missing propagation breaks the trace chain.
3. **Correlate network host metrics with traces.** When a trace shows an unusually long inter-service span, check the host's network counters (`ip -s link`, `/proc/net/snmp`) for packet loss or retransmits during that time window.
4. **Monitor DNS resolution separately.** DNS latency is a common hidden contributor. Export DNS query duration as a metric and alert on p99 values above your baseline.
5. **Set up span-level error annotations.** When a network call fails (connection refused, timeout, DNS failure), the tracing library should record the error type and message on the span. This makes network failures visible in the trace without digging into logs.

## Verify

To confirm the networking-observability pipeline is working:

```bash
# Check that a service is exporting network-related metrics
curl -s http://localhost:9090/metrics | grep -E '(dns_resolution|network_latency|http_request_duration)'

# Verify trace context propagation by checking headers on a downstream call
curl -sI http://service-b:8080/api | grep -i traceparent

# Inspect host network counters to compare with trace data
ip -s link show
cat /proc/net/snmp | grep -E '(Tcp:|Udp:)'
```

## Common errors

- **Trace gaps between services** — the trace context header is not being propagated. Check that both the client library and server framework are instrumented. A common mistake is instrumenting the server but not the client, or vice versa.
- **DNS resolution inflating request latency** — the service is doing a DNS lookup on every connection instead of caching the result. Enable DNS caching in the HTTP client or use a local DNS resolver cache.
- **High retransmit counts correlating with timeouts** — packet loss on the network path is causing TCP retransmissions, which appear as application-level timeouts. Check the network path (switches, routers, firewalls) and the host's TCP retransmission counters.
- **Missing spans in traces after network errors** — the tracing library's timeout is shorter than the application's timeout, so the span ends before the network call completes. Align timeouts between the tracing library and the application.
- **Trace sampling too low to catch intermittent network issues** — if only 1% of requests are traced, you'll rarely see the slow ones caused by transient network problems. Use tail-based sampling that keeps traces above a latency threshold.
