---
last_verified: 2026-08-27
tool_version: n/a
---

# First Grafana web UI

> Installed Grafana and opened the web UI for the first time.

I installed Grafana locally and opened the web UI. The service listens on port 3000 by default, and the initial login is `admin` / `admin`. The first thing the browser showed was a setup screen asking me to create a password and skip or add a data source.

I skipped the data-source step because I don't have anything wired up yet, and the home dashboard loaded with a mostly empty grid. The left sidebar has Explore, Dashboards, Alerting, and Connections, but without a data source most of them are placeholders.

The next thing I want to try is adding a Prometheus data source and building a simple dashboard so the UI actually shows something besides the welcome panels.
