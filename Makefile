D_C=docker compose
D_C_FILE = ./docker-compose.yml

all: up

up:
	mkdir -p ~/data/html
	mkdir -p ~/data/mariadb
	$(D_C) -f $(D_C_FILE) up
build:
	$(D_C) -f $(D_C_FILE) build --no-cache
down:
	$(D_C) -f $(D_C_FILE) down
clean:
	sudo rm -rf ~/data/html
	docker rmi wordpress mariadb nginx
	docker volume prune -f
	docker network prune -f
.PHONY: up build down clean