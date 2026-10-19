#!/usr/bin/env bash
# last_verified: 2026-10-19 · helm n/a
# Install Helm, add the stable repo, update, and deploy a test chart.

set -euo pipefail

main() {
  echo "Installing Helm..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

  echo "Adding stable chart repository..."
  helm repo add stable https://charts.helm.sh/stable

  echo "Updating repositories..."
  helm repo update

  echo "Deploying test chart (nginx-ingress)..."
  helm install my-nginx stable/nginx-ingress --namespace ingress --create-namespace

  echo "Verifying with 'helm version'..."
  helm version
}

main "$@"