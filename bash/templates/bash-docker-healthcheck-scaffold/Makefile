# last_verified: 2026-08-17 · bash 5.3
# Convenience wrappers around the orchestration scripts. docker compose is the
# only host dependency; the Bash helpers and the demo app run in the container.
.PHONY: up down ps logs health lint

up:
	./scripts/up.sh

down:
	./scripts/down.sh

ps:
	docker compose ps

logs:
	docker compose logs -f

health:
	@for c in $$(docker compose ps -q); do \
		echo "$$c: $$(docker inspect --format '{{.State.Health.Status}}' $$c)"; \
	done

lint:
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck scripts/*.sh lib/*.sh app/*.sh docker-entrypoint.sh; \
	else \
		echo "shellcheck not installed on host; run: docker run --rm -v \"$$(pwd):/work\" -w /work koalaman/shellcheck:stable scripts lib app"; \
	fi
