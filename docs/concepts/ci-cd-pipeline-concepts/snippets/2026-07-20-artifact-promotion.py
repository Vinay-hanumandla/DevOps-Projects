# last_verified: 2026-07-20 · python 3.12

# Practicing artifact promotion logic for CI/CD.
# An artifact moves from dev → staging → prod only if it passes gates at each step.

def promote_artifact(version, current_env, test_results):
    envs = ["dev", "staging", "prod"]

    if current_env not in envs:
        print(f"[{version}] Unknown env: {current_env}")
        return None

    idx = envs.index(current_env)
    if idx >= len(envs) - 1:
        print(f"[{version}] Already at highest env ({current_env})")
        return None

    # Gate: at least one test must have passed
    if test_results.get("passed", 0) < 1:
        print(f"[{version}] Blocked — no passing tests")
        return None

    next_env = envs[idx + 1]
    rate = test_results["passed"] / test_results["total"] * 100
    print(f"[{version}] {current_env} → {next_env} ({rate:.0f}% pass rate)")
    return next_env


if __name__ == "__main__":
    promote_artifact("v2.1.0-build.12", "dev", {"passed": 15, "total": 15})
    promote_artifact("v2.1.0-build.12", "staging", {"passed": 8, "total": 8})
