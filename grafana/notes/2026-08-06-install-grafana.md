---
last_verified: 2026-08-06
tool_version: n/a
sources:
  - https://techresources.net/groups/architecture-platforms-cloud-eng/devops-monitoring-observability-guide/
---

# Install Grafana and open the web UI for the first time

I pulled the Grafana Docker image and ran it locally. The container started without issues and I could reach the login page at `localhost:3000`. Default credentials are admin/admin — I logged in and saw the empty dashboard view. I added Prometheus as a data source next, but that's for the next session.