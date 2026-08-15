# last_verified: 2026-08-15 · bash
.PHONY: build up down test status shell

COMPOSE_FILE := docker-compose.yaml

build:
	docker compose -f $(COMPOSE_FILE) build --no-cache

up: startup-wait.sh
	./startup-wait.sh

down:
	docker compose -f $(COMPOSE_FILE) down -v

test:
	@curl -fsS http://localhost:5000/ | python -m json.tool

status:
	docker compose -f $(COMPOSE_FILE) ps

shell:
	docker compose -f $(COMPOSE_FILE) run --rm web bash
