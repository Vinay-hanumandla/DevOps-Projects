---
last_verified: 2026-09-18
tool_version: "14.4.0"
sources:
  - https://akshayghalme.com/blogs/ansible-playbook-patterns-production/
---

# command/shell vs purpose-built idempotent modules

## Purpose

Every Ansible task either describes a desired state or runs a raw command. Purpose-built modules do the former: they check the current state first and report `changed` only when they actually change something. The `command` and `shell` modules do the latter: they run whatever string they are given and report `changed` on every run, because they have no way to know whether the command did anything. Idempotency is the main production property to protect here — a task that reports `changed` on every rerun is a bug, and the fix is usually to stop shelling out. This doc compares the two approaches and shows how to contain `command`/`shell` when it cannot be avoided.

## Steps

1. **Spot the shell-out.** Any task using `command` or `shell` to manage a resource that has a dedicated module — files, packages, services, archives, downloads — is a candidate for replacement. The dedicated module is state-aware; the shell string is not.

2. **Replace with the purpose-built module.** Rewrite the task so the module declares the desired end state instead of the shell steps to get there. The rerun behavior is the test: run the playbook twice and the second run should report `ok` instead of `changed` for that task.

3. **Guard the shell-outs that must stay.** Sometimes there is genuinely no module for the job (a vendor CLI, a one-off migration binary). In that case add one of the guards: `creates` (skip the task if a marker file already exists), `removes` (run only while a stale file still exists), or `changed_when` (decide changed/ok from the command output instead of defaulting to `changed`).

   ```yaml
   # Before: reports changed on every run
   - name: Unpack release tarball
     ansible.builtin.shell: tar -xzf /opt/app/release.tgz -C /opt/app

   # After: skips cleanly once the marker exists
   - name: Unpack release tarball
     ansible.builtin.shell: tar -xzf /opt/app/release.tgz -C /opt/app && touch /opt/app/.unpacked
     args:
       creates: /opt/app/.unpacked
   ```

   Another common guard is matching on output:

   ```yaml
   - name: Run database migration
     ansible.builtin.command: /opt/app/bin/migrate --apply
     register: migrate_out
     changed_when: "'already up to date' not in migrate_out.stdout"
   ```

4. **Preview before applying.** Run `ansible-playbook --check --diff` before the real run. It shows what would change without touching the hosts, which is the fastest way to catch a task that would report `changed` forever.

## Verify

- Run the playbook twice in a row. The second run should show `changed=0` (everything `ok`).
- Run with `--check --diff` and confirm the planned changes match what the modules claim to manage — no shell task should appear as changed when its work is already done.
- Search the playbook for bare `command`/`shell` tasks with no `creates`, `removes`, or `changed_when`. Each one is either replaceable with a module or needs a guard; the docs also suggest `serial` with a failure threshold and health checks for rolling out the change safely, but that is a rollout concern on top of this one.
