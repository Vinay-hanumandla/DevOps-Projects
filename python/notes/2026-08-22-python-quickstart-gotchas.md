---
last_verified: 2026-08-22
tool_version: n/a
---

# Python quickstart — what tripped me up

Following the official Python tutorial/quickstart and noting the spots where I got stuck or had to deviate from the docs.

## Setting up the environment

The quickstart assumes you already have Python installed. On a fresh Ubuntu box, `python3` is there but `python` (the unversioned command) is often missing. If you're used to typing `python` from other tutorials, you'll get `command not found` until you install the `python-is-python3` package or just use `python3` explicitly.

For virtual environments, the quickstart points you at `venv`:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

This part worked fine. What tripped me up was forgetting to activate the env before `pip install` — suddenly packages were going into the system site-packages and I couldn't figure out why `import requests` worked in one terminal but not another.

## Interactive mode vs. script mode

The quickstart jumps between the interactive REPL and writing `.py` files. I kept trying to run multi-line constructs in the REPL and getting confused by indentation errors. The REPL is fine for one-liners and quick experiments, but anything with an `if` or `for` body is better in a script file where you get proper indentation handling.

## Indentation — the thing everyone warns you about

Yes, it really is that strict. I hit `IndentationError` about four times in the first hour because I mixed tabs and spaces in the same file. The fix is simple — configure your editor to use spaces (4 is the convention) and never think about it again. The quickstart mentions this but doesn't emphasize how often it bites in practice.

## `pip install` inside vs. outside venv

The quickstart mentions `pip install requests` as a first step. If you're not in a venv, this installs globally and you'll eventually break something system-level. The pattern I settled on:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install requests
python -c "import sys; print(sys.version)"
```

The `-m venv` approach is more reliable than `virtualenv` for getting started — fewer moving parts.

## f-strings vs. format()

The quickstart uses `str.format()` in some examples and f-strings in others. For a beginner this is confusing — which one should I use? f-strings are more readable and generally faster, so I just use those. The docs don't always make it clear that f-strings are the modern default.

## What I'd try next

I want to dig into the `argparse` module for building CLI tools — that feels like the natural next step after getting comfortable with basics. Also want to understand how `asyncio` works since a lot of DevOps tooling is moving toward async patterns.
