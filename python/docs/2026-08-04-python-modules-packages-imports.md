---
last_verified: 2026-08-04
tool_version: n/a
sources: []
---

# Python modules, packages, and import mechanics — what I learned

> A walkthrough of how Python modules and packages work, and how import resolution actually behaves.

## What a module is

A module is simply a `.py` file. When you write `import mymodule`, Python searches `sys.path` for a file named `mymodule.py` and executes it once, caching the result in `sys.modules`. Every subsequent `import mymodule` reuses the cached module object — it does not re-execute the file.

This caching is the source of most confusion I had. If I edit a module while a REPL session is still open, `import mymodule` does not pick up the changes. I have to reload it explicitly with `importlib.reload(mymodule)`.

## What a package is

A package is a directory that contains an `__init__.py` file (which can be empty). The `__init__.py` marks the directory as a Python package and runs when the package is first imported. It can also control what gets exported via `__all__`.

```
myproject/
    __init__.py
    utils.py
    config.py
```

With this layout, `import myproject.utils` works, and `from myproject import utils` also works because `__init__.py` makes the directory importable.

## How import resolution works

Python resolves imports in this order:

1. **Built-in modules** — things like `os`, `sys`, `json`.
2. **`sys.path` entries** — the current directory, then the standard library paths, then any site-packages directories.
3. **Namespace packages** (Python 3.3+) — directories without `__init__.py` can also be imported, but they don't run initialization code.

The `sys.path` list is built from the script's directory (or the current working directory if running interactively), then `PYTHONPATH`, then the installation-dependent defaults.

## What tripped me up

**Relative imports inside a script.** When I tried `from . import utils` inside a script run directly with `python script.py`, I got `ImportError: attempted relative import with no known parent package`. Relative imports only work inside a package — they rely on `__name__` being set to the package path, not `"__main__"`.

**`__init__.py` side effects.** I put code in `__init__.py` that imported submodules, and then submodules imported back from the package. This created a circular dependency that only surfaced at runtime, not at import time. The fix was to move shared constants to a separate module that neither `__init__.py` nor the submodules depend on.

## Key terms

- **Module** — A single `.py` file that defines a namespace. `import mymodule` loads it.
- **Package** — A directory with `__init__.py` that groups related modules.
- **`sys.path`** — The list of directories Python searches when resolving an import.
- **`sys.modules`** — The cache of already-loaded modules. Editing a file on disk does not invalidate this cache.
- **`__init__.py`** — Runs when a package is first imported; can control exports via `__all__`.
- **Relative import** — `from . import sibling` — only works inside a package, not in a standalone script.
- **`__all__`** — A list in a module or `__init__.py` that controls what `from module import *` exports.

## How this connects to what's next

Understanding import mechanics is essential before writing a multi-file project. The next step is to organize a small tool into a package with `__init__.py`, use explicit imports, and avoid circular dependencies. This also sets up the pattern for distributing the tool as an installable package later.