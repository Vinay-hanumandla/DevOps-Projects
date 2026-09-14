# last_verified: 2026-09-13 · python n/a
# Multi-stage Dockerfile for Python CLI tool
# Stage 1: build dependencies
FROM python:3.11-slim AS builder

WORKDIR /app

COPY pyproject.toml ./
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir build \
    && python -m build --wheel --no-isolation

# Stage 2: runtime
FROM python:3.11-slim AS runtime

RUN groupadd --gid 1000 appuser \
    && useradd --uid 1000 --gid appuser --create-home appuser

COPY --from=builder /app/dist/*.whl /tmp/
RUN pip install --no-cache-dir /tmp/*.whl \
    && rm -rf /tmp/*.whl

USER appuser
WORKDIR /home/appuser

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD ["my-cli", "status"]

ENTRYPOINT ["my-cli"]
CMD ["--help"]
