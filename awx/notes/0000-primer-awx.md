---
last_verified: 2026-10-04
tool_version: n/a
---

# Ansible Tower / AWX — quick primer

> First-day notes for someone who's never used Ansible Tower / AWX. Personal voice, plain language.

## What is it?

I just learned that AWX is the web UI and control plane that sits on top of Ansible. I already know Ansible runs playbooks from my laptop over SSH, and that works fine for one person. AWX is what teams use when "just run the playbook" stops being enough — it adds a shared place to store inventories, click a button to launch a job, watch the output stream by, and look up who launched what last Tuesday.

My mental model right now: AWX is to Ansible what a shared CI server is to running scripts by hand — same underlying engine, but with scheduling, access control, and history built in. Tower is the supported product version of the same idea, and AWX is its upstream project where new bits land first.

## What does it do?

It lets me point a job at a playbook stored in source control, pick which inventory it should run against, hand it the right credential, and launch it — from a browser instead of a terminal. It keeps a record of every run: the output log, the timing, and which user or schedule kicked it off. It also lets me set jobs on a timer so routine runs happen on their own.

## Why does it exist?

Before something like this, I imagine the team workflow was a shared login on one machine, a pile of shell history, and a chat message saying "don't run the deploy playbook right now, I'm running it." Credentials lived in whoever's home directory set things up first, and nobody could say for sure which inventory file the last run used. AWX exists to fix exactly that: one shared source of truth for inventories and credentials, one launch button everyone uses, and a job history that answers "what ran, when, and did it work" without asking around. The day-to-day users are the folks who run automation for others — they set up the templates once, and the rest of the team just launches them.

## Key terminology

- **Inventory** — the list of hosts and groups a job runs against. Example: an inventory with a `web` group holding three hosts.
- **Credential** — a stored secret a job uses to connect, like an SSH key or a vault password. Example: attaching one machine credential to a template so launchers never see the key itself.
- **Project** — a playbook source, usually a repo and branch AWX syncs on a timer. Example: a project tracking the main branch of the team's automation repo.
- **Job template** — a saved launch recipe tying together a project, a playbook, an inventory, and a credential. Example: a template named "deploy web" that runs `site.yaml` against the `web` group.
- **Job** — a single run of a template, with its own log and status. Example: last night's scheduled run of "deploy web" showing changed versus failed hosts.
- **Schedule** — a timer attached to a template. Example: running the patching template every Sunday morning.
- **Workflow** — several templates chained with success/failure branches. Example: provision, then configure, then run checks, stopping if any step fails.
- **Role-based access** — who is allowed to see or launch what. Example: letting the on-call crew launch the restart template but not edit it.

## A tiny example

The smallest "hello world" I can picture is launching a ping against one host from the UI:

```
Inventories -> Demo -> Hosts -> myhost
Templates -> "hello ping" -> Launch
Jobs -> watch the run go green
```

That flow does in clicks what `ansible myhost -m ping` does from a terminal — it just runs through a saved template with a stored inventory and credential, and the output lands in the job record where anyone on the team can read it.

## What I'll cover next

Now that I have the vocabulary, I want to actually click through the UI myself — find where inventories, credentials, and templates live, and launch something harmless to see what a job record looks like. After that I want to peek at the API behind one of those pages, since everything the UI does seems to map to an API call I could script later.
