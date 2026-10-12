# last_verified: 2026-10-12 · terraform n/a
#
# Prod environment: same module, same shape — only the inputs differ.
# Cost-centre and ownership tags are required here, not optional.

project      = "example"
environment  = "prod"
cost_center  = "production-workloads"

extra_tags = {
  Owner       = "platform-team"
  Criticality = "high"
}