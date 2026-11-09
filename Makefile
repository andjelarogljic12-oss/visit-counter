build:
	docker build -t visit-counter .

up:
	docker compose up -d

test:
	pytest

down:
	docker compose down
