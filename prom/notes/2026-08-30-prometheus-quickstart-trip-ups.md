---
last_verified: 2026-08-30
tool_version: n/a
sources: []
---

# Prometheus quickstart trip-ups

> Following the Prometheus quickstart and writing up what tripped me up.

## What I was trying to do

I wanted to get Prometheus running locally, scrape a few targets, and verify the data was coming in through the web UI. Seemed straightforward — download, unzip, run.

## What actually tripped me up

### 1. The default config assumes localhost targets

The bundled `prometheus.yml` ships with a single job scraping `localhost:9090` itself. That works for the "hello world" check, but the moment I tried to add my own target I forgot that Prometheus expects the target to expose a `/metrics` endpoint. My Flask app didn't have one, so Prometheus showed the target as `DOWN` with a `context deadline exceeded` error. Fixed by adding a `/metrics` route that returned Prometheus-format counters.

### 2. YAML indentation is silent poison

I copied an example `prometheus.yml` from a blog post and Prometheus started but showed zero targets. The `static_configs` block was indented under the wrong key. No error in logs — just an empty `targets` list. I only caught it by running `promtool check config prometheus.yml`, which I should have done first.

### 3. Reloading config doesn't restart Prometheus

I edited `prometheus.yml` and expected it to pick up changes automatically. It doesn't — you need to either restart the process or send a `POST` to `/-/reload` (which is disabled by default). I added `--web.enable-lifecycle` to my startup command so `curl -X POST http://localhost:9090/-/reload` works.

### 4. The web UI path is not `/`

After starting Prometheus I hit `http://localhost:9090/` and got a blank page. Turns out the expression browser is at `http://localhost:9090/graph` and the status/targets page is at `http://localhost:9090/targets`. I wasted ten minutes thinking the binary was broken.

### 5. Alertmanager connection refused

I added a basic `alerting` block to `prometheus.yml` pointing at `localhost:9093` but hadn't actually started Alertmanager. Prometheus logs filled with `context canceled` errors on every scrape cycle. Started Alertmanager on another terminal and the errors stopped.

## What I'd try next

- Run Prometheus inside Docker Compose with Alertmanager so both services start together.
- Use file-based service discovery instead of `static_configs` to avoid re-editing the YAML for every new target.
- Set up a minimal recording rule to pre-compute an expensive query.
