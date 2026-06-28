.DEFAULT_GOAL := help
SHELL := /bin/bash

VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "v0.0.0")
LDFLAGS := -s -w -X main.version=$(VERSION)
ARGS :=

.PHONY: help
help: ## Display this help
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-20s\033[0m- %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: build
build: ## Build the CLI binary
	@go build -ldflags="$(LDFLAGS)" -o bin/dotfiles main.go

.PHONY: dev
dev: build ## Build and run the CLI (e.g. make dev ARGS="apply")
	@./bin/dotfiles $(ARGS)

.PHONY: test
test: ## Run all tests
	@go test -race -cover -count=1 -v ./...

.PHONY: clean-state
clean-state: ## Clean Chezmoi state buckets
	@chezmoi state delete-bucket --bucket=entryState
	@chezmoi state delete-bucket --bucket=scriptState

.PHONY: install
install: build clean-state ## Build and apply dotfiles (wipes state first)
	@./bin/dotfiles apply

.PHONY: bundle
bundle: ## Update Brewfiles with currently installed packages
	@brew bundle dump --no-vscode --force --file=./Brewfile
	@brew bundle dump --vscode --force --file=./Brewfile.vscode

.PHONY: image
image: build ## Build Docker image for testing
	@docker build --build-arg TARGETPLATFORM=bin -f Dockerfile -t dotfiles .

.PHONY: debug
debug: image ## Run dotfiles in Docker interactively
	@docker run -it --rm \
		-v $(PWD):/home/testuser/.local/share/chezmoi \
		dotfiles dotfiles apply --non-interactive --verbose
