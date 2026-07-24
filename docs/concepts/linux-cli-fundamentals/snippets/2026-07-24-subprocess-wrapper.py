# last_verified: 2026-07-24 · Linux & CLI Fundamentals L2

"""
Applying Linux & CLI fundamentals — subprocess wrapper

I wanted a small Python snippet that wraps common Linux CLI commands
and handles their output gracefully. This is what I use when I need
to run ls, ps, or df from a script and do something with the result.
"""

import subprocess
import shlex
import sys


def run_cmd(command: str, timeout: int = 10) -> dict:
    """
    Run a shell command and return the result as a dict.

    I kept this simple — just captures stdout, stderr, and the return code.
    No shell injection protection here since this is for my own lab use.
    """
    parts = shlex.split(command)
    try:
        result = subprocess.run(
            parts,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        return {
            "command": command,
            "stdout": result.stdout.rstrip("\n"),
            "stderr": result.stderr.rstrip("\n"),
            "returncode": result.returncode,
            "success": result.returncode == 0,
        }
    except FileNotFoundError as e:
        return {
            "command": command,
            "stdout": "",
            "stderr": f"Command not found: {e}",
            "returncode": -1,
            "success": False,
        }
    except subprocess.TimeoutExpired:
        return {
            "command": command,
            "stdout": "",
            "stderr": f"Timed out after {timeout}s",
            "returncode": -1,
            "success": False,
        }


def main():
    print("=== Subprocess wrapper demo ===")

    # List files in current directory
    result = run_cmd("ls -la")
    print(f"\n--- ls -la (exit: {result['returncode']}) ---")
    print(result["stdout"])

    # Show mounted filesystems
    result = run_cmd("df -h /")
    print(f"\n--- df -h / (exit: {result['returncode']}) ---")
    print(result["stdout"])

    # Try a command that doesn't exist — I always trip over this
    result = run_cmd("nonexistent_cmd_xyz")
    print(f"\n--- nonexistent command (exit: {result['returncode']}) ---")
    print(f"stderr: {result['stderr']}")


if __name__ == "__main__":
    main()
