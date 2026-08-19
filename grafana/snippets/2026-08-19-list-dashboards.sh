#!/usr/bin/env bash
# last_verified: 2026-08-19 · grafana n/a
# First curl call to the Grafana HTTP API to list dashboards.

curl -s http://localhost:3000/api/dashboards
