# last_verified: 2026-08-13 · bash
# Delegates lint/format/test to the dev-toolchain container so nothing
# bash-related has to be installed on the host.
IMAGE_TAG := $(shell ./scripts/app-env --tag)

.PHONY: lint format test shell build

build:
	docker build -t $(IMAGE_TAG) .

lint:
	docker run --rm -v "$$(pwd):/work" -w /work $(IMAGE_TAG) shellcheck bin/* lib/*.sh tests/*.bats

format:
	docker run --rm -v "$$(pwd):/work" -w /work $(IMAGE_TAG) shfmt -i 2 -d bin/* lib/*.sh

test:
	docker run --rm -v "$$(pwd):/work" -w /work $(IMAGE_TAG) bats tests

shell:
	docker run --rm -it -v "$$(pwd):/work" -w /work $(IMAGE_TAG) bash