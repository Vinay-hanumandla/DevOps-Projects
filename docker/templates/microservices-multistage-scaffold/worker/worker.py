# last_verified: 2026-09-30 · docker n/a
# Tiny queue worker: reads the shared secret file (when mounted) and
# prints one heartbeat line per poll interval. Stdlib only.
import os
import time


def read_secret(path):
    try:
        with open(path) as f:
            return f.read().strip()
    except OSError:
        return ""


API_KEY_FILE = os.environ.get("API_KEY_FILE", "/run/secrets/api_key")
INTERVAL = int(os.environ.get("POLL_INTERVAL", "30"))

if __name__ == "__main__":
    key = read_secret(API_KEY_FILE)
    print("worker start: api_key %s" % ("present" if key else "missing"), flush=True)
    while True:
        print("worker heartbeat", flush=True)
        time.sleep(INTERVAL)
