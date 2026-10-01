# last_verified: 2026-09-30 · Docker Engine 29.8.2

# Production distroless Dockerfile with a vulnerability-scan gate (docker-021).
#
# Purpose: one Dockerfile with several named final stages — build, test, and a
# lean production stage — so CI can run `docker build --target test` for checks
# and ship only the distroless runtime. The SBOM travels as a build attestation
# retrieved via GET /images/{name}/attestations (in-toto statements: SLSA
# provenance, SPDX SBOM), and the pushed digest is promoted only after the
# scanner reports clean.
# Sources:
# - https://docs.docker.com/build/building/multi-stage/
# - https://docs.docker.com/engine/release-notes/29.md
#
# When to use: small Go services where you want a minimal, non-root runtime and
# a single file that covers build, test, and ship. For a Python service, the
# same stage layout applies with a different builder image.
#
# Prerequisites: Docker Engine with BuildKit enabled; a registry to push to; a
# vulnerability scanner wired into the pipeline as a gate after push.
#
# Steps:
#   1. Build the test target and run the unit checks inside it:
#        docker build --target test -t svc:test .
#   2. Build the production target:
#        docker build --target production -t registry.example/svc:<tag> .
#   3. Push, fetch the attestation for the SBOM record:
#        GET /images/<name>/attestations
#   4. Run the vulnerability scan against the pushed digest; promote the digest
#      to the deployment repo only on a clean result.
#
# Verify: `docker build --target test` passes; the production image runs as the
# non-root user, has no shell, and the attestation endpoint returns the SBOM
# statement for the pushed reference.

# --- build: compile a static binary -----------------------------------------
# Builder pinned to the research-backed doc example base. Stages are named with
# AS <NAME> so COPY --from survives later reordering (integer indices shift).
FROM golang:1.26 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
# Static binary: no libc in the distroless runtime, so CGO must stay off.
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -o /out/svc ./cmd/svc

# --- test: checks run here, test data stays out of production ----------------
# One Dockerfile, several named final stages: a testing stage vs production
# with real data. BuildKit builds only the target's dependency stages, so
# `--target test` never pulls the runtime stage.
FROM build AS test
RUN go vet ./...
RUN go test ./...

# --- production: minimal distroless runtime, non-root ------------------------
FROM gcr.io/distroless/static:nonroot AS production
WORKDIR /app
COPY --from=build /out/svc /app/svc
# Distroless images ship no shell, so there is nothing to exec into and no
# package manager to drift. Run as the image's non-root user.
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/app/svc"]
