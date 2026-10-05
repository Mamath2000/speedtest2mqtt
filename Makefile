# Makefile pour speedtest2mqtt
.PHONY: help init run docker-build docker-release version
.DEFAULT_GOAL := help

help: ## Affiche cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-16s %s\n", $$1, $$2}'

init: ## Crée config.yaml et .env à partir des exemples (sans écraser)
	@[ -f config.yaml ] || cp config.example.yaml config.yaml
	@[ -f .env ] || { cp .env.example .env && chmod 600 .env; }
	@echo "À éditer : config.yaml, .env"

run: ## Lance localement via docker compose (image publiée)
	docker compose up -d

version: ## Affiche la version courante
	@cat VERSION

docker-build: ## Construit l'image locale (sans push)
	bash docker-release.sh build

docker-release: ## Release : version +1, commit, build et push Docker Hub, tag git
	bash docker-release.sh release
