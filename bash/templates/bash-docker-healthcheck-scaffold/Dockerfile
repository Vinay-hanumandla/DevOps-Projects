# last_verified: 2026-08-15 · bash 5.3
# Runtime image for the health-check scaffold. Alpine base keeps it small;
# busybox-extras provides the nc used by the demo TCP responder. bash 5.3 is
# the shell of record, matching what the host scripts assume.
# This is a scaffold — pin a digest before using it in CI.
FROM bash:5.3-alpine

RUN apk add --no-cache busybox-extras && \
    addgroup -S app && adduser -S app -G app

COPY lib /opt/app/lib
COPY app /opt/app/app
COPY docker-entrypoint.sh /opt/app/docker-entrypoint.sh
COPY docker-entrypoint.d /docker-entrypoint.d

RUN chmod +x /opt/app/docker-entrypoint.sh /opt/app/app/*.sh /opt/app/lib/*.sh /docker-entrypoint.d/*.sh && \
    chown -R app:app /opt/app

USER app
WORKDIR /opt/app
ENTRYPOINT ["/opt/app/docker-entrypoint.sh"]
