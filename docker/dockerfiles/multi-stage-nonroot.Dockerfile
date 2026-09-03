# last_verified: 2026-09-03 · Docker n/a

# Multi-stage build: dependencies compile in the build stage and the
# runtime image ships only the wheels + app source — no compiler, no
# pip cache, no build-only files. A dedicated non-root user (pinned UID)
# runs the process so the container never starts as root.

# --- build stage ---
FROM python:3.12-slim-bookworm AS build

WORKDIR /build
COPY requirements.txt .
# --no-cache-dir keeps the layer lean; -t /wheels isolates the installed
# packages so we can copy just the compiled output into runtime.
RUN pip install --no-cache-dir --compile -r requirements.txt -t /wheels

# App source last so code edits invalidate the layer below, not the
# expensive dependency-install layer above.
COPY . .

# --- runtime stage ---
# Fresh minimal image — no GCC, no pip cache, no test fixtures.
FROM python:3.12-slim-bookworm

# Create a non-root user with explicit numeric IDs. Pinning the GID/UID
# avoids drift if base-image adduser defaults change between releases.
# This is one approach — the docs also suggest uid 1000, but 1001 sits
# safely above the typical host-user range.
RUN addgroup --system --gid 1001 appgroup \
    && adduser --system --uid 1001 --ingroup appgroup appuser

WORKDIR /app
# --chown transfers file ownership so the non-root user can read them.
COPY --from=build --chown=appuser:appgroup /wheels /usr/local/lib/python3.12/site-packages/
COPY --from=build --chown=appuser:appgroup /build /app

USER appuser

# gunicorn needs to be in requirements.txt — this is the standard WSGI
# server choice for Python web apps.
EXPOSE 8000
CMD ["python", "-m", "gunicorn", "--bind", "0.0.0.0:8000", "wsgi:app"]
