---
last_verified: 2026-08-19
tool_version: n/a
---

# Install kubectl and explore the cluster for the first time

> First-day notes on getting kubectl installed and poking around a cluster.

## What I did

I installed kubectl using `brew install kubectl` on my Mac. Then I pointed it at a Minikube cluster with `minikube start`. The version check `kubectl version --client` worked immediately, but `kubectl cluster-info` returned nothing at first because Minikube was still booting.

## What tripped me up

The first confusion was context. I ran `kubectl config current-context` and got `minikube`, but `kubectl get nodes` showed `NotReady` for a couple of minutes. I thought I'd broken the install, but it was just the VM starting up.

The second thing that caught me was namespace visibility. After creating a Deployment in the `default` namespace, I ran `kubectl get pods` and saw nothing. I'd accidentally created it in a different namespace and didn't realize namespaces are fully isolated. `kubectl get pods --all-namespaces` showed it right away.

I also kept typing `kubectl get pods` when I meant `kubectl get deployments`. The short flags are easy to mix up when you're following a tutorial that switches between them.

## What I'd try next

I want to try `kubectl get events --sort-by='.lastTimestamp'` to see cluster activity in order, and then create a Service to expose a Deployment so I can see how traffic routes.
