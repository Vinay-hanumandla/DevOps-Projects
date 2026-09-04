# last_verified: 2026-09-04 · Docker n/a

# Production-style multi-stage Dockerfile for a Python web app.
# The build stage compiles dependencies into isolated wheels; the
# runtime stage copies only those wheels plus the app source, so the
# final image contains no compiler, pip cache, or test fixtures.
# A dedicated non-root user (pinned UID/GID) owns the files and
# runs the process.

# --- build stage ---
FROM python:3.12-slim-bookworm AS build

WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --compile -r requirements.txt -t /wheels

COPY . .

# --- runtime stage ---
FROM python:3.12-slim-bookworm

# Create a non-root user with explicit numeric IDs. Pinning the GID/UID
# avoids drift if the base image's adduser defaults change between
# releases. UID 1001 sits above the typical host-user range (1000)
# and avoids collision with default nobody/nogroup accounts.
RUN addgroup --system --gid 1001 appgroup \
    && adduser --system --uid 1001 --ingroup appgroup appuser

WORKDIR /app
COPY --from=build --chown=appuser:appgroup /wheels /usr/local/lib/python3.12/site-packages/
COPY --from=build --chown=appuser:appgroup /build /app

USER appuser

EXPOSE 8000
CMD ["python", "-m", "gunicorn", "--bind", "0.0.0.0:8000", "wsgi:app"]
