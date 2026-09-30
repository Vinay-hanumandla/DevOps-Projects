# last_verified: 2026-09-30 · docker n/a
# Same two-stage shape as the api service: builder gathers sources,
# runtime runs as non-root with only the worker file.
FROM python AS builder
WORKDIR /src
COPY worker.py ./

FROM python AS runtime
WORKDIR /srv
RUN useradd -r -u 10001 app && chown app /srv
COPY --from=builder /src/worker.py ./
USER app
CMD ["python", "worker.py"]
