---
last_verified: 2026-08-01
tool_version: n/a
sources:
  - https://wowhow.cloud/blogs/bash-scripting-automation-devops-complete-guide-2026
  - https://oneuptime.com/blog/post/2026-02-08-how-to-plan-docker-container-communication-architecture/view
---

# Terraform — quick primer

> First-day notes on Terraform. What it is, how I used it, and the key ideas to know.

## What is it?

Terraform is a tool for defining infrastructure as code. Instead of clicking through a console to create servers, networks, and cloud resources, I write declarative configuration files that describe what I want. Terraform reads those files and figures out how to make the real infrastructure match what I described. It's like git for infrastructure — I can track changes, see what diffed between versions, and apply updates predictably.

## What does it do?

I write configuration files that declare the resources I need — things like virtual machines, networks, and storage. Terraform plans the changes it needs to make, shows me what it will create or modify, and then applies those changes to my cloud provider. It keeps a state file so it knows what already exists and can detect drift.

## Why does it exist?

Before Terraform, provisioning infrastructure meant clicking through web consoles or writing fragile shell scripts that called cloud APIs. Those scripts were hard to share, hard to version, and easy to get wrong. Terraform lets a team treat infrastructure like software — write it once, review it, version it, and reuse it across environments.

## Key terminology

- **Provider** — a plugin that knows how to talk to a specific cloud or service. Example: the AWS provider lets Terraform create EC2 instances and S3 buckets.
- **Resource** — a single piece of infrastructure I declare in a config file. Example: `aws_instance.example` represents a virtual machine.
- **State file** — Terraform's record of what it has created. It maps my config files to real resources so Terraform knows what to update or skip.
- **Plan** — Terraform's preview of what changes it will make before applying them. I run `terraform plan` to review the diff before committing changes.
- **Apply** — the command that makes the planned changes real. After I approve the plan, `terraform apply` creates or updates resources.

## A tiny example

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

This declares a single EC2 instance using a specific Amazon machine image and a small instance type. Running `terraform apply` would create this instance in AWS.

## What I'll cover next

I want to try writing a config with multiple resource types and see how Terraform handles dependencies between them. Next I'll also explore how to use variables and outputs to make configs reusable across environments.