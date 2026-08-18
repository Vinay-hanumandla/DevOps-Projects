---
last_verified: 2026-08-18
tool_version: n/a
sources: []
---

# Combining IaC with Scripting & Automation Philosophy — parameterised config generation

> This pattern combines infrastructure-as-code with scripting and automation so that one template plus a small parameter set produces every environment's config.

## Purpose

Dev, staging, and prod usually want the same infrastructure shape and differ only in a handful of values: names, CIDR blocks, sizes, and maybe a port. Hand-copying a full config per environment is where drift creeps in — a change lands in one file and silently misses the others. Parameterised config generation inverts that: keep ONE template with placeholders, keep a tiny parameter set per environment, and let a script render the concrete config from those parameters.

IaC supplies the discipline — the template and parameters live in version control, are reviewable, and produce declarative output. Scripting & Automation Philosophy supplies the habit: generate, don't hand-edit. The two combine so that changing an environment is a one-line parameter edit followed by a re-render, not a multi-file search-and-replace.

## Prerequisites

- **Infrastructure as Code Principles** — declarative config, idempotency, and state, because the rendered output only earns its value if it is applied and reconciled by an IaC tool.
- **Scripting & Automation Philosophy** — variables, loops, and heredocs, because the generator script is the other half of this pattern.

## Steps

1. **Define the parameter set.** List what actually varies per environment — name, CIDR, instance size. Keep it small; every extra parameter is a new place to make a mistake.
2. **Write one template.** Create a single config file with placeholders for the parameters. Heredocs in a script or a template engine both work; the point is one source of shape.
3. **Write the generator script.** The script reads the parameter set and writes out the rendered config file. A working miniature is the companion `scripts/generating-docker-compose-configs.sh`, which turns a service list into a Compose file.
4. **Version-control the template and parameters.** Treat the rendered config as a build artifact that can be regenerated at any time, rather than a hand-maintained source.
5. **Apply with the IaC tool.** Run the generated config through the tool's plan/apply cycle; re-applying reconciles any drift back to the parameters.

## Verify

- Render two environments from the same template and diff the outputs — they should differ only in the parameterised fields.
- Re-run the generator with unchanged inputs and confirm the output is identical (deterministic rendering).
- Feed the rendered config to the IaC tool's validation or plan step and confirm it is accepted.

## How this connects to what's next

This pattern is exactly the mechanism behind tool-native parameterisation: Helm values + templates, Terraform variables and `.tfvars`, Ansible vars + Jinja2. Once the pattern is clear in a plain script, those tools stop being magic — they are the same template-plus-parameters idea, formalised. The network topology generator in this folder's `scripts/` applies the same idea to a VPC and its subnets.
