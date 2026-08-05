---
last_verified: 2026-08-04
tool_version: n/a
sources: []
---

# Python functions and modules — what tripped me up

> Following the official Python tutorial on functions and modules, here's what I found confusing and what finally clicked.

## What I tried

I worked through the Python tutorial's sections on defining functions, default arguments, `*args`/`**kwargs`, and then moved into modules and imports. I ran each example in a fresh REPL session and tried variations to see what would break.

## What worked

Defining a function with `def` was straightforward — I already knew this from the primer. The part that actually clicked was how `return` hands a value back to the caller, and how you can chain function calls:

```python
def get_port(service):
    return {"nginx": 80, "postgres": 5432}.get(service, 443)

port = get_port("nginx")
print(port)  # 80
```

Default arguments were intuitive too. I used them to set sensible fallbacks in a config-lookup function.

## What tripped me up

**Mutable default arguments.** The tutorial warns about this, but it still caught me off guard. When I wrote `def add_item(item, lst=[])`, the list persisted across calls. Every call appended to the same list, which is not what I expected. The fix is `None` as the default and creating the list inside the function body.

**Import order and circular imports.** When I tried importing a function from a module that itself imported from my script, I got an `ImportError`. The tutorial doesn't cover this well — it turns out Python executes modules top-to-bottom, so if module A imports module B and B imports A, one of them gets a half-initialized namespace.

**`from module import *`** — I used this in a quick experiment and then couldn't trace where a function was coming from. The tutorial says to avoid it, and I see why: it pollutes the namespace and makes debugging a nightmare.

## Key takeaways

- Default arguments should be immutable (`None`, not `[]` or `{}`).
- Imports are executed at module load time, not at call time — order matters.
- Explicit imports (`from module import name`) are always clearer than wildcard imports.

## What I'll do next

I want to write a small file-processing script that uses functions to organize the logic — read a file, parse its lines, and write results. Then I'll experiment with packaging a couple of modules together and using `__init__.py` to control what gets exported.