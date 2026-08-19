#!/usr/bin/env bash
# last_verified: 2026-08-19 · prometheus n/a
# First PromQL query via the Prometheus HTTP API.

curl -s 'http://localhost:9090/api/v1/query?query=up'
