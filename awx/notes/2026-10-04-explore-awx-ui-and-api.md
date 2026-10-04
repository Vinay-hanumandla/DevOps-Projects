---
last_verified: 2026-10-04
tool_version: "24.6.1"
sources:
  - https://github.com/ansible/awx/releases
  - https://ansible-awx.mintlify.app/installation/docker-compose
---

# Poking around the AWX UI and API

> Second day with AWX (I pinned 24.6.1, paired Operator v2.19.1). Clicked through the UI, then peeked at the API behind it.

## What I clicked through

I got in via `https://localhost:8043/` — my browser complained about the self-signed certificate, which turns out to be expected. There was no default login, so I made one with `docker exec -ti tools_awx_1 awx-manage createsuperuser`, then loaded the demo content with `awx-manage create_preload_data` so I'd have something to look at.

The left side basically matched the primer vocabulary: Inventories (hosts and groups), Credentials (stored keys and secrets), Projects (playbook repos it syncs), Templates (the saved launch recipes), Jobs (each run with its log), Schedules (timers on templates), and Workflows (templates chained with pass/fail branches). I also found Users, Teams, and Roles — makes sense given the 24.6.1 changelog is mostly RBAC repair (managed RoleDefinitions, object-level roles on ExecutionEnvironments, the external Auditor role).

## Got stuck on

First start looked frozen — turns out it was running database migrations ("takes several minutes as the database is initialized"). At one point the web UI showed errors until I ran the UI build step on my machine (`make clean-ui ui`), then `awx-manage collectstatic --noinput` and `supervisorctl restart awx-web` inside the container. I also learned the compose path I'm on is dev/test/demo only — real servers use the Operator method instead.

## What I'd try next

Everything I clicked seems to map to an API call returning the same objects (templates, jobs, inventories) as JSON, so next I want to fetch one job record through the API and compare it with what the Jobs page shows.
