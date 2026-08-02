---
last_verified: 2026-08-02
tool_version: n/a
---

# Kubernetes — quick primer

> First-day notes for someone who's never used Kubernetes. Personal voice, plain language.

## What is it?

Kubernetes is a system for running containerized applications across a cluster of machines. If Docker lets you package an app into a container, Kubernetes is what keeps that container running, scales it up when traffic grows, and restarts it if it crashes. Think of it as the operating system for a fleet of containers — it decides where each container runs, how they talk to each other, and what happens when something goes wrong.

## What does it do?

It lets you deploy containers, scale them up or down, and manage their lifecycle across multiple machines. You describe the state you want (how many copies of an app should be running, what image to use), and Kubernetes makes the cluster match that state. It also handles networking between containers, secret management, and rolling updates.

## Why does it exist?

Before Kubernetes, running containers at scale meant manually SSHing into machines, starting containers by hand, and writing custom scripts to restart things when they failed. As teams grew, this became unmanageable. Kubernetes automates all of that — it's the tool that turned container running from a manual chore into a reliable, repeatable process.

## Key terminology

- **Pod** — the smallest unit Kubernetes manages; it wraps one or more containers that share networking and storage. Example: a Pod running an nginx container.
- **Service** — a stable network endpoint that routes traffic to Pods. Example: a Service that load-balances across three nginx Pods.
- **Deployment** — a controller that manages Pod replicas and handles rolling updates. Example: a Deployment that keeps 3 copies of my app running.
- **kubectl** — the command-line tool for talking to a Kubernetes cluster. Example: `kubectl get pods` lists running Pods.
- **Node** — a worker machine (physical or virtual) that runs Pods. Example: a VM in the cloud that Kubernetes schedules containers onto.
- **Cluster** — a set of Nodes managed by Kubernetes. Example: a local Minikube cluster with one Node, or a cloud cluster with dozens.

## A tiny example

```bash
kubectl run hello-minikube --image=nginx --port=80
kubectl get pods
```

This starts an nginx container in a Pod and then checks that it's running. It's the smallest "hello world" for Kubernetes — one command to deploy, one to verify.

## What I'll cover next

I plan to dig into Minikube setup so I can run Kubernetes locally, then explore kubectl commands for inspecting Pods, Services, and deployments. After that I want to try writing a minimal Deployment and Service manifest.