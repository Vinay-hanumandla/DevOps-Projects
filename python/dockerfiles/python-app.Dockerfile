# last_verified: 2026-09-14 · python n/a
#
# python-app.Dockerfile — Production multi-stage build for a Python web service
# This is one pattern that works well for FastAPI/Flask/Django apps.
# Stage 1 builds the wheel; stage 2 runs it in a slim image as non-root.

FROM python:3.12-slim AS builder

WORKDIR /build

# Install build dependencies if your project compiles C extensions
# (remove this block if pure-Python only)
RUN pip install --no-cache-dir build

COPY pyproject.toml README.md ./
COPY src/ ./src/

RUN python -m build --wheel --outdir /build/dist

# --- runtime stage ---
FROM python:3.12-slim AS runtime

# Create a non-root user before copying anything
RUN groupadd -r appuser && useradd -r -g appuser -d /app -s /sbin/nologin appuser

WORKDIR /app

# Install only the wheel — no build tools in the final image
COPY --from=builder /build/dist/*.whl /tmp/
RUN pip install --no-cache-dir /tmp/*.whl && rm -rf /tmp/*.whl

# Copy application config if needed at runtime
COPY config/ ./config/

# Switch to non-root user
USER appuser

# Expose the default port (adjust if your app listens elsewhere)
EXPOSE 8000

# A simple HTTP-based healthcheck — adjust the path for your framework
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"]

# Use exec form so Python gets SIGTERM for graceful shutdown
CMD ["python", "-m", "uvicorn", "src.app:app", "--host", "0.0.0.0", "--port", "8000"]
