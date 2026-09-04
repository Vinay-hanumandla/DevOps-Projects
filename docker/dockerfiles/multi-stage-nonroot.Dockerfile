# last_verified: 2026-09-04 · Docker 29.2.0
#
# Production-style multi-stage Dockerfile for a Python web app.
# This is one approach — the docs also suggest BuildKit-only syntax
# (--mount=type=cache) for caching pip downloads across builds, but
# that locks you into BuildKit and isn't universally available yet.
#
# Key decisions:
#   1. Separate build stage so the final image has no compiler, pip,
#      or build-time files — just wheels + app source.
#   2. Non-root user with a pinned UID/GID so file ownership stays
#      predictable even if the base image's adduser defaults change.
#   3. COPY requirements.txt before app source so dependency layers
#      are cached independently of code edits.
#   4. .dockerignore is assumed — without one, the entire build
#      context (including .git, __pycache__, tests) ships into the
#      build stage. Worth double-checking if builds are slow.

# --- build stage -------------------------------------------------------
FROM python:3.12-slim-bookworm AS build

WORKDIR /build

# Install dependencies into /wheels so we can copy just the compiled
# output into the runtime image. --compile embeds .pyc files; --no-cache
# keeps the layer lean. The wheel directory isolates installed packages
# from the app source so we can COPY them separately.
COPY requirements.txt .
RUN pip install --no-cache-dir --compile -r /build/requirements.txt \
        -t /wheels

# App source goes last — code edits now only invalidate this layer
# (and anything below it), not the expensive dependency-install layer.
COPY . .

# --- runtime stage -----------------------------------------------------
FROM python:3.12-slim-bookworm

# Create a non-root user with explicit numeric IDs. The UID 1001 sits
# above the typical host-user range (1000) and avoids collision with
# the default nobody/nogroup accounts. Some guides suggest uid 1000;
# either works — the point is to not ship a root-running container.
RUN addgroup --system --gid 1001 appgroup \
    && adduser --system --uid 1001 --ingroup appgroup appuser

WORKDIR /app

# --chown transfers ownership so the non-root user can read the files
# without a chown step at runtime (which would require root).
COPY --from=build --chown=appuser:appgroup /wheels /usr/local/lib/python3.12/site-packages/
COPY --from=build --chown=appuser:appgroup /build /app

USER appuser

# gunicorn is the standard WSGI server for Python web apps in
# containers. It needs to be in requirements.txt — this Dockerfile
# doesn't install it separately. The --bind address 0.0.0.0:8000
# makes the server reachable from outside the container.
EXPOSE 8000
CMD ["python", "-m", "gunicorn", "--bind", "0.0.0.0:8000", "wsgi:app"]
