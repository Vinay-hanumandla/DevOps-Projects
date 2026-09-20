---
last_verified: 2026-09-20
tool_version: n/a
sources: []
---

# Local dev cluster scaffold — Docker Compose + kind

## Purpose

This template scaffolds a local development cluster that combines Docker Compose and Kubernetes via kind (Kubernetes in Docker). One Docker Compose file manages external services — a database and a cache — that run as plain containers, while kind provisions a multi-node Kubernetes cluster in separate Docker containers. The two run side by side on the same Docker daemon, connected through the host network so pods can reach Compose services by host-level port.

This is one approach to local Kubernetes development; teams that prefer an all-in-cluster strategy (running PostgreSQL and Redis as Kubernetes manifests instead of Compose services) can drop the `docker-compose.yml` and deploy those services into kind directly. This template chooses the split model when external services are shared across multiple kind clusters or maintained by a different team.

## Prerequisites

- Docker Engine or Docker Desktop
- kind (Kubernetes in Docker)
- kubectl (version-aligned with the kind node image)
- The `docker compose` plugin

## Layout

| Path | What it is |
|---|---|
| `kind-config.yaml` | kind cluster topology: one control-plane node with port mappings plus two worker nodes |
| `docker-compose.yml` | External services (PostgreSQL, Redis) that run outside the Kubernetes cluster |
| `bootstrap.sh` | Provisions the kind cluster and starts external services in one command |
| `k8s/app.yaml` | Sample Deployment, Service, and ConfigMap that connect to PostgreSQL |
| `.env.example` | Tunable variables — cluster name, ports, credentials |
| `secrets/` | Placeholder files for secrets mounted as files by the Compose services |

## Steps

1. Copy the environment file: `cp .env.example .env`.
2. Set up the database secret: `cp secrets/db_password.txt.example secrets/db_password.txt` and fill in a password.
3. Provision the cluster and start external services: `./bootstrap.sh`.
4. Deploy the sample application: `kubectl apply -f k8s/app.yaml`.
5. Confirm the pod is running: `kubectl get pods -l app=sample-app`.

## Verify

- `docker ps` shows the `postgres` and `redis` containers in a `running` state.
- `kubectl cluster-info` returns the Kubernetes API address.
- `kubectl get nodes` lists one control-plane and two worker nodes, all `Ready`.
- `kubectl get pods` shows the sample app pod in `Running` state.

## Common errors

- **kind cluster name collision**: if a cluster named `dev` already exists, `kind create cluster` fails. Override with `CLUSTER_NAME=my-cluster ./bootstrap.sh` or delete the old cluster with `kind delete cluster --name dev`.
- **External service not reachable from pods**: kind nodes route to the host network, so Compose services must bind to `0.0.0.0` (the compose file does this by default). If a pod cannot connect, check that the port in `k8s/app.yaml` matches the host port exposed by Compose.
- **kubectl version mismatch**: kind and kubectl must agree on minor version. Run `kind create cluster` with a node image whose Kubernetes version matches the locally installed `kubectl`.
- **Secret file missing**: the Compose `postgres` service reads its password from `/run/secrets/db_password`. If `secrets/db_password.txt` is absent the container starts but fails to initialize the database.
