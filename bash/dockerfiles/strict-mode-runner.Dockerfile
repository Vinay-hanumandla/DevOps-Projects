# last_verified: 2026-08-15 · bash 5.3

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN groupadd -r appuser && useradd -r -g appuser -d /app -s /usr/sbin/nologin appuser

WORKDIR /app

RUN cat > /usr/local/bin/run.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
set -x

echo "Strict-mode runner started as $(id -un)"
exec "$@"
EOF
RUN chmod +x /usr/local/bin/run.sh

USER appuser

ENTRYPOINT ["/usr/local/bin/run.sh"]
CMD ["bash", "-c", "echo Strict-mode container ready"]
