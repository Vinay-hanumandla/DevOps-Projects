#!/usr/bin/env bash
# last_verified: 2026-10-19 · helm n/a
# Install Helm via the official install script and run `helm version`.

set -euo pipefail

main() {
  echo "Installing Helm..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

  echo "Verifying installation with 'helm version'..."
  helm version
}

main "$@"