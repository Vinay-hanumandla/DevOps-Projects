# last_verified: 2026-07-22 · Python n/a

# create_venv_and_run.py — end-to-end venv setup, no install needed
# This script creates a .venv, runs a second script inside it, and prints the result.
# Kept minimal for L1: no error handling yet, no argparse.

import os
import subprocess
import sys

venv_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".venv")

if not os.path.exists(venv_dir):
    subprocess.run([sys.executable, "-m", "venv", venv_dir], check=True)
    print(f"Created: {venv_dir}")
else:
    print(f"Exists:  {venv_dir}")

venv_python = os.path.join(venv_dir, "bin", "python")
runner = "import sys; print('Python version:', sys.version)"

result = subprocess.run([venv_python, "-c", runner], capture_output=True, text=True)
print(result.stdout.strip())

if result.returncode == 0:
    print("Success — the venv Python runs correctly.")
else:
    print("Something went wrong.", result.stderr)
