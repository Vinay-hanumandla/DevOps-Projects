---
last_verified: 2026-09-21
tool_version: n/a
---

# Terraform module composition patterns

## Purpose

Large Terraform configurations benefit from breaking work into modules, but how those modules are organized matters as much as the modules themselves. This document compares three composition patterns: root-module fan-out, a dedicated composition module, and Terraform stacks. Each pattern is a different answer to the same question: how do you keep a multi-team, multi-environment Terraform codebase readable, reusable, and safe to change?

## When to use

| Pattern | Use when... | Avoid when... |
|---|---|---|
| Root-module fan-out | You have a small number of environments and want each environment's `main.tf` to call modules directly. | More than a handful of environments, because the root module grows large and each environment duplicates the same module calls. |
| Dedicated composition module | You want one place that defines which modules belong together and how they are wired, so environments stay thin. | The composition layer adds indirection that confuses newcomers who just want to see a resource. |
| Terraform stacks | You need to orchestrate multiple independent Terraform configurations (modules or root modules) as a single deployable unit with dependencies between them. | Every configuration is small and can be applied by hand; stacks add orchestration overhead. |

## Prerequisites

- Terraform 1.6+ for stack support.
- Modules stored in a module registry or a shared source location.
- A clear ownership model for which team maintains which module.

## Pattern 1 — Root-module fan-out

In this pattern each environment is its own directory containing a root module that calls shared modules directly:

```
environments/
  prod/
    main.tf      → module "vpc" { source = "../modules/vpc" }
    main.tf      → module "database" { source = "../modules/database" }
  staging/
    main.tf      → module "vpc" { source = "../modules/vpc" }
    main.tf      → module "database" { source = "../modules/database" }
```

**Strengths:** Simple to understand. Each environment is self-contained and can be applied independently.

**Weaknesses:** The module call graph is repeated in every environment. A change to the arguments passed to a module must be made in every environment that calls it, which invites drift.

## Pattern 2 — Dedicated composition module

A composition module wraps the modules that belong together and exposes a single entry point. Environments call the composition module instead of the individual modules:

```
modules/
  platform/      → calls module "vpc", module "database", module "networking"
environments/
  prod/
    main.tf    → module "platform" { source = "../modules/platform" }
  staging/
    main.tf    → module "platform" { source = "../modules/platform" }
```

**Strengths:** One place to wire modules together. Adding a new module to the platform means changing the composition module, not every environment.

**Weaknesses:** Adds a layer of indirection. If the composition module is too generic it can hide important per-environment differences behind optional variables.

## Pattern 3 — Terraform stacks

A Terraform stack orchestrates multiple Terraform configurations as a single unit. Each configuration in the stack is a separate root module or a module, and the stack declares the dependencies between them:

```
stacks/
  platform.stack.yaml
    components:
      - name: network
        source: ./modules/network
      - name: database
        source: ./modules/database
        depends_on: [network]
      - name: app
        source: ./modules/app
        depends_on: [database]
```

**Strengths:** Applies multiple configurations in the correct order without manual `terraform apply` in each directory. Good for large platforms with clear dependency chains.

**Weaknesses:** Stacks are a newer feature and add a new concept to the toolchain. Debugging a failure requires understanding both the stack definition and the underlying configuration.

## Combining patterns

A common approach is to use a composition module for the common platform services and stacks for the parts of the platform that have complex ordering requirements. The composition module keeps the wiring in one place, and the stack ensures that dependent configurations are applied in the right order.

## Verify

- Run `terraform plan` in each environment and confirm the plan covers the expected resources.
- Change a variable in the composition module and confirm the change appears in every environment's plan.
- For stacks, run the stack in a dry-run mode and confirm the dependency order matches the declared `depends_on`.

## Common errors

| Symptom | Cause | Fix |
|---|---|---|
| Two environments drift because they duplicate module calls | Root-module fan-out without a composition layer | Extract the shared calls into a composition module. |
| Stack fails because a component cannot find its source | The `source` in the stack file is wrong or unreachable | Confirm the path or module registry reference is correct. |
| A composition module hides an environment-specific setting | The module uses a single variable where the environment needs different values | Add an override variable to the composition module so environments can pass per-environment values. |