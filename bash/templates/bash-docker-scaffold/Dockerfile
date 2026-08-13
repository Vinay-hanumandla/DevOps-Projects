# last_verified: 2026-08-13 · bash
# Dev-toolchain image: brings shellcheck + shfmt + bats so the host stays clean.
# The official bash image is Alpine-based, so packages come from apk.
# This is a scaffold — pin a digest here before using it in CI.
FROM bash:latest

RUN apk add --no-cache shellcheck shfmt bats

WORKDIR /work
ENTRYPOINT ["/bin/bash"]