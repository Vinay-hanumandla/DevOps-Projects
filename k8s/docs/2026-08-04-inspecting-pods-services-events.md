---
last_verified: 2026-08-04
tool_version: n/a
---

# How I learned to inspect Pods, Services, and events

> Following the Kubernetes docs, here's how I got comfortable with the basic inspection commands and what each one reveals.

## Getting to know Pods

The first command I reached for was `kubectl get pods`. It shows the current state of every Pod in the default namespace. But I quickly learned that `kubectl get pods` alone doesn't tell you everything — a Pod might be running but not ready, or it might be stuck in a CrashLoopBackOff.

I started using `kubectl describe pod <name>` to get the full picture. This shows events, conditions, and the exact image that was pulled. The Events section at the bottom is especially useful — it tells you if the image pull failed, if a liveness probe failed, or if the scheduler couldn't find a node with enough resources.

## Understanding Services

Services confused me at first because they feel abstract. A Service is just a stable endpoint that routes traffic to Pods based on labels. I used `kubectl get services` to see what Services exist, and `kubectl describe service <name>` to inspect the selector and endpoints. The Endpoints field shows which Pods are actually receiving traffic — if it's empty, the Service selector doesn't match any Pod labels.

## Reading events

`kubectl get events` became my go-to debugging tool. Events are time-ordered records of things that happened in the cluster — scheduling decisions, image pulls, health check failures. I found that sorting by timestamp with `kubectl get events --sort-by='.lastTimestamp'` makes it much easier to trace what went wrong.

## What stuck with me

The pattern that clicked for me was: `kubectl get` to see the high-level state, `kubectl describe` to dig into a specific resource, and `kubectl get events` to understand what happened recently. Together these three commands cover most of the debugging I need to do day-to-day.