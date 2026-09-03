---
last_verified: 2026-09-03
tool_version: n/a
---

# How I wired Docker Compose healthchecks into service startup ordering

> Notes on using Docker Compose healthchecks to control when dependent services start, instead of relying on fixed delay-based waits.

## Purpose

Docker Compose starts containers in dependency order declared by `depends_on`, but by default it only waits for the dependency container to start — not for the service inside it to be ready. This creates a race condition where, for example, a web application tries to connect to a database before the database is accepting connections. The goal here is to wire healthchecks into the Compose file so that `depends_on` actually waits for a service to pass its own internal readiness check.

## When to use

This pattern applies whenever one service needs another to be fully ready before it starts. Common pairs include an application container depending on a database, cache, or message broker. It is less useful for services that can tolerate connection retries on their own, since most client libraries already implement backoff and reconnect logic.

## Prerequisites

- A Docker Compose project with at least two services that have a startup-order dependency.
- The ability to modify the `docker-compose.yml` file for the project.
- A way to verify that the downstream service is ready (a built-in healthcheck endpoint, a TCP port probe, or a command that returns zero when the service is healthy).

## Steps

1. **Add a healthcheck to the dependency service.** The `healthcheck` block lives inside the service definition and specifies a command, an interval, a timeout, a retry count, and a start period. For a database, this might be a shell command that attempts a connection; for an HTTP service, a `curl` against a health endpoint.

2. **Switch `depends_on` to a condition-based form.** Instead of the simple string form (`depends_on: - db`), use the mapping form with `condition: service_healthy`. Compose will then poll the dependency's health status and only mark the condition satisfied after the service reports `healthy`.

3. **Tune the healthcheck cadence to match the service's actual startup time.** A service that takes several seconds to initialize needs a longer `start_period` and a more generous `retries` count than a service that is ready almost immediately. If the healthcheck is too aggressive, Compose marks the container unhealthy before the service has had a chance to finish its own initialization.

4. **Verify the ordering from the outside.** After bringing the stack up, run `docker compose ps` and confirm that the dependent service shows a state of `healthy` for its dependency before it transitions to `running`. You can also inspect the container's health status directly with `docker inspect` to see the healthcheck log.

## Verify

Bring the stack up with `docker compose up` and watch the startup sequence. The dependency service should reach `healthy` status before the dependent service starts. A quick `docker compose ps` should show the dependency with `(healthy)` in the state column and the dependent service only beginning its startup after that point.

## What tripped me up

- **Healthcheck command ran but never returned healthy.** I had a PostgreSQL healthcheck that used the wrong port and missing credentials. The command failed regardless of whether the database was actually up. Fixing the connection string made the healthcheck pass reliably.

- **Service still started before the database was ready.** I initially left `depends_on` in the simple string form. Compose only waits for the container to start in that form, not for the service to be healthy. Switching to the mapping form with `condition: service_healthy` was the missing step.

- **Healthcheck was too aggressive and marked the service unhealthy.** My first attempt used a short `interval` and zero `start_period`. The database was still initializing when the first healthcheck ran, so Compose killed it before it could finish. Adding a `start_period` and increasing `retries` gave the service enough breathing room.

## References

No external sources were used for this walkthrough.
