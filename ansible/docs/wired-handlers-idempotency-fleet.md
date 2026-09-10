---
last_verified: 2026-09-10
tool_version: "2.21.4"
sources:
  - https://www.ssdnodes.com/learn/ansible-tutorial-first-playbook-vps
  - https://moldstud.com/articles/p-top-common-mistakes-in-first-ansible-playbooks-and-how-to-avoid-them
  - https://docs.ansible.com/projects/ansible/latest/tips_tricks/sample_setup.html
---

# How I wired Ansible handlers and idempotency checks into fleet configuration

## Purpose

When managing a fleet of machines instead of a single host, the playbook needs to do two things reliably: restart a service only when its configuration actually changed, and report `changed=0` on a second run. Handlers handle the first; idempotency checks handle the second. This doc records how I combined both into a small fleet playbook that configures SSH hardening, UFW, sysctl, and fail2ban across a group of VPS hosts.

## Steps

1. **Write tasks that notify handlers instead of restarting inline.** Every config-writing task (`copy`, `template`, `lineinfile`) carries a `notify:` line naming a handler. The handler itself is a normal task listed under a `handlers:` section. Ansible runs handlers once at the end of the play, after all tasks have completed — so if three tasks all notify `restart sshd`, sshd restarts exactly once.

2. **Use `meta: flush_handlers` when a later task depends on the restart.** After deploying a new sshd config and notifying `restart sshd`, the next task that needs the new config (for example, a connection test) should be preceded by `meta: flush_handlers`. Without it, the restart happens at play end and the dependent task runs against the old sshd.

3. **Validate config before writing it.** The `copy` and `template` modules accept a `validate:` argument that runs a command against the staged file (`%s` is the placeholder for the temp path). For sshd, use `validate: "sshd -t -f %s"`. For sudoers, use `validate: "visudo -cf %s"`. If validation fails, the task is skipped and the live config is untouched.

4. **Run the playbook twice and confirm `changed=0`.** The first run reports `changed` for every task. The second run should report `ok` (not `changed`) for every task — that is the idempotency check. If any task still reports `changed`, the module is not actually idempotent and needs a different module or a `changed_when:` clause.

5. **Use `--check --diff` as a safety net before applying.** `ansible-playbook -i inventory fleet.yml --check --diff` shows what would change without touching the hosts. It is the closest thing to a dry run Ansible offers, and it is safe to run on production fleets.

## Verify

- `ansible-playbook -i inventory fleet.yml` — first run shows `changed` for config tasks; second run shows `ok`.
- `ansible-playbook -i inventory fleet.yml --check --diff` — shows the planned changes with no modifications made.
- `ansible-playbook -i inventory fleet.yml --syntax-check` — catches YAML errors before any connection is attempted.

## What I hit along the way

- **Handlers did not fire because the task name changed.** `notify:` matches handler *names*, not task names. Renaming a task but forgetting to update the notify line silently skipped the restart. The playbook "succeeded" but sshd kept running with the old config.
- **`flush_handlers` ran the handler before the config was written.** I put `meta: flush_handlers` at the top of the play by mistake, which flushed nothing and then the real flush at the end worked. The placement matters — it must come *after* the notifying tasks.
- **A typo in the sshd drop-in name let cloud-init override it.** Cloud-init writes `50-cloud-init.conf`, which sorts after `00-hardening.conf`. Naming the hardening drop-in `00-hardening.conf` ensures it loads last and wins. The `sshd -t -f %s` validate step caught a syntax error before it reached the host.
- **Idempotency broke when I used `command` instead of a module.** `command` always reports `changed` because it cannot detect whether the command actually did anything. Switching to `ansible.builtin.template` and `ansible.builtin.copy` restored idempotency.

## How this connects to what's next

The next step is wrapping this playbook in a reusable script that runs syntax-check, check-diff, and the actual run in sequence, and parses the result so a CI job can fail the build when the playbook reports unexpected changes. That is the `ansible-009` wrapper script task.