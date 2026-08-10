---
last_verified: 2026-08-10
tool_version: n/a
sources:
  - https://www.ansiblebyexample.com/articles/how-to-install-ansible-all-platforms
  - https://kloudvin.com/article/ansible-installation-setup-ansible-cfg-first-connection/
---

# Ansible — quick primer

> First-day notes for someone who's never used Ansible. Personal voice, plain language.

## What is it?

Ansible is an automation tool that runs commands on remote machines over SSH. Think of it as `ssh` but scripted — instead of logging into each server by hand, you write a list of steps in a YAML file and Ansible walks through them for you. It's like a recipe book for servers: "on host X, do Y, then Z."

Unlike heavier tools (Chef, Puppet), Ansible doesn't need an agent installed on every machine it manages. It just SSHes in and runs commands. That's why it feels lighter than its competitors — there's no daemon to keep alive on every box.

## What does it do?

It lets you define the state you want your servers in and makes them get there. You write YAML "playbooks" that say things like "install nginx on these hosts" or "restart the database on that host," and Ansible figures out how to make it happen. Under the hood, the steps are modules — small reusable pieces of code that do one thing (like install a package, copy a file, or start a service).

## Why does it exist?

Before Ansible, sysadmins either typed commands manually into each server (slow, error-prone, no consistency) or used heavier tools like Puppet or Chef that needed an agent and a learning curve. Ansible came along and said: let's use SSH — something almost every Linux box already has — and make the automation language readable enough that you don't need to be a programmer to write it. The YAML configs read almost like a checklist.

## Key terminology

- **Control node** — The machine where Ansible runs and from which it connects to other machines. Example: my laptop running Ansible to configure my servers.
- **Managed node** — Any machine Ansible controls over SSH. Example: the web servers, database, and cache I'm configuring.
- **Playbook** — A YAML file listing the automated steps. Example: `site.yml` that installs packages, copies configs, and restarts services.
- **Inventory** — The list of managed nodes Ansible connects to. Can be a simple text file or pulled from a dynamic source.
- **Module** — A reusable chunk of code that does one job. Example: `apt` installs packages, `copy` writes files, `service` starts daemons.
- **Task** — A single call to a module. Example: `- name: install nginx` calls the `apt` module.
- **Role** — A grouping of tasks, files, and templates meant to be reused. Example: a `webserver` role that bundles nginx install + config + service.
- **Host key checking** — Ansible refuses to connect to unknown SSH hosts by default. First connection prompts for confirmation or uses `known_hosts`.
- **fact** — Information Ansible collects about a host (CPU, RAM, OS). Available as `ansible_facts` in templates and conditions.

## A tiny example

```yaml
- name: ping all hosts
  hosts: all
  tasks:
    - name: check connectivity
      ansible.builtin.ping:
```

This is Ansible's "hello world" — the `ping` module just confirms Ansible can SSH in and find Python on each host. Run it with `ansible-playbook ping.yml`.

## What I'll cover next

I want to actually install Ansible on my machine (the PEP 668 externally-managed-environment error already sounds familiar), write my first playbook against localhost, and then work through the common connection errors — host key verification, missing Python on the target, and SSH auth issues.