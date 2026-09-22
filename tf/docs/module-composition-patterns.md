---
last_verified: 2026-09-22
tool_version: n/a
---

# Terraform module composition patterns

## Purpose

Once a Terraform codebase outgrows a single directory, the next question is where the wiring between modules should live. This doc compares three answers: root-module fan-out (each environment calls shared modules directly), a dedicated composition module (one module owns the wiring, environments stay thin), and orchestrated multi-configuration deploys (several configurations applied as one ordered unit, sometimes called stacks). The point is not which pattern is "best" — it is which trade-off fits the number of environments, the number of teams, and how much ordering the platform needs.

## When to use

| Pattern | Use when... | Avoid when... |
|---|---|---|
| Root-module fan-out | A few environments, one team, and each environment can be applied on its own. | Environment count keeps growing, because every environment repeats the same module calls and they drift apart. |
| Dedicated composition module | Several environments share the same platform shape and you want one place that defines it. | The platform shape differs so much per environment that the composition module becomes a pile of conditionals. |
| Orchestrated multi-configuration deploy | Configurations have a real deploy order (network before data before app) and must roll out as a unit. | Everything fits in one state and one apply; the orchestration layer is then overhead with no payoff. |

## Prerequisites

- Terraform CLI installed and a configuration you can already `plan` and `apply`.
- Shared modules kept in one known location (a registry or a shared directory) so every pattern references the same sources.
- Agreement on who owns which module — the patterns below mostly differ in where ownership boundaries fall.

## Pattern 1 — Root-module fan-out

Each environment is a directory with its own root module that calls the shared modules directly and passes outputs between them. The worked example is already in this kit at `../manifests/root-module-fan-out-composition.hcl` (the tf-020 artifact): a root module calling VPC, EKS, and RDS submodules, feeding VPC outputs into the other two, with an explicit dependency so the database waits for the cluster.

There is not much more to say about the mechanics — that manifest is the pattern. What matters for this comparison is how it scales: with two environments the duplication is trivial, with ten it is the dominant cost. Every new module argument has to be threaded through every environment directory, and sooner or later one environment gets missed. State stays per environment, which keeps the blast radius small, but there is no shared record of "these environments are supposed to look the same."

## Pattern 2 — Dedicated composition module

A composition module wraps the modules that belong together and exposes a single entry point. Environments stop calling individual modules and call the composition instead:

```hcl
module "platform" {
  source = "../modules/platform"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr

  tags = var.tags
}
```

The wiring that used to be repeated in every environment now lives inside `modules/platform`, which itself contains the `vpc`, `database`, and `networking` module blocks and the output-passing between them. Adding a module to the platform means editing the composition module once; every environment picks it up through its next plan.

The design pressure moves to the composition module's interface. It needs per-environment inputs (names, CIDRs, sizes) without turning into optional-variable soup, and it should only surface outputs that callers actually consume rather than re-exporting everything. When the per-environment differences start outweighing the shared shape — different module sets per environment, not just different values — that is the signal the composition layer is too generic and fan-out (or splitting the composition per platform tier) fits better.

## Pattern 3 — Orchestrated multi-configuration deploy

Sometimes one state and one apply is the wrong unit: the network, the data layer, and the app each deserve their own state and lifecycle, but they still have to roll out in order. The orchestration pattern keeps each configuration independent and records the deploy order separately, roughly like this layout:

```
stacks/
  platform/          <- orchestration record: which configurations, in which order
configurations/
  network/           <- own state, applied first
  database/          <- own state, applied after network
  app/               <- own state, applied last
```

Note what is deliberately missing above: a config-file sketch. The exact format of the orchestration record depends on the wrapper or platform doing the orchestrating, so showing one dialect's file would teach syntax that may not match the reader's setup. The transferable ideas are: each configuration keeps its own state, the order is written down in exactly one place instead of living in runbooks or memory, and a failure in an early configuration stops the later ones before they apply against missing dependencies.

## How the three differ

Fan-out and composition differ in **where the wiring lives** (repeated per environment vs. written once); orchestration differs in **what gets applied together** (one state vs. several states in a declared order). Put differently: fan-out vs. composition is a code-organization choice inside a single apply, while orchestration is a deploy-boundary choice across several applies. A common end state combines them — a composition module defines the shared platform shape, and an orchestration record orders the few configurations that cannot share a state (typically along blast-radius lines: network, data, app). If the setup only ever needs one of the two decisions, adding the other layer is indirection without benefit.

## Verify

- Run `terraform plan` in each environment and confirm the plan covers the expected resources before touching any wiring.
- After extracting shared calls into a composition module, re-run the plan in every environment and confirm it is empty (no diff) — the refactor changed organization, not infrastructure.
- Change one composition input and confirm the change shows up in every environment's plan.
- For the orchestrated pattern, walk the declared order and run `plan` per configuration in that sequence; confirm each configuration's inputs from the previous one resolve before anything is applied.

## Common errors

| Symptom | Cause | Fix |
|---|---|---|
| Two environments drift because they duplicate module calls | Fan-out with no composition layer; one environment missed an argument change | Extract the shared calls into a composition module so the wiring is written once. |
| A composition module hides a per-environment setting | One variable where environments need different values | Add an explicit per-environment input to the composition module instead of hardcoding the shared value. |
| A later configuration applies against a missing dependency | The deploy order lives in memory or a runbook rather than a written record | Write the order down in one orchestration record and apply strictly in that sequence. |
