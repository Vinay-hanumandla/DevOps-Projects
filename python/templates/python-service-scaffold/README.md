---
last_verified: 2026-10-03
tool_version: n/a
---

# FastAPI service scaffold

A starting point for an HTTP service that owns a relational schema: FastAPI for the
request layer, SQLAlchemy for the ORM, Alembic for schema changes, pytest for tests,
and Ruff plus mypy as the gates that run before every commit.

## Purpose

This scaffold exists so a new service boots with the parts that are tedious to
re-derive each time: a `src/` layout that keeps imports unambiguous, one typed
settings object, a single place where the engine and session factory are built, a
request-scoped session dependency, migrations wired to the ORM metadata, and a test
suite that runs against an in-memory database with nothing else running.

Everything here is small enough to read in one sitting, and each file does one job.
The files most likely to be edited first are `src/app/models.py` and `src/app/main.py`;
**Steps** covers getting the scaffold running before any of that happens.

## When to use

Use it when the service needs to own tables: an internal API, a webhook receiver, or
a worker with an HTTP surface. Treat it as a starting point, not a finished service —
there is no authentication, rate limiting, background scheduler, or tracing.

Skip it when the service is a thin read path over an existing API, when the data
lives in a document store, or when the deployment target already supplies its own
application framework.

## Design decisions to know before editing

- **A synchronous SQLAlchemy session.** Routes that touch the database are declared
  with `def`, so Starlette runs them in its worker threadpool and the session stays
  ordinary blocking code. Tests then drive the app with the plain `TestClient` and
  need no async plugin. Moving to `AsyncSession` later is a contained change:
  `src/app/db.py` plus `async def` on the database-backed routes.
- **One override point for tests.** `tests/conftest.py` swaps `get_session` for a
  session bound to an in-memory SQLite database, so no test can reach the URL in
  `.env` by accident.
- **Migrations read their URL from the application settings.** `alembic/env.py`
  imports `app.config` rather than duplicating the connection string, so the app and
  its migrations cannot drift onto different databases.
- **Health checks are split.** `/healthz` answers without touching the database, so
  an orchestrator can distinguish "process is up" from "process can serve traffic".
  `/healthz/ready` runs a probe query and answers the second question.
- **The application never calls `create_all()`.** Only the test fixtures do. Schema
  changes go through Alembic so that every environment ends up on the same revision.

## Layout

```
python-service-scaffold/
├── pyproject.toml            # metadata, dependencies, Ruff/mypy/pytest config
├── .env.example              # every setting with its default, no secrets
├── .gitignore
├── alembic.ini               # migration environment and logging config
├── alembic/
│   ├── env.py                # online/offline migrations, metadata import
│   └── script.py.mako        # template used by `alembic revision`
├── src/app/
│   ├── __init__.py
│   ├── config.py             # typed settings, cached per process
│   ├── db.py                 # Base, engine, session factory, FastAPI dependency
│   ├── models.py             # ORM models
│   ├── schemas.py            # request and response models
│   └── main.py               # app, lifespan, routes
└── tests/
    ├── conftest.py           # in-memory database and client fixtures
    ├── test_health.py
    └── test_items.py
```

The `alembic/versions/` directory is created by the first `alembic revision`; it is
not committed empty.

## Prerequisites

- A Python interpreter matching the floor the deployment image pins. Declare it in
  `pyproject.toml` with `requires-python` and in `[tool.ruff] target-version`.
- A writable working directory, because the default settings use a SQLite file.
- A PostgreSQL server only if the service is pointed at one. The test suite needs
  nothing beyond the virtual environment.

## Steps

1. **Create the environment and install the project in editable mode.**

   ```bash
   python -m venv .venv
   . .venv/bin/activate
   pip install -e ".[dev]"
   ```

2. **Copy the settings and edit them.**

   ```bash
   cp .env.example .env
   ```

   The defaults run against a local SQLite file. Set `DATABASE_URL` to a
   `postgresql+psycopg://` URL to use a server instead. On platforms where the
   compiled driver extension is unavailable, install `psycopg` with its `binary`
   extra; otherwise the import fails with a driver error at engine creation.

3. **Create the first migration and apply it.**

   ```bash
   alembic revision --autogenerate -m "initial schema"
   alembic upgrade head
   ```

   Read the generated file before committing it. Autogenerate is a starting point,
   not an authority: it cannot see column renames, some server-side defaults, or any
   data movement, so hand-edit the result for anything beyond a new table.

4. **Run the service.**

   ```bash
   uvicorn app.main:app --reload
   ```

   `--reload` is a local-development flag; a deployment runs the ASGI server
   directly. Then check both probes:

   ```bash
   curl -s localhost:8000/healthz
   curl -s localhost:8000/healthz/ready
   ```

5. **Run the gates.** All four pass before a commit.

   ```bash
   ruff check .
   ruff format --check .
   mypy src
   pytest
   ```

   `ruff check --fix .` repairs import ordering and most other mechanical findings in
   place.

## Verify

A working checkout answers all of these:

| Check | Expected |
|---|---|
| `alembic current` | prints the revision created in step 3 |
| `curl -s localhost:8000/healthz` | `{"app":"python-service-scaffold","environment":"local","status":"ok"}` |
| `curl -s localhost:8000/healthz/ready` | `{"database":"ok"}` |
| `curl -s -X POST localhost:8000/items -H 'content-type: application/json' -d '{"name":"first"}'` | status `201` and a body with a server-assigned `id` and `created_at` |
| `curl -s localhost:8000/items` | the created item, oldest first |
| `pytest` | all tests pass with no database server running |
| `mypy src` | no output |

## Common errors

| Symptom | Cause | Fix |
|---|---|---|
| `ModuleNotFoundError: No module named 'app'` | The project was never installed, and the interpreter is not reading pytest's `pythonpath = ["src"]` setting | `pip install -e ".[dev]"` |
| `ImportError: cannot import name 'config' from 'src.app'` | Mixed import styles — `from app.config import ...` in the app and `from src.app.config import ...` in a script | Use the `app.` prefix everywhere; `alembic.ini` sets `prepend_sys_path = src` so migrations resolve it the same way |
| `sqlalchemy.exc.OperationalError: ... no such table: items` | The service was started before `alembic upgrade head` ran against that database | Run the migrations; the app deliberately does not create tables at startup |
| `Can't locate revision identified by '...'` from Alembic | A revision file was deleted or a database was restored from elsewhere, leaving the version table pointing at a revision that is no longer in `alembic/versions/` | Restore the missing file and re-run `alembic upgrade head`, or `alembic stamp head` when the schema is already correct |
| `No 'script_location' key found in configuration.` from Alembic | `alembic.ini` was not copied into the project root, or its `[alembic]` section was edited away | Restore `script_location` and `prepend_sys_path` |
| `SQLite objects created in a thread can only be used in that same thread` | An in-memory database was opened without `check_same_thread=False` and a `StaticPool`, so the app's worker thread cannot see the connection the test created | Use the fixtures in `tests/conftest.py`, which already do both |
| `Function is missing a return type annotation` from mypy | A function was added without annotations while `strict = true` | Annotate it, or relax `strict` in `pyproject.toml` deliberately |
| `I001 Import block is un-sorted or un-formatted` from Ruff | Imports were added by hand | `ruff check --fix .` |
| A password containing `%` breaks migrations | The connection string is stored in a configparser value, where `%` starts an interpolation | Already handled in `alembic/env.py`, which escapes it before writing the URL |

## Customizing

- **Rename the project.** Change `name` in `pyproject.toml`. The distribution name
  and the import package are independent, so `app` can stay `app` or become
  `myservice` — if it changes, update the imports, `alembic.ini`, and the pytest
  `pythonpath` entry together.
- **Add a model.** Declare it in `src/app/models.py` on `Base`, add a request and a
  response model in `src/app/schemas.py`, then generate a migration for it.
- **Change the database.** `DATABASE_URL` is the only place the connection string is
  read, for the application and for the migrations.
- **Turn on statement logging.** Set `SQL_ECHO=true`; the engine echoes every
  statement it emits.
- **Add authentication, metrics, or a worker.** Nothing in the scaffold assumes they
  are absent, and nothing is wired so that they must arrive in a particular order.