---
last_verified: 2026-07-19
tool_version: n/a
sources:
  - https://about.gitlab.com/topics/ci-cd/
---

# Infrastructure as Code Principles — quick primer

> First-day notes on Infrastructure as Code. What it is, why it matters, and the key ideas before I write my first config.

## What is it?

Infrastructure as Code (IaC) is the practice of defining servers, networks, and other infrastructure in text files — declarative config or code — instead of clicking through a cloud console or running one-off commands. Those files live in version control, so the infrastructure can be created, changed, and torn down reproducibly.

It's like writing down a recipe instead of cooking from memory: anyone can recreate the exact same dish, you can see who changed the recipe and when, and you can roll back to last week's version if today's tastes wrong. Compare it to configuring machines by hand, where two "identical" servers drift apart because someone tweaked one and forgot.

## Why does it matter for DevOps?

Hand-built infrastructure suffers from "snowflake" servers — each one slightly different, undocumented, and scary to touch. When one dies, nobody is quite sure how to rebuild it. IaC fixes this: the config is the source of truth, so rebuilding is a single command, and every change is reviewable in a pull request.

For a DevOps practitioner, IaC is what makes the "deploy" stage of a CI/CD pipeline safe and repeatable. Tools like Terraform and Ansible are built on these principles, so understanding them first means the tooling later feels like a natural implementation rather than a black box.

## Key terminology

- **Declarative** — you state the desired end state, not the steps. Example: "3 web servers exist" rather than "create a server, then another…".
- **Idempotency** — running the same config twice produces the same result. Example: applying a playbook again doesn't create a second duplicate server.
- **State** — a record of what infrastructure currently exists. Example: Terraform's state file tracks real resources vs. the config.
- **Drift** — when real infrastructure diverges from the config. Example: someone manually edited a setting in the console.
- **Provisioning** — creating the base resources (VMs, networks). Example: Terraform provisions a VPC and instances.
- **Configuration management** — setting up software on existing machines. Example: Ansible installs and configures Nginx.
- **Source of truth** — the version-controlled config everyone trusts. Example: the repo, not the cloud console, defines reality.
- **Immutable infrastructure** — replace, don't patch, a server. Example: deploy a new image version rather than SSHing in to upgrade.

## A concrete example

The mental loop of IaC, regardless of the tool:

```
write config (want: 2 servers)
   -> apply  ->  tool creates 2 servers, records state
   -> someone deletes one by hand (drift)
   -> re-apply  ->  tool sees only 1, recreates the missing 1 (idempotent)
```

This idempotency is the whole point: the config describes the goal, and re-applying always reconciles reality back to it.

## How this connects to what's next

IaC underpins Terraform, Ansible, and Helm later on, and it's the "deploy" foundation that CI/CD pipelines hand off to. Once I'm comfortable with declarative state and idempotency here, those tools will click into place, and the container images from the previous concept become something I can provision and manage as code.
