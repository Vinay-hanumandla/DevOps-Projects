#!/usr/bin/env bash
# last_verified: 2026-08-13 · bash
# Example single-purpose hook. Real projects put one concern per file here,
# e.g. 10-wait-for-db.sh, 20-migrate.sh, 30-healthcheck.sh.
set -Eeuo pipefail

echo "[hook] starting job in $(pwd)"