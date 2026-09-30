# last_verified: 2026-09-30 · docker n/a
# Builder stage: collect the service sources. Runtime stage: copy only
# what the service needs and run as a non-root user. Stdlib only, so no
# install step is needed; the split still keeps build-time files out of
# the final image and gives each service the same two-stage shape.
FROM python AS builder
WORKDIR /src
COPY server.py ./

FROM python AS runtime
WORKDIR /srv
RUN useradd -r -u 10001 app && chown app /srv
COPY --from=builder /src/server.py ./
USER app
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --retries=3 --start-period=10s \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"
CMD ["python", "server.py"]
