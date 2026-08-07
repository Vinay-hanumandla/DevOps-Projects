---
last_verified: 2026-08-07
tool_version: 3.13.2
sources:
  - https://github.com/prometheus/prometheus/releases/tag/v3.13.2
---

# Installing Prometheus and exploring the web UI

I'm running Prometheus 3.13.2 locally to get a feel for how scraping and the UI work before pointing it at real services.

## What I did

1. Downloaded the Prometheus 3.13.2 release tarball for linux-amd64 from the GitHub releases page.
2. Extracted it: `tar xvfz prometheus-3.13.2.linux-amd64.tar.gz && cd prometheus-3.13.2.linux-amd64`.
3. Ran `./prometheus --config.file=prometheus.yml` — it started right up, listening on port 9090.
4. Opened `localhost:9090` in my browser.

## What tripped me up

- The first time I tried, I typed `localhost:9000` — that's Grafana's default port, not Prometheus's. Prometheus uses 9090. Easy fix.
- I wasn't sure which flags were required. Turns out `--config.file` is the only one you really need; everything else has sensible defaults. The bundled `prometheus.yml` already scrapes Prometheus itself, so I had data immediately.
- The UI has a lot of links (Graph, Console, Targets, Alerts, Status) and I didn't know where to start. I clicked "Graph" first and typed `up` as a test query — it showed `1` for itself, which was reassuring.

## What I saw

The Targets page (`/targets`) shows every scrape target and whether it's "up" or "down". By default it lists only the one self-scrape. The Status dropdown gives you Configuration, Rules, and Alerts pages. I played with the Expression field on the Graph page — typing `prometheus_tsdb_head_series` showed the number of active time series, visualized as a line graph over time.

## What I'd try next

I want to add a Node Exporter as a second scrape target so I can see host-level metrics (CPU, memory, disk). Then I'll write a few basic PromQL queries to graph those metrics.
