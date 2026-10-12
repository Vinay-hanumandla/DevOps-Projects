# last_verified: 2026-10-12 · terraform n/a
#
# Staging environment: mirrors prod inputs as closely as possible so release
# candidates are exercised under realistic names and tags.

project      = "example"
environment  = "staging"
cost_center  = "staging-validation"

extra_tags = {
  Owner = "platform-team"
}