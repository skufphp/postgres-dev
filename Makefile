# ==========================================
# PostgreSQL & pgAdmin Docker Environment
# ==========================================

.PHONY: help up down restart logs status shell clean clean-all

# Цвета для вывода
YELLOW=\033[0;33m
GREEN=\033[0;32m
RED=\033[0;31m
NC=\033[0m

# Команда Compose
COMPOSE = docker compose

help: ## Показать справку
	@echo "$(YELLOW)PostgreSQL Dev Environment$(NC)"
	@echo "======================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

check-env: ## Проверить наличие .env файла
	@if [ ! -f .env ]; then \
		echo "$(RED)✗ .env не найден. Скопируйте его из .env.example: cp .env.example .env$(NC)"; \
		exit 1; \
	fi

up: check-env ## Запустить контейнеры
	$(COMPOSE) up -d
	@echo "$(GREEN)✓ Проект запущен$(NC)"
	@echo "$(YELLOW)PostgreSQL доступен на порту:$(NC) $$(grep DB_FORWARD_PORT .env | cut -d '=' -f 2)"
	@echo "$(YELLOW)pgAdmin доступен на:$(NC) http://localhost:$$(grep PGADMIN_PORT .env | cut -d '=' -f 2)"

down: ## Остановить контейнеры
	$(COMPOSE) down

restart: ## Перезапустить контейнеры
	$(COMPOSE) restart

logs: ## Показать логи всех сервисов
	$(COMPOSE) logs -f

logs-db: ## Показать логи PostgreSQL
	$(COMPOSE) logs -f postgres-dev

logs-pgadmin: ## Показать логи pgAdmin
	$(COMPOSE) logs -f pgadmin-dev

status: ## Статус контейнеров
	$(COMPOSE) ps

shell: ## Войти в консоль psql внутри контейнера
	$(COMPOSE) exec postgres-dev psql -U postgres

clean: ## Остановить контейнеры и удалить тома (ОСТОРОЖНО: удалит все данные БД)
	$(COMPOSE) down -v
	@echo "$(RED)! Контейнеры и данные БД удалены$(NC)"

clean-all: ## Полная очистка (контейнеры, образы, тома)
	$(COMPOSE) down -v --rmi all
	@echo "$(GREEN)✓ Выполнена полная очистка$(NC)"

.DEFAULT_GOAL := help
