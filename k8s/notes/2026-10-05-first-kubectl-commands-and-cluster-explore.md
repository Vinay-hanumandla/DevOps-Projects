---
last_verified: 2026-10-05
tool_version: n/a
---

# First kubectl commands — what's actually in this cluster

> My scratch notes from poking at a cluster for the first time. I just wanted to answer: is anything there, and what is it?

## What I did

I ran `kubectl cluster-info` first just to see if I was even talking to a cluster. It printed something back, so I knew my context was pointing somewhere live.

Then I ran `kubectl get nodes` to see how many machines I'm working with, and `kubectl get namespaces` to get a feel for how things are divided up. I saw the familiar default ones plus one the demo app lives in.

Next I tried `kubectl get pods --all-namespaces` because plain `kubectl get pods` showed me almost nothing and I assumed I was looking in the wrong place. That was the trick — suddenly I could see a handful of pods, mostly system stuff plus the demo app. I picked one pod and ran `kubectl describe pod` on it to see what labels and restarts it has.

## Got stuck on

I kept typing `kubectl get pods` with no flags and thinking the cluster was empty. Turns out I was just sitting in the default namespace while everything interesting lives elsewhere. Adding `--all-namespaces` fixed it right away.

I also tried `kubectl logs` on one of the system pods and got a wall of text I didn't understand yet. Skipping that for now.

## What I'd try next

I want to look at what services exist with `kubectl get services` and figure out how the demo app is exposed. Also curious what `kubectl get deployments` shows versus the raw pods I already saw.
