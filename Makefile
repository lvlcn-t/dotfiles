.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help
help:
	@echo "📖 Usage: make [target]"
	@echo ""
	@echo "🎯 Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: install
install: prep ## 📦 Installs the dotfiles on your system
	@echo "🔧 Installing dotfiles..."
	@chezmoi apply
	@echo "✅ Dotfiles installed successfully."

.PHONY: prep
prep: ## 🧪 Installs all python dependencies for the configuration script
ifeq ($(shell which poetry),)
	@echo "❌ Poetry is not installed. Please install it first."
	@exit 1
endif
	@echo "🐍 Installing Python dependencies with Poetry..."
	@poetry install
	@echo "🧙‍♂️ Running configuration wizard..."
	@poetry run python3 scripts/configure.py

.PHONY: bump-deps
bump-deps: ## 🚀 Bump the dependencies
	@echo "🔄 Dumping and installing latest Brewfile..."
	@brew bundle dump --force --file=./Brewfile
	@brew bundle install --file=./Brewfile
	@git add ./Brewfile || true # ignore if there are no changes
	@echo "🌱 Creating or switching to branch chore/bump-deps..."
	@git branch | grep -q 'chore/bump-deps' && git checkout chore/bump-deps || git checkout -b chore/bump-deps
	@git commit -m "chore: bump dependencies" || true
	@git push --force -u origin chore/bump-deps || true
	@echo "📬 Creating PR if none exists..."
	@if [ -z "$(shell gh pr list --state open --base main --head chore/bump-deps)" ]; then \
		gh pr create --base main --head chore/bump-deps --title "chore: bump dependencies" --body "Bumps the dependencies"; \
	fi
	@echo "🏁 Switching back to main branch..."
	@git checkout main

.PHONY: debug
debug: ## 🐛 Debugs the dotfiles
	@echo "🐳 Building debug Docker container..."
	@docker build -f Dockerfile -t dotfiles-debug .
	@echo "🧩 Running container with template rendering and verbose apply..."
	@docker run -it --rm dotfiles-debug /bin/bash -c "\
		~/bin/chezmoi execute-template < ~/.local/share/chezmoi/scripts/run_once_before_install-deps.sh.tmpl > ~/.local/share/chezmoi/scripts/script.sh && \
		chmod +x ~/.local/share/chezmoi/scripts/script.sh && \
		~/.local/share/chezmoi/scripts/script.sh && \
		~/bin/chezmoi apply --verbose --force && \
		zsh"
