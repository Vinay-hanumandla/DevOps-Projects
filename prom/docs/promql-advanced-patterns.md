---
last_verified: 2026-09-28
tool_version: n/a
---

# PromQL advanced patterns: subqueries, predictive recording rules, and cross-cluster federation

> Working through the advanced PromQL material after the rate/increase/histogram primer. Subqueries and predict_linear are the two shapes I actually use day to day; federation is the one I keep a config snippet for.

## Subqueries

Subqueries let me run an inner expression over a range and then aggregate or re-rate the result on an outer range. The syntax is `[resolution:range]`:

```promql
max_over_time(http_requests_total[5m:1m])
```

This takes the per-second counter, computes a 1-minute rolling max over a 5-minute lookback window, and returns one point per minute. The outer `1m` is the resolution; the inner `5m` is the range. Dropping the resolution (a plain range) is the common case — it's just a range selector applied to the inner expression.

The trade-off I hit first: subqueries are cheaper than sliding a full range over every evaluation, but the resolution you pick is a hard floor on how often the result can change. A `1m` resolution means a spike at `t+30s` is invisible until the next tick. For alerting I want the resolution to match (or be finer than) the alert's `for` duration, otherwise the alert can sit in `PENDING` while the underlying value already moved.

## Predictive recording rules

`predict_linear` extrapolates a series forward on a linear model. It's the standard way to record "will this counter breach in the next N seconds":

```promql
predict_linear(http_requests_total[1h], 3600) > 1000000
```

I use it for capacity headroom rules: if the 1-hour trend says the counter crosses a million in the next hour, fire before the pod is actually full.

Two pitfalls I learned the hard way:

- **Counter resets.** `predict_linear` assumes monotonicity. On a reset the slope flips negative and the prediction dives, producing a false "we are fine" result. Only feed it series you know do not reset between evaluations — or wrap it in `increase()` first so resets are absorbed into the windowed delta.
- **Extrapolation horizon.** A `1h` horizon over a `5m` rate is misleading: the rate measured over 5 minutes is too noisy to extrapolate an hour. Match the horizon to the window you trust. A `6h` window with a `6h` horizon is a sane pairing; a `5m` window with a `6h` horizon is not.

## Multi-cluster federation

Federation is how I pull selected series from a peer Prometheus instead of shipping everything to one central server. The scrape config targets the peer's `/federate` endpoint with a `match[]` param:

```yaml
scrape_configs:
  - job_name: federation
    honor_labels: true
    metrics_path: /federate
    params:
      match[]:
        - '{job=~".+"}'
    static_configs:
      - targets: ["<peer-prometheus-endpoint>"]
```

What I had to unlearn: federation pulls **samples, not rules**. The recording rules and alerting rules on the peer stay local to that cluster — federation only transports the metric samples the `match[]` selects. So if I want a global alert, the federation config has to feed a central Prometheus whose own rule files do the alerting. `honor_labels: true` is what lets the federated series keep their original `cluster` label instead of being overwritten by the scraper's identity.

For the full remote-write vs federation comparison, see `configs/remote-write-vs-federation.yaml`.

## What I'll try next

I want to wire a `predict_linear` recording rule into a real counter and watch the extrapolation diverge after a counter reset, so I can see the false-negative in action. After that I'll set up a two-node federation pair and confirm which labels survive `honor_labels`.