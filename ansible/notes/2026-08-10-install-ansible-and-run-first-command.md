---
last_verified: 2026-08-10
tool_version: n/a
sources:
  - https://www.ansiblebyexample.com/articles/how-to-install-ansible-all-platforms
  - https://kloudvin.com/article/ansible-installation-setup-ansible-cfg-first-connection/
---

# Installing Ansible and running my first command

I tried `pip install ansible` and hit `error: externally-managed-environment` — Ubuntu 24.04 blocks system-wide pip installs (PEP 668). The docs point to using `pipx` or a virtualenv instead.

I ran:

```bash
pipx install ansible
pipx ensurepath
```

The `ensurepath` step matters — without it, `ansible` isn't on my PATH and I get "command not found." Open a new shell after running it.

`pipx` gives me the full `ansible` package (engine + community collections), which the install guide says is what most beginners want — `ansible-core` alone trips you up later with missing collections.

## My first command

With the control node ready, the canonical first command is an ad-hoc `ping`:

```bash
ansible all -i localhost, -m ping
```

The `-i localhost,` tells Ansible to target just this machine (trailing comma = literal inline inventory). The `-m ping` calls the `ping` module, which SSHes in and runs a tiny Python snippet to confirm connectivity + Python availability.

## What tripped me up

- `-i localhost,` — forget the comma and Ansible reads `localhost` as a file, complaining "No inventory was parsed."
- If the managed node lacks Python, `ping` fails with `/usr/bin/python: not found`. Fix: set `ansible_python_interpreter=/usr/bin/python3` in inventory or `ansible.cfg`.
- On first SSH connection, Ansible refuses unknown hosts. For a lab, `host_key_checking = False` in `ansible.cfg` skips the prompt.