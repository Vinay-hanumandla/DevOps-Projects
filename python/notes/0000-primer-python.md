---
last_verified: 2026-07-22
tool_version: n/a
sources: []
---

# Python — quick primer

> First-day notes for someone who's never used Python. Personal voice, plain language.

## What is it?

Python is a programming language that reads like plain English. Created by Guido van Rossum and released in 1991, it was designed to be easy to read and quick to write. That design decision is what made it popular — and it is still the reason beginners pick it up first.

As a DevOps practitioner, Python sits in the same space as your shell scripts, but with a richer standard library and cleaner syntax. Where a Bash one-liner can parse a log file, a Python script can parse that same file, call a REST API, store results in a database, and email a report — all in one file. Bash is great for quick orchestrations; Python is where you go when the logic starts to compound.

## What does it do?

Python is a general-purpose language, which means it does not have a single narrow job. In practice it is used to:

- Automate repetitive tasks — bulk file renaming, log parsing, cloud resource cleanup.
- Glue systems together — call AWS APIs, query a database, talk to a Kubernetes cluster.
- Process data — parse YAML/JSON/CSV, transform it, and write it back out.
- Spin up prototypes — validate an idea before rewriting it in a compiled language.

Everything in Python is an object — numbers, strings, lists, dictionaries, even functions. That consistency makes the learning curve gentler than most languages.

## Why does it exist?

Before scripting languages matured, serious automation required Perl, awk, or compiled binaries. Perl was powerful but cryptic; C was fast but overkill for sysadmin tasks. Python was created to fill the middle ground: fast enough to write, readable enough to maintain.

For DevOps work specifically, Python replaced a patchwork of Bash, Perl, and ad-hoc scripts. Now the same language writes a deployment script, a monitoring check, and an infrastructure-as-code helper. The Ansible CLI, the AWS CLI, and the Kubernetes Python client all expose Python bindings because the ecosystem standardized around it.

## Key terminology

- **Variable** — A named reference to a value. `count = 5` gives the name `count` to the number 5. Python is dynamically typed; you do not declare the type beforehand.

- **Type** — The category of a value: `int`, `float`, `str`, `bool`, `list`, `dict`, and so on. `type(count)` returns `<class 'int'>`. Knowing the type helps avoid surprises like `5 / 2` giving `2.5` instead of `2`.

- **Function** — A reusable block of logic with inputs and an output. `def greet(name): return f"Hello, {name}"`. Functions keep scripts modular and testable.

- **List** — An ordered, mutable collection. `services = ["nginx", "postgres", "redis"]`. You add with `.append()` and iterate directly with `for s in services:`.

- **Dictionary** — A key-value map. `config = {"env": "prod", "region": "eu-west-1"}`. The most common way to pass structured data between scripts.

- **Virtual environment (venv)** — An isolated Python directory containing its own copies of Python and installed packages. `python -m venv .venv` creates one; nothing leaks in or out. Prevents version conflicts between projects.

- **pip** — The package installer for Python. `pip install requests` fetches and installs a library. Combined with `venv`, it makes project dependencies reproducible.

- **Module** — A `.py` file containing functions, classes, or constants. `import os` loads the built-in `os` module for filesystem and environment access.

- **f-string** — A string with `{}` placeholders evaluated at runtime. `f"Found {n} errors"` is faster and more readable than the older `.format()` style.

- **Shebang line** — The `#!/usr/bin/env python3` line at the top of an executable script. Tells the OS which interpreter to use.

## A tiny example

```python
#!/usr/bin/env python3
# list_services.py — print each service name from a list
services = ["nginx", "postgres", "redis"]

for svc in services:
    print(f"  * {svc}")
```

Save it as `list_services.py`, make it executable (`chmod +x list_services.py`), and run it (`python3 list_services.py`). It prints each service on its own line — the smallest loop in Python.

## What I'll cover next

From here I want to write a real script that uses variables, loops, and a function to do something useful — like reading a config file or calling an API. After that I want to set up a `venv`, install a package with `pip`, and understand why isolation matters when I have five different projects on the same machine.
