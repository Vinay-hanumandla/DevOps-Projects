---
last_verified: 2026-09-26
tool_version: "n/a"
sources: []
---

# PromQL advanced patterns

## Histograms

Prometheus histograms are exposed as a family of `_bucket` series with a shared name and a `le` label. Each bucket counts observations below a threshold. The `_sum` and `_count` series complete the picture.

A raw histogram is not directly useful for alerting. The standard shape wraps it in `histogram_quantile`:

```promql
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

`rate` converts each bucket's counter into a per-second speed over the window, then `histogram_quantile` interpolates across buckets to estimate the value below which 95% of observations fall. The result is a single series that answers "how slow were the unlucky 5%".

Bucket selection matters. Too few buckets and the quantile is coarse; too many and the interpolation is noisy. Choose bucket boundaries that bracket the latency range you actually care about, and keep them consistent across services so the same query works everywhere.

## Subqueries

Subqueries let you query a derived time series over a range, then feed the result back into an outer query. The syntax wraps an inner expression in square brackets with a range and a resolution step:

```promql
rate(http_requests_total[5m])
```

A subquery version samples that rate at a fixed interval instead of evaluating it once per scrape:

```promql
rate(http_requests_total[5m:1m])
```

The inner `5m` is the range; the trailing `1m` is the subquery resolution. Use subqueries when the outer expression needs a derived value that itself changes over time — for example, comparing the current rate against its own moving average, or computing a ratio of two rates that must be sampled at matching timestamps.

Subqueries are more expensive than plain range queries because they evaluate the inner expression repeatedly. Keep the resolution step coarse and the range short when the alert can tolerate it.

## Predictive recording rules

Recording rules precompute an expression once per evaluation interval and expose the result as a new metric. That turns an expensive query into a cheap one for dashboards and alerts to consume.

A predictive rule computes a threshold ahead of time so the alert fires before the condition is fully visible:

```yaml
groups:
  - name: predictive
    rules:
      - record: predict:requests_per_second:5m
        expr: predict_linear(http_requests_total[1h], 3600)
```

`predict_linear` extrapolates the series forward by the number of seconds given. Here it projects the request rate one hour ahead. An alert can then compare the actual rate against the prediction and fire when the two diverge.

Recording rules belong in a Prometheus rule file loaded by the server. Give every recorded metric a descriptive name with a `:`-separated hierarchy so it is obvious in a query browser which rule produced it.

## Multi-cluster federation

Federation lets one Prometheus server scrape a subset of metrics from another Prometheus server. It is useful for cross-cluster rollups, long-term storage handoffs, or exposing a curated view to a global dashboard.

Configure a scrape job pointing at the remote server and select the series you want with query parameters:

```yaml
scrape_configs:
  - job_name: 'federate'
    metrics_path: '/federate'
    params:
      match[]:
        - '{job="kubernetes"}'
    static_configs:
      - targets:
          - 'prometheus-cluster-a:9090'
          - 'prometheus-cluster-b:9090'
```

The `match[]` selector determines which series are pulled. Federation pulls samples, not rules, so the receiving server still needs its own recording rules and alerting if it is to act on the data.

Choose federation over a single global server when clusters are managed by different teams, run in separate networks, or have retention requirements that differ. The trade-off is that the receiving server becomes a single point of failure for the global view, so run it with HA and consider a second receiving server with the same selection.

## Verification

1. Render a histogram query in the expression browser and confirm the quantile moves with traffic.
2. Run a subquery query with and without the resolution step and confirm the output shape.
3. Evaluate a predictive recording rule and confirm the recorded metric appears in the server.
4. Query the federation endpoint from the receiving server and confirm selected series arrive.