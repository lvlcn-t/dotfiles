.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: install
install: configure apply ## Installs the dotfiles on your system
	@echo "Installation complete! Have fun!"

.PHONY: configure
configure: ## Configure the dotfile configurations
	@echo "Let's configure the dotfiles to your preferences..."
	@chmod +x ./scripts/configure.sh
	@./scripts/configure.sh

.PHONY: update
update: ## Update the dotfiles with the latest changes
	@echo "Updating the dotfiles to the latest changes..."
	@git pull
	@echo "Updating the dotfiles to the latest changes... Done"

.PHONY: apply
apply: ## Apply the dotfiles
	@echo "Applying the dotfiles..."
	@chezmoi apply
	@echo "Applying the dotfiles... Done"

.PHONY: pre-install
pre-install: ## Install the pre-requisites
	@chezmoi execute-template < ~/.local/share/chezmoi/run_once_before_install-deps.sh.tmpl > ./scripts/install-deps.sh
	@chmod +x ./scripts/install-deps.sh
	@./scripts/install-deps.sh

.PHONY: bump-deps
bump-deps: ## Bump the dependencies
	@brew bundle dump --force --file=./Brewfile
	@brew bundle install --file=./Brewfile
	@git add ./Brewfile ./Brewfile.lock.json || true # ignore if there are no changes
	@git branch | grep -q 'chore/bump-deps' && git checkout chore/bump-deps || git checkout -b chore/bump-deps
	@git commit -m "chore: bump dependencies" || true # ignore if there are no changes
	@git push origin chore/bump-deps || true # ignore if there are no changes
	@if [ -z "$(shell gh pr list --state open --base main --head chore/bump-deps)" ]; then \
		gh pr create --base main --head chore/bump-deps --title "chore: bump dependencies" --body "Bumps the dependencies"; \
	fi
	@git checkout main

.PHONY: debug
debug: ## Debugs the dotfiles
	@docker build -f Dockerfile -t dotfiles-debug .
	@docker run -it --rm dotfiles-debug /bin/bash -c "\
		~/bin/chezmoi execute-template < ~/.local/share/chezmoi/scripts/run_once_before_install-deps.sh.tmpl > ~/.local/share/chezmoi/scripts/script.sh && \
		chmod +x ~/.local/share/chezmoi/scripts/script.sh && \
		~/.local/share/chezmoi/scripts/script.sh && \
		~/bin/chezmoi apply --verbose --force && \
		zsh"

.PHONY: lint
lint: ## Run the linter (secret detection)
	@pre-commit run -a