---
last_verified: 2026-09-16
tool_version: n/a
---

# Kubernetes quickstart, second pass — kind, contexts, and a port mismatch

> Went through the quickstart again, this time with kind instead of minikube. Here's what worked and where it broke.

## What I did

I spun up a local cluster with `kind create cluster` and deployed a tiny echo server with `kubectl create deployment hello --image=hashicorp/http-echo`. The Pod came up clean on the first try, so I exposed it with `kubectl expose deployment hello --port=80` and expected to curl it. That is where the smooth part ended.

## Got stuck on

My first confusion was contexts. I had an old minikube context still configured, and after creating the kind cluster my `kubectl get nodes` kept showing the wrong cluster. Running `kubectl config get-contexts` showed the asterisk sitting on minikube, not kind. I fixed it with `kubectl config use-context kind-kind` and everything started responding. Lesson learned: always check which context is active before concluding the cluster is broken.

The second snag was a port mismatch. The echo server listens on port 5678 inside the container, but I exposed the Service on port 80 without setting a target port, so curling the Service gave me connection refused even though the Pod was running. Describing the Service showed traffic going nowhere. I deleted it and re-exposed with an explicit target port pointing at 5678, and the curl finally returned the echo response. I had assumed the Service would figure out the container port on its own — it does not.

The third stumbling block was reaching the app from my laptop. With minikube I was used to a helper command that opens a tunnel, but kind runs inside docker containers, so a NodePort is not directly reachable. I fell back to `kubectl port-forward service/hello 8080:80` and curled localhost instead. It feels like a workaround, but for local experiments it is the fastest path.

## What I'd try next

I want to write the Deployment and Service as YAML files instead of imperative commands so I can re-apply them after tearing the cluster down. I also want to try scaling the Deployment to three replicas and watch what happens to the endpoints when I delete a Pod mid-request.
