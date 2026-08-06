---
last_verified: 2026-08-06
tool_version: n/a
sources:
  - https://techresources.net/groups/architecture-platforms-cloud-eng/devops-monitoring-observability-guide/
  - https://www.devx.com/technology/the-complete-guide-to-container-networking-for-engineers/
---

# Grafana — quick primer

> First-day notes for someone who's never used Grafana. Personal voice, plain language.

## What is it?

Grafana is a dashboarding tool for observability data. If Prometheus is the database that stores your metrics, Grafana is the window you look through to read them — it pulls data from sources like Prometheus, Loki, and Elasticsearch and renders them as graphs, tables, and alerts on a single screen. I think of it as the "spreadsheet" for your monitoring data, except instead of rows and columns you get time-series charts and heatmaps.

## What does it do?

It connects to data sources, lets you write queries against them, and displays the results as visual panels on a dashboard. You can set up alerts that fire when a metric crosses a threshold, and share dashboards with your team so everyone sees the same view of the system.

## Why does it exist?

Before Grafana, teams would cobble together custom scripts or use basic monitoring UIs that only worked with one backend. Grafana unified that — you can connect to Prometheus, Graphite, InfluxDB, and many other backends from a single UI, and build dashboards that mix data from multiple sources. It became the standard because it was open-source and extensible.

## Key terminology

- **Dashboard** — a collection of panels that display related metrics. Example: a "API Health" dashboard with panels for latency, error rate, and request volume.
- **Panel** — a single visualization on a dashboard. Example: a time-series graph showing CPU usage over the last hour.
- **Data source** — the backend system Grafana queries. Example: connecting Grafana to a Prometheus server so it can pull metrics.
- **Query** — the expression Grafana sends to a data source to fetch data. Example: `rate(http_requests_total[5m])` in Prometheus.
- **Alert** — a rule that triggers a notification when a metric crosses a threshold. Example: alert when error rate exceeds 5% for 5 minutes.
- **Row** — a horizontal section on a dashboard that groups related panels. Example: a "Network" row containing latency and throughput panels.

## A tiny example

```bash
docker run -d --name=grafana -p 3000:3000 grafana/grafana
```

This starts a Grafana container on port 3000. Open `localhost:3000` in a browser and log in with the default admin/admin credentials.

## What I'll cover next

Next I want to walk through connecting Grafana to a Prometheus data source and building a dashboard with a few panels. After that I'll explore alerting rules and how to set up notification channels.