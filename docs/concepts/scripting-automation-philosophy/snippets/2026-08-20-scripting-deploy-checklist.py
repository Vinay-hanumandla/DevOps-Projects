# last_verified: 2026-08-20 · scripting-automation-philosophy n/a
# Applying scripting in DevOps — my take on a deploy checklist.
# The habit I'm practicing here: encode a known sequence of steps (health
# check, config sanity check, worker count) as data, then loop over it. When a
# step needs to change I edit one list entry instead of a wall of copy-pasted
# if blocks — that is the DRY idea from the primer applied to operations.

import subprocess

STEPS = [
    ("api responds on health endpoint", ["curl", "-fsS", "http://localhost:8080/health"]),
    ("config file parses", ["python3", "-c",
                            "import sys; __import__('yaml').safe_load(open('app.yaml'))"]),
    ("worker processes running", ["pgrep", "-c", "demo-worker"]),
]


def run_step(label, argv):
    print(f"[{label}] ", end="")
    try:
        subprocess.run(argv, check=True, capture_output=True)
        print("ok")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError) as err:
        print(f"failed ({err})")
        return False


passed = 0
for label, argv in STEPS:
    passed += 1 if run_step(label, argv) else 0

print(f"{passed}/{len(STEPS)} checks green")
if passed != len(STEPS):
    print("DO NOT PROCEED — one or more checks failed")