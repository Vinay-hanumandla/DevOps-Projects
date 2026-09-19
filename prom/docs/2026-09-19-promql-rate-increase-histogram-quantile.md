---
last_verified: 2026-09-19
tool_version: n/a
---

# PromQL fundamentals: rate, increase, and histogram_quantile

> Following the query tutorial and writing my first queries against a counter and a histogram until the shapes made sense.

## What I set up

I had a small test instance running with a demo service exposing request counters and request-duration histograms. I opened the query view and started with the simplest thing: plotting the raw counter. That just gave me a line climbing forever, which looked impressive and told me nothing. Counters only become useful once you ask how fast they are moving, so that is where the tutorial pointed next.

## Trying rate

My first working query wrapped the counter like this:

```promql
rate(http_requests_total[5m])
```

This asks for the per-second average speed of the counter over the last five minutes. Once I saw it, the dashboard finally answered the question I actually had: how much traffic is arriving right now. I tried a short window and a long window back to back and noticed the short one jumps around while the long one smooths everything out. Picking the window turned out to be the whole skill — too short and the graph is noise, too long and a fresh spike hides for a while.

## Trying increase

Next I wanted totals instead of speeds, for questions like "how many errors happened during the deploy window". That is what `increase` is for:

```promql
increase(http_requests_total{status="500"}[30m])
```

It gives the absolute growth of the counter over the window. I compared it against `rate` over the same window multiplied out and got roughly the same number, which reassured me they are two views of the same movement. My rule of thumb now: `rate` for alerting and dashboards showing speed, `increase` for summarizing what happened inside a bounded window.

## Got stuck on histogram_quantile

Histograms confused me for a while. The duration metric is not one series but a bucket family, and the tutorial query looked like magic at first:

```promql
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

What finally clicked: `rate` first turns each bucket's counter into a speed, then `histogram_quantile` reads across the buckets to estimate the value below which 95 percent of observations fall. So this answers "how slow were the unlucky 5 percent of requests". I made the classic mistake of averaging the bucket values directly, which gives a meaningless number because buckets are cumulative counts, not samples. The quantile function exists precisely because you cannot average your way there.

## What I'd try next

I want to redo these three queries against a recording of a real traffic spike and check that my window choices still behave. After that I plan to look at how these query shapes feed into alert thresholds, since a `rate`-based alert with the wrong window seems like the easiest way to page myself at night for no reason.
