# dotfiles 🛠️

Welcome to my dotfiles repository! Here you'll find everything you need to set up and maintain a consistent and productive development environment across different machines. Dotfiles are configuration files that customize and automate the setup of software applications and tools on Unix/Linux systems. By managing these files in a repository, you can easily synchronize your preferences and settings across multiple environments.

## About This Component 📝

This dotfiles collection includes configurations for multiple shells, development tools, and utilities, along with a Brewfile for managing software installations through Homebrew. Here's a brief overview of each component:

### Shell Configurations
- 💻 **dot_zshrc**: Customize your Zsh shell environment with modular configuration (aliases, plugins, environment variables, key bindings).
- 🐚 **dot_config/fish**: Full Fish shell configuration with fisher plugins, custom functions, and completions for an alternative shell experience.
- 🎨 **dot_p10k.zsh**: Powerlevel10k Zsh theme configuration (fallback prompt).
- ⭐ **dot_config/starship.toml**: Starship prompt configuration (primary prompt) with Gruvbox Dark theme and multi-language support.
- 🖥️ **dot_tmux.conf**: Tmux terminal multiplexer configuration with custom key bindings (prefix: C-a) and mouse support.

### Development Tools
- 🌍 **dot_gitconfig**: Global Git settings with automatic SSH signing, signoff, and context-aware configurations.
- 🏡 **dot_gitconfig-personal** & 💼 **dot_gitconfig-work**: Automatically apply specific Git configurations based on repository remote URL (GitHub vs GitLab).
- 🗝️ **dot_netrc**: Store credentials for accessing remote servers with automated authentication.
- 📥 **dot_wgetrc**: Customize wget download options.
- 📦 **dot_npmrc**: Manage npm settings for node packages.
- 🍺 **Brewfile**: 65+ packages including Kubernetes tools (kubectl, helm, k9s, argocd), cloud CLIs (AWS, Azure), development languages (Go, Python 3.14), and productivity utilities (bat, eza, fzf, ripgrep).

Feel free to explore and adapt these configurations to suit your own development needs and preferences. Happy coding! 😄

## Installation 🚀

**Warning:** This installation process will **overwrite** any existing configuration files. Make sure to back up your current dotfiles before proceeding.

To install my dotfiles, simply run the following command in your terminal:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lvlcn-t
```

This command will install [chezmoi](https://chezmoi.io/) and apply my dotfiles to your system. Chezmoi is a tool for managing dotfiles across multiple machines, providing a simple and secure way to handle your configuration files. For more information, check out the [official documentation](https://www.chezmoi.io/docs/).

### What Gets Installed

My dotfiles will bootstrap your system with the following:
- Passwordless `sudo` access for `$USER`.
- Zsh as the default shell with [zplug](https://github.com/zplug/zplug) plugin manager.
- Fish shell (alternative) with [fisher](https://github.com/jorgebucaran/fisher) plugin manager.
- Install all 65+ dependencies from [`Brewfile`](Brewfile) using [Homebrew](https://brew.sh/).
- [Starship](https://starship.rs/) prompt (primary) with custom Gruvbox theme.
- Powerlevel10k theme (fallback) from [`dot_p10k.zsh`](dot_p10k.zsh).
- Tmux configuration with intuitive key bindings and mouse support.
- Git with SSH signing, auto-signoff, and context-specific configs ([`dot_gitconfig-personal`](dot_gitconfig-personal), [`dot_gitconfig-work`](dot_gitconfig-work)).
- Neovim configuration from [kickstart.nvim](https://github.com/lvlcn-t/kickstart.nvim).
- Python environment with Poetry for running the configuration wizard.
- Development tools: kubectl, helm, k9s, argocd, AWS CLI, Azure CLI, Go, Python 3.14, and more.
- Security: pre-commit hooks with gitleaks for secret scanning.

### Post-Installation

After installation, the interactive configuration wizard will prompt you to configure:
- **Netrc credentials**: GitHub and GitLab tokens for private repository access.
- **Proxy settings**: HTTP/HTTPS proxy configuration (optional).
- **Conjur integration**: Secret management configuration (optional).

You can skip any section to preserve existing configuration or re-run the wizard anytime with `make prep`.

## Usage 🎯

### Common Commands

```bash
# Apply dotfiles changes
chezmoi apply
```

For AI agents and detailed technical documentation, see [AGENTS.md](AGENTS.md).

Feel free to adapt these steps to your specific needs!
