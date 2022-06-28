init:
	git config core.hooksPath .githooks
	cp .env.example .env

.PHONY: help
help: ## Displays this list of targets with descriptions
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: setup
setup: init build vendor node ## Setup the local environment

.PHONY: build
build: ## Build the local Docker containers
	docker-compose build --no-cache --build-arg USER_ID=$(shell id -u) --build-arg GROUP_ID=$(shell id -g)

.PHONY: up
up: ## Bring up the docker-compose stack
	docker-compose up -d

.PHONY: fix
fix: up ## Fix code style
	docker-compose exec laravel.app vendor/bin/php-cs-fixer fix

.PHONY: check
check: up ## Fix code style
	docker-compose exec laravel.app vendor/bin/php-cs-fixer fix --dry-run --stop-on-violation

.PHONY: test
test: up ## Runs tests with PHPUnit
	docker-compose exec laravel.app composer test
	docker-compose exec laravel.app composer stan

vendor: up composer.json ## Install composer dependencies, run artisan setup
	docker-compose exec laravel.app composer install
	docker-compose exec laravel.app composer update --lock
	docker-compose exec laravel.app composer validate --strict
	docker-compose exec laravel.app composer normalize
	docker-compose exec laravel.app php artisan key:generate
	docker-compose exec laravel.app php artisan migrate:fresh
	docker-compose exec laravel.app php artisan shield:generate
	docker-compose exec laravel.app php artisan db:seed
	docker-compose exec laravel.app php artisan storage:link

db-fresh: up ## Resets the databse
	docker-compose exec laravel.app php artisan migrate:fresh

db-seed: up ## Seed the DB with data
	docker-compose exec laravel.app php artisan db:seed

optimize: up ##Optimizes the backend
	docker-compose exec laravel.app php artisan optimize:clear
	docker-compose exec laravel.app php artisan optimize

node: up package.json ## Install node dependencies and start the file watcher
	docker-compose exec laravel.node npm install
	docker-compose exec -d laravel.node npm run watch

.PHONY: app
app: up ## Open an interactive shell into the PHP container
	docker-compose exec laravel.app bash

.PHONY: pre-commit
pre-commit: up ## Run pre-commit checks
	docker-compose exec -T laravel.app vendor/bin/php-cs-fixer fix

.PHONY: pre-push
pre-push: up ## Run pre-push checks
	docker-compose exec -T laravel.app vendor/bin/php-cs-fixer fix --dry-run --stop-on-violation
	docker-compose exec -T laravel.app composer test