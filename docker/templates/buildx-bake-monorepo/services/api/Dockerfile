# last_verified: 2026-09-21 · buildx bake template (version n/a)
# Minimal runtime for the monorepo API placeholder. No third-party installs;
# the service is a single stdlib file so the image stays small and auditable.
FROM python:slim
WORKDIR /srv
COPY services/api/server.py ./server.py
EXPOSE 8080
CMD ["python", "server.py"]
