---
last_verified: 2026-08-29
tool_version: n/a
---

# First Prometheus run — install and poke around

I just spun up Prometheus locally to see the web UI before pointing it at real services.

## What I did

1. Grabbed the release tarball, extracted it, and `cd`'d into the folder.
2. Ran `./prometheus --config.file=prometheus.yml` — it started on port 9090 without any extra flags.
3. Opened `localhost:9090` and clicked through the top nav.

## What tripped me up

- I typed `localhost:9000` first because I mixed it up with Grafana's port. Prometheus listens on 9090.
- I almost edited `prometheus.yml` before checking the Targets page — the bundled config already scrapes Prometheus itself, so I had data immediately.
- The Graph page's expression input has autocomplete for metric names. I typed a partial name at first and got nothing, then saw the dropdown suggestions.

## What I'm exploring next

I want to try a `rate()` query on a counter metric and click into the Console tab to see the raw JSON output.
