---
last_verified: 2026-10-21
tool_version: n/a
---

# What tripped me up with depends_on and healthchecks

I followed a tutorial that added a `depends_on` block and I assumed it meant "wait until the database is actually ready." It did not. Compose started the db container and immediately started the web container, and web kept crashing because the db wasn't accepting connections yet.

## What I tried

- Added `depends_on: [db]` to the web service. Compose ordered startup, but web still failed on first try.
- Switched to the long form with `condition: service_healthy` and added a healthcheck to db. That worked, but only after I figured out the healthcheck command itself.

## Got stuck on

- `depends_on` without a condition only controls start order, not readiness. I had to read the docs twice to accept that.
- Healthcheck commands run inside the container. My first attempt used `curl localhost:5432`, which failed because the postgres image has no curl. `pg_isready` worked.
- The `interval` and `retries` matter. With too few retries the web service gave up before db finished its first init.
- `restart: on-failure` masked the real problem for a while — the container kept restarting and I thought it was working.

## What I'd try next

I want to write a small stack with web, db, and cache where each dependency waits on a real healthcheck, and then add a lifecycle script that waits for healthy before printing "ready."
