# last_verified: 2026-09-17 · docker n/a
# Placeholder one-shot migration runner for the "tools" profile.
# Reads the DB_* env the same way server.py does; replace the body with
# real schema calls when the project grows one.
import os

print("migrate: host=%s db=%s user=%s" % (
    os.environ.get("DB_HOST", "db"),
    os.environ.get("DB_NAME", "appdb"),
    os.environ.get("DB_USER", "app"),
))
print("migrate: nothing to apply yet (placeholder) — exit 0")
