---
last_verified: 2026-08-29
tool_version: 3.13.2
sources:
  - https://github.com/prometheus/prometheus/releases/tag/v3.13.2
---

# Installing Prometheus and exploring the web UI

I grabbed Prometheus 3.13.2 to see how the install works and poke around the built-in UI.

## What I did

1. Downloaded the 3.13.2 release tarball for linux-amd64 from the GitHub releases page.
2. Extracted it: `tar xvfz prometheus-3.13.2.linux-amd64.tar.gz && cd prometheus-3.13.2.linux-amd64`.
3. Ran `./prometheus --config.file=prometheus.yml` — started right up on port 9090.
4. Opened `localhost:9090` in the browser.

## What tripped me up

- Typed `localhost:9000` at first — that's Grafana's default, not Prometheus. Prometheus uses 9090.
- Didn't know which flags were required. Turns out `--config.file` is the only one you really need; the bundled `prometheus.yml` already scrapes itself so I had data immediately.
- The UI has a lot of tabs (Graph, Console, Targets, Alerts, Status) and I wasn't sure where to start. Clicked "Graph" and typed `up` as a test query — it returned `1` for the Prometheus self-scrape, which was reassuring.

## What I saw

The Targets page (`/targets`) lists every scrape target and whether it's "up" or "down". By default it only shows the one self-scrape. The Expression field on the Graph page let me write PromQL — typing `prometheus_tsdb_head_series` showed the number of active time series as a line graph.

## What I'd try next

I want to add a Node Exporter as a second scrape target so I can see host-level metrics. Then a few basic PromQL queries to graph CPU and memory.
