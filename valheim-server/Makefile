.PHONY: hel:wq
p build start stop restart logs status backup clean

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the Docker image
	docker compose build

start: ## Start the Valheim server
	docker compose up -d
	@echo "Server starting... Use 'make logs' to view progress"

stop: ## Stop the Valheim server
	docker compose down

restart: ## Restart the Valheim server
	docker compose restart
	@echo "Server restarting..."

logs: ## View server logs (follow mode)
	docker compose logs -f

status: ## Show container status and stats
	@echo "=== Container Status ==="
	docker compose ps
	@echo ""
	@echo "=== Resource Usage ==="
	docker stats --no-stream valheim-server 2>/dev/null || echo "Container not running"

backup: ## Manually trigger a backup
	@echo "Creating manual backup..."
	docker-compose exec valheim-server tar -czf /home/steam/backups/manual_backup_$$(date +%Y%m%d_%H%M%S).tar.gz -C /home/steam/.config/unity3d/IronGate/Valheim/worlds .
	@echo "Backup created successfully"

list-backups: ## List all available backups
	@echo "Available backups:"
	@docker-compose exec valheim-server ls -lh /home/steam/backups/ || echo "No backups found or container not running"

clean: ## Remove all containers, volumes, and images
	@echo "WARNING: This will delete all server data and backups!"
	@echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
	@sleep 5
	docker compose down -v
	docker rmi valheim-server:latest 2>/dev/null || true
	@echo "Cleanup complete"

update: ## Update server to latest version
	docker compose pull
	docker compose up -d --build
	@echo "Server updated"

shell: ## Open a shell in the container
	docker compose exec valheim-server /bin/bash
