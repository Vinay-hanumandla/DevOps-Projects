# last_verified: 2026-07-17 · Docker n/a
#
# Multi-stage build producing a minimal runtime image with a pinned
# base-image tag and a non-root user.
#
# I split this into build + runtime stages so the final image has no
# build tools or cached files — just the server and the Python runtime.
# Using a specific tag (not :latest) so rebuilds don't silently pull a
# different Python patch version.

# --- build stage ---
FROM python:3.12-slim-bookworm AS build

WORKDIR /app
COPY src/2026-07-16-server.py server.py
# Pre-compiling in the build stage catches syntax errors during
# docker build rather than at container start — saves a cycle.
RUN python -m py_compile server.py

# --- runtime stage ---
FROM python:3.12-slim-bookworm

# Docker containers run as root by default. Research flagged this as
# a top beginner mistake. Creating a system user so the process has
# no unnecessary capabilities.
RUN addgroup --system appgroup \
    && adduser --system --ingroup appgroup --uid 1001 appuser

WORKDIR /app
COPY --from=build /app/server.py .

USER appuser

EXPOSE 8000
CMD ["python", "server.py"]
