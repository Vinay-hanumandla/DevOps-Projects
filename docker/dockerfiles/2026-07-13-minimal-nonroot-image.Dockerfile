# last_verified: 2026-07-13 · Docker n/a

# Multi-stage build: build stage uses the full Go image, runtime stage
# uses distroless so the final image is tiny and has no shell.
# Doing this as a multi-stage because the quickstart kept telling me images
# get bloated — this keeps the build deps out of the runtime layer.

# --- build stage ---
FROM golang:1.22-alpine AS build

WORKDIR /src
COPY main.go .
# CGO_ENABLED=0 because the runtime is distroless and has no libc
RUN CGO_ENABLED=0 go build -o /app/server .

# --- runtime stage ---
FROM gcr.io/distroless/base-debian12:nonroot

WORKDIR /app
COPY --from=build /app/server .

# distroless nonroot images already set USER to a non-root uid, but I'm
# being explicit here so it's visible in the Dockerfile.
USER 65532:65532

EXPOSE 8080
ENTRYPOINT ["/app/server"]
