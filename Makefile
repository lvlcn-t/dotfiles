.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help
help:
	@echo "📖 Usage: make [target]"
	@echo ""
	@echo "🎯 Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: clean-state
clean-state: ## 🧹 Cleans up the Chezmoi state buckets
	@echo "🧹 Cleaning up the Chezmoi state buckets..."
	@chezmoi state delete-bucket --bucket=entryState
	@chezmoi state delete-bucket --bucket=scriptState
	@echo "✅ Chezmoi state buckets cleaned successfully."


.PHONY: install
install: clean-state ## 📦 Installs the dotfiles on your system
	@echo "🔧 Installing dotfiles..."
	@chezmoi apply
	@echo "✅ Dotfiles installed successfully."

.PHONY: bundle
bundle: ## 📦 Updates the Brewfile with the currently installed Homebrew packages
	@echo "🔄 Updating Brewfile with currently installed Homebrew packages..."
	@brew bundle dump --no-vscode --force --file=./Brewfile
	@brew bundle dump --vscode --force --file=./Brewfile.vscode
	@echo "✅ Brewfile updated successfully."

.PHONY: image
image: ## 🐳 Builds the Docker image for testing
	@echo "🐳 Building Docker image..."
	@docker build -f Dockerfile -t dotfiles .
	@echo "✅ Docker image built successfully."

.PHONY: debug
debug: image ## 🐛 Debugs the dotfiles
	@echo "🧩 Running container to apply dotfiles..."
	@docker run -it --rm dotfiles bash -c "/home/testuser/bin/chezmoi apply --verbose --force && /bin/bash"
