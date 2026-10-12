# last_verified: 2026-10-12 · terraform n/a
#
# Dev environment: cheapest settings, verbose tagging so sandbox resources
# are easy to spot and clean up.

project     = "example"
environment = "dev"

extra_tags = {
  Owner    = "platform-team"
  Lifespan = "short-lived"
}