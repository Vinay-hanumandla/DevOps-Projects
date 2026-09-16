# last_verified: 2026-09-16 · kubernetes n/a
#
# operator-dev.Dockerfile — development image for building and testing a
# Kubernetes operator or controller (k8s-018).
#
# Purpose: give operator authors a reproducible container for the inner loop —
# compile the manager binary, run unit tests, and iterate without installing a
# Go toolchain on the host.
# When to use: during development of a controller built with the standard Go
# scaffolding layout (cmd/manager entrypoint, api/ types, internal/controller
# reconcilers). Not a deployment artifact; the cluster runs a separate
# minimal runtime image.
# Steps: build with the builder target for a compile check, run the test
# target for the unit suite, then start the dev target and mount the repo
# over /workspace for live iteration.
# Verify: `docker build --target builder`, `docker build --target test`, and
# `docker run` on the dev target printing the manager version output below
# should all succeed.

# --- builder stage: compile the manager binary ---
FROM golang AS builder

WORKDIR /src

# Copy module manifests first so dependency downloads stay cached
# until the module set actually changes.
COPY go.mod go.sum* ./
RUN go mod download

COPY . .

# Compile-check plus static analysis before producing the binary.
RUN go vet ./... \
    && go build -o /out/manager ./cmd/manager

# --- test stage: run the unit suite ---
FROM builder AS test

# Fail the build if any package test fails; results stream to the build log.
RUN go test ./...

# --- dev stage: interactive loop with the built binary ---
FROM debian

# Shell and build tooling for running repo test helpers inside the container.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates make \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r operator && useradd -r -g operator -d /workspace -s /usr/sbin/nologin operator

WORKDIR /workspace

COPY --from=builder --chown=operator:operator /out/manager /usr/local/bin/manager

USER operator

# Prints the manager binary help so a fresh container self-describes.
CMD ["manager", "--help"]
