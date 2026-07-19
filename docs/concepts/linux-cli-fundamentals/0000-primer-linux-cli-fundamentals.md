---
last_verified: 2026-07-19
tool_version: n/a
---

# Linux & CLI Fundamentals — quick primer

> First-day notes on Linux and the command line. What it is, why it matters, and the key ideas to know.

## What is it?

Linux is an open-source operating system kernel that powers most of the internet — servers, containers, cloud VMs, and even Android phones. The command-line interface (CLI) is how you talk to a Linux machine without a graphical desktop: you type text commands, and the system responds with text output.

Think of the CLI as a text-based control panel for the computer. Instead of clicking buttons, you type instructions like `ls` (list files), `cd` (change directory), or `cat` (show a file's contents). Once you get past the initial intimidation, it's actually faster and more scriptable than a GUI — especially when you're managing dozens of servers instead of one.

## Why does it matter for DevOps?

Almost every DevOps tool runs on Linux. Docker containers use Linux kernel features. Kubernetes nodes run Linux. CI/CD pipeline runners are Linux VMs. Cloud services (AWS, GCP, Azure) are built on Linux. If you work in DevOps, you will spend your career in a terminal — reading logs, editing configs, checking process status, and debugging why something isn't working.

You don't need to be a sysadmin who can compile a kernel. But you do need to be comfortable navigating the filesystem, finding files, inspecting processes, reading log output, and writing simple shell commands. Every deeper skill (Docker, Kubernetes, Terraform, CI/CD) assumes you have this foundation.

## Key terminology

- **Kernel** — The core of Linux that manages hardware, processes, and memory. The distro (Ubuntu, Debian, Alpine, etc.) packages the kernel with tools and a package manager.
- **Shell** — The program that reads your commands and runs them. Bash is the default on most distros. Zsh, Fish, and Dash are alternatives.
- **Filesystem hierarchy** — Linux arranges everything under `/` (root). Key directories: `/home` (user files), `/etc` (config files), `/var` (logs and dynamic data), `/tmp` (temporary files), `/proc` (running process info).
- **Permissions** — Every file has an owner, a group, and three permission triples (owner/group/others) for read/write/execute. `ls -l` shows them; `chmod` changes them.
- **Process** — A running program. `ps` shows processes; `top` or `htop` shows live resource usage. Each process has a PID (process ID).
- **Package manager** — The tool that installs, updates, and removes software. `apt` (Debian/Ubuntu), `yum`/`dnf` (RHEL/Fedora), `apk` (Alpine).
- **Standard streams** — Every command has stdin (input), stdout (output), and stderr (errors). You can redirect them: `>` writes stdout to a file, `2>` writes stderr, `|` pipes stdout to the next command.
- **Exit code** — Every command returns a number (0 = success, non-zero = failure). Scripts check `$?` to decide what to do next.

## A concrete example

```bash
# List all files in /var/log, filter for lines containing "error",
# and save the result to a file
ls /var/log | grep -i error > errors-i-found.txt
echo "Found $(wc -l < errors-i-found.txt) error lines"
```

This demonstrates three core ideas: listing files (`ls`), filtering text (`grep`), piping output between commands (`|`), saving output to a file (`>`), and running a command inside another (`$(...)`). No GUI needed — just text in, text out.

## How this connects to what's next

Once you're comfortable navigating the CLI and understanding files, processes, and permissions, you're ready to work with Git (version control), run Docker containers, write shell scripts, and configure servers. Every tool in the DevOps stack expects you to be at home in a terminal.
