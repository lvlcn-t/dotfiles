# dotfiles 🛠️

Dotfiles managed by [chezmoi](https://chezmoi.io/) for a consistent development
environment on Linux/WSL and macOS machines. Includes shell configs, development
tools, and a bootstrap script that wires everything together.

## What's here

### Shells

- **dot_zshrc** + **dot_zshrc.d/**: Zsh with modular config (aliases, plugins,
  environment variables, key bindings).
- **dot_config/fish/**: Fish shell — primary shell with
  [fisher](https://github.com/jorgebucaran/fisher) plugins, custom functions,
  fzf bindings, starship prompt, and Zoxide navigation.
- **dot_config/starship.toml**: Starship prompt with Gruvbox Dark theme and
  multi-language support (used by both Zsh and Fish).
- **dot_p10k.zsh**: Powerlevel10k fallback theme for Zsh.
- **dot_tmux.conf**: Tmux with `C-a` prefix and mouse support.

### Git

- **dot_gitconfig.tmpl**: Global Git settings — SSH signing, automatic signoff,
  difftastic, and Git LFS. The `glab` credential helper path is templated per
  OS (Linux vs macOS).
- **dot_gitconfig-personal** / **dot_gitconfig-work**: Applied automatically via
  `includeIf hasconfig:remote.*.url` based on whether the remote is GitHub or
  the internal GitLab instance.

### Tools

- **dot_config/k9s/**: k9s Kubernetes TUI — config, resource aliases, and
  plugins (including a `ssh-node.sh` helper).
- **dot_config/opencode/**: [opencode](https://opencode.ai) AI assistant — MCP
  servers, custom agents, and the `/review` slash command. See
  [dot_config/opencode/README.md](dot_config/opencode/README.md).
- **Brewfile**: ~65 packages — Kubernetes tools (kubectl, helm, k9s, argocd),
  cloud CLIs (awscli, azure-cli, azd), development languages (Go, Python 3.14),
  IaC tooling (terraform, kcl, helm-docs), and productivity utilities (bat, eza,
  fzf, ripgrep, lazygit).

## Installation

> [!WARNING]
> This will overwrite existing config files. Back up your dotfiles first.

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lvlcn-t
```

### What gets bootstrapped

- Passwordless `sudo` for `$USER`.
- Zsh as default shell (or Fish, if already set).
- Fish shell with fisher plugins: fzf, git, kubectl-aliases, tmux, One Dark
  theme, nvm, Zoxide (`z`), and `bass` for sourcing bash scripts.
- All dependencies from [`Brewfile`](Brewfile) via [Homebrew](https://brew.sh/).
- Starship prompt with Gruvbox theme; Powerlevel10k as Zsh fallback.
- Tmux configuration with intuitive key bindings.
- Git with SSH signing, auto-signoff, difftastic, and context-specific configs.
- Neovim from [kickstart.nvim](https://github.com/lvlcn-t/kickstart.nvim).
- Rust (rustup), Node.js (nvm), Python (Poetry).
- Docker — Linux/WSL only (skipped on macOS).
- Homebrew path resolved dynamically (`brew --prefix`) — works on both Linux
  (`/home/linuxbrew/.linuxbrew`) and macOS (`/opt/homebrew`).
- pre-commit hooks with gitleaks for secret scanning.

### Post-installation

The interactive wizard (`make prep`) prompts for:

- **Netrc credentials**: GitHub and GitLab tokens for private repo access.
- **Proxy settings**: HTTP/HTTPS proxy (optional).
- **Conjur integration**: Secret management (optional).

Skip any section to preserve existing config, or re-run anytime with
`make prep`.

## Common commands

```bash
chezmoi apply           # apply dotfiles to the system
chezmoi diff            # preview pending changes
chezmoi apply --verbose # verbose apply
make prep               # re-run the config wizard
make debug              # test bootstrap in Docker (Ubuntu 24.04)
```

For AI agents and detailed repo conventions, see [AGENTS.md](AGENTS.md).
