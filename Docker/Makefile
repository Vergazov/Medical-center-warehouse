.PHONY: up down down-clear bash-master bash-slave

up:
	docker compose up -d --build

down:
	docker compose down

down-clear:
	docker compose down -v

bash-master:
	docker compose exec -u root master bash

bash-slave:
	docker compose exec -u root slave bash
