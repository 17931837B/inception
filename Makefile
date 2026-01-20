# Inception Project Makefile

# Variables
SOURCE_DIR = ./srcs
COMPOSE_FILE = ${SOURCE_DIR}/docker-compose.yml
DATA_DIR = "$${HOME}/data"
MARIADB_DATA = $(DATA_DIR)/mariadb
WORDPRESS_DATA = $(DATA_DIR)/wordpress

.PHONY: up down build clean test logs status help restart

# Default target
help:
	@echo "🚀 Inception Project Commands:"
	@echo "  make up       - Start all containers"
	@echo "  make down     - Stop all containers"
	@echo "  make build    - Build all containers"
	@echo "  make clean    - Stop and remove all containers, volumes, and images"
	@echo "  make test     - Run integration test"
	@echo "  make logs     - Show container logs"
	@echo "  make status   - Show container status"

# Start all containers
up:
	@mkdir -p $(MARIADB_DATA) $(WORDPRESS_DATA)
	docker compose -f $(COMPOSE_FILE) up -d
	@echo Preview Link: https://tobaba.42.fr
	@echo Preview Admin Panel: https://tobaba.42.fr/wp-admin
	@echo Preview Database Panel: https://tobaba.42.fr/adminer

buildup:
	@mkdir -p $(MARIADB_DATA) $(WORDPRESS_DATA)
	docker compose -f $(COMPOSE_FILE) up -d --build
	@echo Preview Link: https://tobaba.42.fr
	@echo Preview Admin Panel: https://tobaba.42.fr/wp-admin
	@echo Preview Database Panel: https://tobaba.42.fr/adminer

restart:
	docker compose -f ${COMPOSE_FILE} restart

# Stop all containers
down:
	docker compose -f $(COMPOSE_FILE) down

# Build and start all containers
build:
	@mkdir -p $(MARIADB_DATA) $(WORDPRESS_DATA)
	docker compose -f $(COMPOSE_FILE) up -d --build

# Clean everything
clean:
	docker compose -f $(COMPOSE_FILE) down -v --rmi all
	docker system prune -f
	rm -rf $(MARIADB_DATA) $(WORDPRESS_DATA)

# Show logs
logs:
	docker compose -f $(COMPOSE_FILE) logs -f

# Show container status
status:
	@echo "📊 Container Status:"
	@docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
	@echo ""
	@echo "🌐 Networks:"
	@docker network ls | grep inception
