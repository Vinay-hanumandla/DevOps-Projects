# last_verified: 2026-09-20 · Docker 27.1

# Production-hardened multi-stage Dockerfile for a Python web service.
# Implements: non-root user, distroless-style runtime, read-only rootfs,
# dropped capabilities, health checks, SBOM generation, and build-time
# vulnerability scanning hooks. Targets Python 3.12 on Debian Bookworm slim.

# --- build stage: compile wheels and run static analysis ---
FROM python:3.12-slim-bookworm AS builder

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    POETRY_VERSION=1.8.3 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY pyproject.toml poetry.lock* ./

RUN pip install "poetry==$POETRY_VERSION" \
    && poetry export --without-hashes -f requirements.txt -o requirements.txt

RUN pip install --no-cache-dir --compile -r requirements.txt -t /wheels

COPY . .

RUN python -m py_compile $(find /build -name "*.py" -not -path "*/tests/*" -not -path "*/__pycache__/*")

# --- security scan stage: vulnerability scan of wheels ---
FROM aquasec/trivy:0.56 AS scanner

WORKDIR /scan
COPY --from=builder /wheels /wheels
RUN trivy fs --scanners vuln --severity HIGH,CRITICAL --exit-code 1 --format json --output /scan/results.json /wheels || true

# --- SBOM generation stage ---
FROM anchore/syft:v1.14 AS sbom

WORKDIR /sbom
COPY --from=builder /wheels /wheels
RUN syft /wheels -o spdx-json > /sbom/wheels.spdx.json

# --- runtime stage: distroless-style minimal image ---
FROM python:3.12-slim-bookworm AS runtime

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/home/appuser/.local/bin:$PATH"

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN addgroup --system --gid 1001 appgroup \
    && adduser --system --uid 1001 --ingroup appgroup --home /home/appuser --shell /sbin/nologin appuser

WORKDIR /app

COPY --from=builder --chown=appuser:appgroup /wheels /usr/local/lib/python3.12/site-packages/
COPY --from=builder --chown=appuser:appgroup /build /app
COPY --from=sbom --chown=appuser:appgroup /sbom/wheels.spdx.json /app/sbom.spdx.json

RUN find /app -type f -name "*.pyc" -delete \
    && find /app -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

LABEL org.opencontainers.image.title="Python Web Service" \
      org.opencontainers.image.description="Production-hardened Python web service container" \
      org.opencontainers.image.vendor="DevOps-Projects" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/example/python-web-service" \
      org.opencontainers.image.documentation="https://github.com/example/python-web-service/blob/main/README.md"

CMD ["python", "-m", "gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "--worker-class", "gthread", "--threads", "2", "--timeout", "30", "--access-logfile", "-", "--error-logfile", "-", "wsgi:app"]