# last_verified: 2026-07-16 · Docker 29.2.0

# Using a specific tag instead of :latest so rebuilds don't silently pull a
# different Python version — found that out the hard way last week.
FROM python:3.12-slim-bookworm AS build

WORKDIR /app
COPY 2026-07-16-server.py server.py
# Pre-compiling here catches syntax errors during the build step rather
# than when the container starts — saves a round-trip when iterating.
RUN python -m py_compile server.py

# Second stage uses the same tagged base image — no build tools carried over.
FROM python:3.12-slim-bookworm

# Docker runs as root by default, which the research doc flagged as risky.
# Creating a system user + group here so the process has no root capabilities.
RUN addgroup --system appgroup && adduser --system --ingroup appgroup --uid 1001 appuser

WORKDIR /app
COPY --from=build /app/server.py .

USER appuser

EXPOSE 8000
CMD ["python", "server.py"]
