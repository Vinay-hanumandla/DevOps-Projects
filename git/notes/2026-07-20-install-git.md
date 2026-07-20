---
last_verified: 2026-07-20
tool_version: n/a
sources: []
---

# Installing Git and setting up my identity

> L1 scratch notes — installing Git and configuring name/email for the first time.

## What I did

I opened a terminal and ran `git --version` first. It wasn't installed, so I used my system package manager:

```bash
sudo apt update
sudo apt install git
```

That installed Git. I confirmed with `git --version` and saw a version number printed.

## Configuring my identity

Git needs to know who I am so every commit has an author attached. I set two global config values:

```bash
git config --global user.name "My Name"
git config --global user.email "my.email@example.com"
```

The `--global` flag writes these to `~/.gitconfig` so they apply to every repository on this machine. Without these, Git complains when I try to commit.

## Verifying it worked

I ran `git config --global --list` and saw both `user.name` and `user.email` listed. That confirmed the settings are in place.

## What tripped me up

I almost forgot to add the `--global` flag. Without it, Git only sets the value for the current repository. Since I hadn't created a repo yet, the command would have silently succeeded but the setting wouldn't stick.
