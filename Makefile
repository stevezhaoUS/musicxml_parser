# Makefile for musicxml_parser

.PHONY: help install test coverage clean analyze format

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install dependencies
	dart pub get

test: ## Run tests
	dart test

coverage: ## Generate test coverage report
	@./scripts/quick-coverage.sh

clean: ## Clean build artifacts and coverage
	@rm -rf coverage/ .dart_tool/build/ build/
	@echo "🧹 Cleaned build artifacts and coverage"

analyze: ## Run static analysis
	dart analyze --fatal-infos

format: ## Format code
	dart format .

check: analyze test ## Run analysis and tests

all: install format analyze test coverage ## Run all checks
