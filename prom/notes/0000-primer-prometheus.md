---
last_verified: 2026-08-07
tool_version: 3.13.2
sources:
  - https://github.com/prometheus/prometheus/releases/tag/v3.13.2
---

# Prometheus — quick primer

> First-day notes for someone who's never used Prometheus. Personal voice, plain language.

## What is it?

Prometheus is a monitoring and alerting toolkit that collects and stores metrics as time-series data. A metric is any numeric measurement — requests per second, CPU usage, error counts — tagged with labels so you can slice and dice it. If you've used `vmstat` or `iostat` on a single Linux box, you've seen raw metrics; Prometheus takes that same idea and scales it to thousands of servers, applications, and services, all queryable in real time.

It's different from log-based tools (like the ELK stack or Loki): where logs give you detailed per-event records that are great for debugging, Prometheus gives you structured numeric data that's easy to aggregate and alert on.

## What does it do?

Prometheus pulls (scrapes) metrics from HTTP endpoints on a schedule you define, stores the values with timestamps, and gives you PromQL — a query language for slicing and combining that data. You can feed those queries into Grafana dashboards, and fire alerts through AlertManager when thresholds are crossed.

## Why does it exist?

Before Prometheus, monitoring in the cloud-native world was fragmented. You'd cobble together Ganglia, collectd, Nagios, and custom scripts, each with its own data model and query syntax. Prometheus unified all of that into one system: a single pull-based scrape model, a powerful label-based query language, and built-in service discovery for Kubernetes, EC2, and other environments. It was originally built at SoundCloud in 2012 to replace a sprawl of monitoring tools, and open-sourced in 2015.

## Key terminology

- **Metric** — a named time series identified by its name and optional key/value labels. Example: `http_requests_total` is a counter that increments on every HTTP request.
- **Series** — one stream of data points for a given metric + label combination. Example: `http_requests_total{method="POST"}` is a separate series from `http_requests_total{method="GET"}`.
- **Scrape** — Prometheus actively polls an HTTP endpoint that exposes metrics in a simple text format. Example: `prometheus.yml` tells Prometheus to fetch `/metrics` from each target every 15 seconds.
- **Scrape target** — a single endpoint Prometheus knows to poll. Example: `static_configs: - targets: ["localhost:9090"]` adds localhost:9090 as a target.
- **Exporter** — a small process that exposes metrics for another service or system. Example: the Node Exporter exposes host CPU, memory, and disk stats.
- **PromQL** — Prometheus's query language for selecting and aggregating time-series data. Example: `rate(http_requests_total[5m])` returns the per-second request rate over the last 5 minutes.
- **AlertManager** — receives alerts fired by Prometheus, handles deduplication, grouping, and routing. Example: a high-CPU alert fires to a Slack channel via AlertManager.
- **Job** — a logical name grouping scrape targets with shared configuration. Example: `job_name: "node"` collects all Node Exporter targets under one label.

## A tiny example

```bash
tar xvfz prometheus-3.13.2.linux-amd64.tar.gz
cd prometheus-3.13.2.linux-amd64
./prometheus --config.file=prometheus.yml
```

This starts Prometheus with its bundled config file. Open `localhost:9090` in your browser — the web UI lets you write PromQL queries and view graphs. The default `prometheus.yml` already scrapes Prometheus itself, so you have data to play with immediately.

## What I'll cover next

I want to add a Node Exporter as a second scrape target so I can see host-level metrics (CPU, memory, disk). Then I'll write simple PromQL queries to graph those metrics, and set up a basic alert rule to understand how AlertManager picks up fired alerts.
