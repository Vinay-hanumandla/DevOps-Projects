# last_verified: 2026-08-14 · git n/a
# Driver targets for the Git release workflow scaffold. Each command is thin —
# the real logic lives in scripts/, so the same steps run from a terminal or CI.
.PHONY: patch minor major changelog verify lint

STEP ?= patch

patch:
	./scripts/release.sh patch

minor:
	./scripts/release.sh minor

major:
	./scripts/release.sh major

release: $(STEP)

changelog:
	./scripts/changelog.sh

verify:
	./scripts/verify-release.sh

lint:
	shellcheck scripts/*.sh lib/*.sh