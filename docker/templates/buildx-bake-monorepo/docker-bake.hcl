# last_verified: 2026-09-21 · buildx bake template (version n/a)
# Monorepo Bake definition: one entrypoint to build every service with a shared
# remote cache, provenance attestations, and tags for two registries.
# Copy this directory into a monorepo root and adapt the service targets.

variable "REGISTRY_PRIMARY" {
  default = "ghcr.io/example"
}

variable "REGISTRY_MIRROR" {
  default = "registry.example.com/team"
}

variable "TAG" {
  default = "local"
}

variable "CACHE_REF" {
  # Registry location used for both cache import and cache export. Point it at
  # a repository the CI identity can read and write.
  default = "ghcr.io/example/monorepo-build-cache"
}

# The default group builds every service in dependency-free parallel.
group "default" {
  targets = ["api", "web"]
}

# Shared settings inherited by every service target below. Keeping cache and
# attestation policy in one place means a new service gets the same supply-chain
# posture by adding a single `inherits` line.
target "_common" {
  context    = "."
  platforms  = ["linux/amd64", "linux/arm64"]
  pull       = true
  cache-from = ["type=registry,ref=${CACHE_REF}"]
  cache-to   = ["type=registry,ref=${CACHE_REF},mode=max"]
  attest = [
    "type=provenance,mode=max",
    "type=sbom",
  ]
  output = ["type=registry"]
}

target "api" {
  inherits   = ["_common"]
  dockerfile = "services/api/Dockerfile"
  tags = [
    "${REGISTRY_PRIMARY}/monorepo-api:${TAG}",
    "${REGISTRY_MIRROR}/monorepo-api:${TAG}",
  ]
}

target "web" {
  inherits   = ["_common"]
  dockerfile = "services/web/Dockerfile"
  tags = [
    "${REGISTRY_PRIMARY}/monorepo-web:${TAG}",
    "${REGISTRY_MIRROR}/monorepo-web:${TAG}",
  ]
}

# Lightweight check target: builds without pushing, for pull-request pipelines.
target "check" {
  inherits = ["api"]
  output   = ["type=cacheonly"]
  tags     = []
  attest   = []
}
