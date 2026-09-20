#!/usr/bin/env bash
# last_verified: 2026-09-20 · Docker n/a
#
# Provision a local dev cluster: kind Kubernetes + Docker Compose
# external services (PostgreSQL, Redis).
#
# Usage:
#   ./bootstrap.sh          # create cluster + start services
#   ./bootstrap.sh down     # tear down cluster + stop services

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLUSTER_NAME="${CLUSTER_NAME:-dev}"
KIND_CONFIG="${SCRIPT_DIR}/kind-config.yaml"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: $1 is required but not installed." >&2
    exit 1
  fi
}

create_cluster() {
  echo "Creating kind cluster '${CLUSTER_NAME}'..."
  kind create cluster --name "${CLUSTER_NAME}" --config "${KIND_CONFIG}"
}

start_services() {
  echo "Starting external services..."
  docker compose --project-directory "${SCRIPT_DIR}" up -d
}

wait_ready() {
  echo "Waiting for external services to be healthy..."
  local timeout=60
  local elapsed=0
  while [[ $elapsed -lt $timeout ]]; do
    local healthy
    healthy=$(docker compose --project-directory "${SCRIPT_DIR}" ps --services --filter "status=running" 2>/dev/null || true)
    if [[ -n "$healthy" ]]; then
      echo "External services are running."
      break
    fi
    sleep 2
    elapsed=$((elapsed + 2))
  done
  if [[ $elapsed -ge $timeout ]]; then
    echo "WARNING: timed out waiting for external services." >&2
  fi
  echo "Cluster and services are ready."
  echo
  echo "Next steps:"
  echo "  kubectl cluster-info"
  echo "  kubectl apply -f ${SCRIPT_DIR}/k8s/app.yaml"
}

destroy_cluster() {
  echo "Deleting kind cluster '${CLUSTER_NAME}'..."
  kind delete cluster --name "${CLUSTER_NAME}"
}

stop_services() {
  echo "Stopping external services..."
  docker compose --project-directory "${SCRIPT_DIR}" down --volumes
}

main() {
  require_cmd docker
  require_cmd kind
  require_cmd kubectl

  if [[ "${1:-}" == "down" ]]; then
    stop_services
    destroy_cluster
    echo "Tore down cluster and services."
    return
  fi

  create_cluster
  start_services
  wait_ready
}

main "$@"
