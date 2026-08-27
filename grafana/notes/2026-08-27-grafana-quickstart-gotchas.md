---
last_verified: 2026-08-27
tool_version: n/a
sources: []
---

# Follow the official Grafana quickstart and write up what tripped me up

Following the Grafana quickstart — Docker install, first dashboard, connecting a data source. Here's what worked and where I got stuck.

## Docker start was easy

The quickstart says `docker run -d --name=grafana -p 3000:3000 grafana/grafana`. That worked fine — container came up, port 3000 was reachable, login page showed default admin/admin credentials. No issues here.

## First confusion: data sources vs. dashboards

I assumed I needed to build a dashboard first and then connect a data source. The quickstart actually expects you to have a data source already running. If you don't have Prometheus or another metrics backend, you're stuck at "create a new dashboard" because there's nothing to query. I had to spin up a quick Prometheus container before the dashboard step made sense:

```bash
docker run -d --name=prometheus -p 9090:9090 prom/prometheus
```

Then in Grafana, add Prometheus as a data source using `http://host.docker.internal:9090` (or your container's IP) — not `localhost:9090`. The quickstart glosses over this Docker networking detail.

## Panel editing is not obvious

Creating a new dashboard and adding a panel is straightforward. But the panel editor UI has a lot going on. The query editor defaults to a random data source if you have multiple, and the "Visualization" dropdown is hidden under a sidebar that you might not notice. I spent a few minutes wondering why my time-series graph wasn't showing any data before realizing the data source selector in the panel was pointing to the wrong source.

## Saving dashboards: the "discard changes" trap

Grafana auto-saves some things but not dashboard edits. If you make changes to a panel and navigate away without clicking "Save dashboard" (the floppy disk icon in the top bar), your changes are gone. There's no "unsaved changes" prompt like in a text editor. I lost a panel config this way. Always save explicitly.

## What worked well

- The built-in Explore feature is great for testing queries before putting them in a dashboard. I could write a PromQL query, see results immediately, and then copy it into a panel.
- Dashboard variables let you make reusable dashboards. The quickstart mentions this but doesn't walk through it — worth exploring on your own.
- The snapshot/share feature is useful for showing someone a dashboard without giving them access to your Grafana instance.

## What I'd try next

I want to set up alerting rules — the quickstart stops short of that. Also want to try provisioning dashboards from JSON files instead of building them by hand, since that's more repeatable.
