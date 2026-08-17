#!/usr/bin/env bash
# last_verified: 2026-08-17 · bash 5.3
# Tear down the stack. Runs as its own script so a half-started bring-up can be
# cleaned up from the same entry point the up.sh used.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
# shellcheck disable=SC1091
source "$ROOT/lib/common.sh"

require_command docker

cd "$ROOT"
log "stopping stack"
docker compose down
