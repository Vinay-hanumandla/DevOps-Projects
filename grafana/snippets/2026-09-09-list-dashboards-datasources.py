#!/usr/bin/env python3
# last_verified: 2026-09-09 · grafana n/a · python requests

"""Minimal Grafana API query: list dashboards and datasources.

Run with:
    export GRAFANA_URL="http://localhost:3000"
    export GRAFANA_API_KEY="eyJr..."
    python 2026-09-09-list-dashboards-datasources.py
"""

import json
import os
import sys

import requests

GRAFANA_URL = os.environ.get("GRAFANA_URL", "http://localhost:3000")
GRAFANA_API_KEY = os.environ.get("GRAFANA_API_KEY", "")

if not GRAFANA_API_KEY:
    sys.exit("Set GRAFANA_API_KEY before running.")


def get_dashboards():
    # GET /api/search?query=&type=dash-json returns every dashboard the key can see.
    resp = requests.get(
        f"{GRAFANA_URL}/api/search",
        params={"query": "", "type": "dash-json"},
        headers={"Authorization": f"Bearer {GRAFANA_API_KEY}"},
        timeout=10,
    )
    resp.raise_for_status()
    return resp.json()


def get_datasources():
    # GET /api/datasources returns every provisioned or manually-added datasource.
    resp = requests.get(
        f"{GRAFANA_URL}/api/datasources",
        headers={"Authorization": f"Bearer {GRAFANA_API_KEY}"},
        timeout=10,
    )
    resp.raise_for_status()
    return resp.json()


def main():
    dashboards = get_dashboards()
    datasources = get_datasources()

    print(f"Dashboards ({len(dashboards)}):")
    print(json.dumps(dashboards, indent=2))

    print(f"\nDatasources ({len(datasources)}):")
    print(json.dumps(datasources, indent=2))


if __name__ == "__main__":
    try:
        main()
    except requests.exceptions.RequestException as exc:
        sys.exit(f"Request failed: {exc}")
