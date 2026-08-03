---
last_verified: 2026-08-03
tool_version: n/a
---

# Explore kubectl CLI — what's there after Minikube install

I installed Minikube and ran `kubectl version` for the first time. The client version printed fine, but the server version showed an error because I hadn't started Minikube yet. Once I ran `minikube start`, `kubectl version` showed both client and server versions matching.

## What I tried

I ran `kubectl get pods` to see what was running. The cluster was empty — no Pods yet. Then I tried `kubectl get nodes` and saw my Minikube node listed as Ready.

## What stuck with me

The difference between `kubectl` (the CLI tool) and the cluster (Minikube running locally). The CLI talks to the cluster API server — if Minikube isn't running, the CLI can't reach it. I also noticed `kubectl` has a `--context` flag for switching between clusters, which I'll need when I move beyond local testing.

## What I want to try next

Deploying a real Pod with `kubectl run`, then exposing it with `kubectl expose`. I also want to look at `kubectl describe` and `kubectl logs` to understand how to debug running workloads.