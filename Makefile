NAME = inception
DATA_PATH = /home/tobaba/data
COMPOSE = docker compose -f ./srcs/docker-compose.yml

all:
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	$(COMPOSE) up -d --build
	@echo "-------------------------------------------------------"
	@echo "✅  Inception is ready!"
	@echo "🌐  Website:     https://tobaba.42.fr"
	@echo "🔑  Admin Panel: https://tobaba.42.fr/wp-admin"
	@echo "-------------------------------------------------------"

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

fclean: clean
	docker system prune -af
	sudo rm -rf $(DATA_PATH)

re: fclean all

.PHONY: all down clean fclean re