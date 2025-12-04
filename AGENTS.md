# AGENTS.md

This document provides essential information for AI agents working in this dotfiles repository. This is a [chezmoi](https://www.chezmoi.io/)-managed dotfiles repository that configures development environments across multiple machines.

## Repository Overview

**Purpose**: Personal dotfiles repository that bootstraps and maintains a consistent development environment across Linux/WSL machines.

**Technology Stack**:
- **Dotfile Manager**: chezmoi (template-based dotfile management)
- **Package Manager**: Homebrew (Linux)
- **Shells**: 
  - Zsh (primary) with zplug plugin manager
  - Fish shell (alternative, fully configured with fisher plugins)
- **Prompt**: Starship (primary) or Powerlevel10k (fallback for Zsh)
- **Terminal Multiplexer**: tmux (with custom key bindings)
- **Python**: Poetry for dependency management (Python 3.14+)
- **Testing**: pytest, ruff for linting
- **Security**: pre-commit hooks with gitleaks for secret scanning

**Key Files**:
- `Makefile`: Primary interface for common operations
- `pyproject.toml`: Python project configuration
- `Brewfile`: Homebrew package definitions (65 packages)
- `scripts/configure.py`: Interactive configuration wizard
- `.pre-commit-config.yaml`: Git hook configuration
- `config/chezmoi.toml`: Template configuration file

## Essential Commands

### Development Workflow

```bash
# Install/apply dotfiles (requires Poetry)
make install

# Prepare Python environment and run config wizard
make prep

# Debug dotfiles in Docker container
make debug

# Update dependencies and create PR
make bump-deps

# Show all available targets
make help
```

### Chezmoi Operations

```bash
# Apply dotfiles to system
chezmoi apply

# Apply with verbose output
chezmoi apply --verbose

# Edit a managed file
chezmoi edit ~/.zshrc

# See what would change
chezmoi diff

# Re-run scripts manually
chezmoi execute-template < run_once_before_01-install-deps.sh.tmpl
```

### Python Environment

```bash
# Install dependencies (from project root)
poetry install

# Run configuration wizard
poetry run python3 scripts/configure.py

# Run tests
poetry run pytest

# Run linting
poetry run ruff check
```

### Git Operations

```bash
# All commits are automatically signed and include signoff
# Configured via .gitconfig: gpgsign=true, signoff=true

# Context-aware Git configs:
# - github.com repos → .gitconfig-personal
# - gitlab.devops.telekom.de repos → .gitconfig-work
```

### Pre-commit Hooks

```bash
# Install hooks
pre-commit install

# Run manually on all files
pre-commit run --all-files

# Run gitleaks only
pre-commit run gitleaks --all-files
```

## Project Structure

### Dotfile Organization

```
.
├── dot_*                          # Files starting with "dot_" → ~/.* (e.g., dot_zshrc → ~/.zshrc)
├── dot_config/                    # Maps to ~/.config/
│   ├── starship.toml             # Starship prompt configuration
│   └── private_fish/             # Fish shell config (prefix "private_" = read-only by owner)
│       ├── config.fish.tmpl      # Main fish configuration (templated)
│       ├── fish_plugins          # Fisher plugin list
│       ├── functions/            # Fish shell functions (git helpers, fzf, z, etc.)
│       ├── completions/          # Shell completions (fisher, fzf, nvm)
│       └── conf.d/               # Autoloaded config files (async_prompt, fzf, git, nvm, tmux, z)
├── dot_zshrc.d/                  # Zsh configuration modules
│   ├── aliases.zsh               # Command aliases and shell functions (234 lines)
│   ├── env.zsh.tmpl              # Environment variables (templated)
│   ├── keybindings.zsh           # Key bindings configuration
│   └── plugins.zsh               # Zplug plugin declarations
├── dot_tmux.conf                 # Tmux terminal multiplexer configuration
├── dot_p10k.zsh                  # Powerlevel10k prompt theme config (fallback)
├── dot_gitconfig*                # Git configurations (main, personal, work)
├── dot_netrc.tmpl                # Network credentials (templated, private)
├── dot_npmrc.tmpl                # NPM configuration (templated)
├── dot_wgetrc.tmpl               # Wget configuration (templated)
├── run_once_before_*.sh.tmpl     # Bootstrap scripts (run once before apply)
├── scripts/                       # Helper scripts
│   └── configure.py              # Interactive configuration wizard
├── config/                        # Configuration templates
│   └── chezmoi.toml              # Default chezmoi config template
├── Brewfile                       # Homebrew package definitions (65 packages)
├── Makefile                       # Main interface for common operations
├── Dockerfile                     # Docker container for testing dotfiles
└── .chezmoiexternal.toml         # External resources (nvim from GitHub)
```

### Naming Conventions

**Chezmoi file naming**:
- `dot_` prefix → `.` in home directory (e.g., `dot_zshrc` → `~/.zshrc`)
- `private_` prefix → file permissions set to 0600 (owner read/write only)
- `.tmpl` suffix → file is processed as Go template
- `run_once_before_*.sh.tmpl` → bootstrap script executed once before applying
- `run_onchange_*.sh` → script runs when content changes

**Script execution order**:
1. `run_once_before_00-setup.sh.tmpl` - Copy initial chezmoi config
2. `run_once_before_01-install-deps.sh.tmpl` - Install system dependencies
3. `run_once_before_02-config-wizard.sh.tmpl` - Run interactive configuration

### Code Organization

**Zsh configuration** is modular:
- `~/.zshrc` (from `dot_zshrc.tmpl`) - Main entry point, sources modules
- `~/.zshrc.d/plugins.zsh` - Plugin management (zplug, oh-my-zsh plugins)
- `~/.zshrc.d/env.zsh.tmpl` - Environment setup, tool initialization
- `~/.zshrc.d/aliases.zsh` - Aliases and shell functions (234 lines)
- `~/.zshrc.d/keybindings.zsh` - Key bindings and shell options

**Fish shell configuration**:
- `~/.config/fish/config.fish` (from `dot_config/private_fish/config.fish.tmpl`) - Main fish config
- Uses fisher for plugin management (plugins declared in `fish_plugins`)
- `functions/` - Custom functions for git workflows, fzf, z directory jumping, nvm
- `completions/` - Shell completions for fisher, fzf, nvm
- `conf.d/` - Auto-loaded configuration files (async_prompt, fzf, git, nvm, tmux, z)

**Tmux configuration**:
- `~/.tmux.conf` (from `dot_tmux.conf`) - Terminal multiplexer settings
- Prefix: `C-a` (instead of default `C-b`)
- Split panes: `|` (horizontal), `-` (vertical)
- Mouse support enabled
- Vi mode keys
- Alt-arrow keys for pane navigation without prefix

**Python scripts**:
- `scripts/configure.py` - Interactive wizard for netrc, proxy, and Conjur configuration
- Uses `tomllib` for reading, `toml` for writing TOML configs

## Chezmoi Templates

### Template Variables

Templates use Go template syntax with custom data from `~/.config/chezmoi/chezmoi.toml`:

```toml
[data.machine.proxy]
enabled = false
http = "http://proxy.example.com:8080"
https = "https://proxy.example.com:8080"
no_proxy = "example.com"

[data.machine.conjur]
url = "https://conjur.example.com"
account = "my-account"
sns = "example/secret/namespace"
login_host = "$CONJUR_SNS/my-host"
api_key = "my-api-key"

[[data.netrc.machines]]
url = "https://gitlab.com"
username = "__token__"
token = "glpat-xxxxxxx"
```

**Template Usage Examples**:

```bash
# In .tmpl files, access variables:
{{ .chezmoi.sourceDir }}           # Source directory path
{{ .chezmoi.configFile }}          # Config file path
{{ .machine.proxy.enabled }}       # Custom data from config
{{ .machine.proxy.http }}          # Proxy HTTP URL
{{ .machine.conjur.url }}          # Conjur URL

# Conditionals:
{{- if .machine.proxy.enabled }}
export HTTP_PROXY={{ .machine.proxy.http }}
{{- end }}
```

### Built-in Chezmoi Variables

- `.chezmoi.sourceDir` - Source directory (`~/.local/share/chezmoi`)
- `.chezmoi.configFile` - Config file path (`~/.config/chezmoi/chezmoi.toml`)
- `.chezmoi.homeDir` - Home directory

## Code Patterns & Conventions

### Shell Scripting

**Function naming**:
- Public functions: snake_case (e.g., `argocd-login`)
- Private/internal functions: `__snake_case` with double underscore prefix
- Internal functions are unset at end of script: `unset -f __function_name`

**Function documentation style**:
```bash
# Brief description
# Args:
#   arg1: Description
#   arg2: Description
# Returns:
#   0 if successful, 1 if error
# Exports:
#   VAR_NAME: Description
function_name() {
  # implementation
}
```

**Conditional sourcing pattern**:
```bash
sourceIfExists() {
  test -f "$1" && source "$1"
}
sourceIfExists "$HOME/.zshrc.d/plugins.zsh"
```

**Common patterns in aliases.zsh**:
- Check command availability: `if command -v tool &>/dev/null; then`
- Conditional alias definition based on tool availability
- Functions with autocomplete using `compdef`

### Python Code

**Style**:
- Python 3.14+ with type hints
- Use `tomllib` (built-in) for reading TOML, `toml` package for writing
- Emoji prefixes for user-facing messages: 🚀 📦 ✅ ❌ ⚠️ 🔐 🌐 etc.
- Interactive prompts with yes/no/skip options
  - Yes answers: `y`, `yes`, `ye`, `yeah`, `yep`, `bet`, `sure`
  - No answers: `n`, `no`, `nah`, `nope`, `never`, `not really`
  - Skip answers: `skip`, `s`, `sk`, `pass`
- Preserve existing configuration when skipped

**Configuration wizard pattern**:
```python
def configure_section(config: dict[str, Any]) -> dict[str, Any]:
    """Update or preserve configuration section."""
    existing = config.get("data", {}).get("section", {})
    if existing:
        print("Current config found:")
        # Display existing
    
    answer = ask_yes_no("Do you want to (re)configure?")
    if answer is None:  # skip
        print("Skipping, preserving current values.")
        return config
    
    # Gather new values or use defaults
    config.setdefault("data", {})["section"] = new_values
    return config
```

### Git Configuration

**Commit signing**:
- All commits are GPG-signed using SSH key (`~/.ssh/id_rsa.pub`)
- Format: `signoff = true` (automatic Signed-off-by line)
- Configured in `.gitconfig`: `commit.gpgsign = true`, `format.signoff = true`

**Conditional includes** (context-aware configs):
```gitconfig
# Supports both SSH and HTTPS URLs
[includeIf "hasconfig:remote.*.url:git@github.com*/**"]
    path = .gitconfig-personal

[includeIf "hasconfig:remote.*.url:https://github.com/**"]
    path = .gitconfig-personal

[includeIf "hasconfig:remote.*.url:git@gitlab.devops.telekom.de*/**"]
    path = .gitconfig-work

[includeIf "hasconfig:remote.*.url:https://gitlab.devops.telekom.de/**"]
    path = .gitconfig-work
```

**Diff/Merge tool**: neovim (`nvimdiff`)

## Environment Setup

### Bootstrapping Process

1. **Initial setup** (`run_once_before_00-setup.sh.tmpl`):
   - Copies `config/chezmoi.toml` to `~/.config/chezmoi/chezmoi.toml` if missing

2. **Dependency installation** (`run_once_before_01-install-deps.sh.tmpl`):
   - Sets up passwordless sudo for current user
   - Installs system packages: git, curl, wget, zsh, tree, ca-certificates
   - Sets zsh as default shell
   - Installs Homebrew and runs `brew bundle install`
   - Installs Rust (rustup), pipx, Poetry, nvm
   - Installs Docker if missing
   - Installs kubectl krew plugins: ctx, ns, mc
   - Handles proxy configuration (interactive or from config)

3. **Configuration wizard** (`run_once_before_02-config-wizard.sh.tmpl`):
   - Checks if config file differs from template
   - If identical to template, removes config file to force re-run
   - Runs `poetry install` to set up Python environment
   - Executes `scripts/configure.py` for interactive setup
   - Configures netrc, proxy, and Conjur settings
   - Writes final config to `~/.config/chezmoi/chezmoi.toml`
   - Allows skipping sections to preserve existing config

### Development Tools

**Installed via Homebrew** (see full list in `Brewfile`):
- **Version control**: git, git-lfs, git-town, gh (GitHub CLI), glab (GitLab CLI)
- **Kubernetes**: kubectl, helm, k9s, kind, argocd, krew, kubeconform, kustomize
- **Cloud**: awscli, azure-cli, azd (Azure Dev CLI)
- **Languages**: go, python@3.14, gcc
- **DevOps**: terraform, act, gomplate, lazygit
- **Utilities**: bat, eza, fastfetch, fd, ripgrep, jq, yq, fzf, neovim, starship
- **Security**: gitleaks, pre-commit
- **Linting**: golangci-lint, ruff, protolint

**Shell plugins** (via zplug/oh-my-zsh):
- Completions: kubectl, docker, helm, git, gh, argocd, aws, azure, gcloud
- Productivity: autojump, command-not-found, zsh-autosuggestions, zsh-syntax-highlighting
- Search: zsh-history-substring-search, zsh-autocomplete

### Environment Variables

**Key environment variables set in `env.zsh.tmpl`**:
- `LANG=C.UTF-8`
- `HISTFILE=~/.zsh_history`, `HISTSIZE=10000`, `SAVEHIST=10000`
- `PATH` additions: `$HOME/bin`, `$HOME/go/bin`, `$HOME/.krew/bin`, `$PNPM_HOME`
- `GOPRIVATE=gitlab.devops.telekom.de`, `GO111MODULE=on`
- GitHub: `GH_USER`, (`GH_TOKEN` commented - conflicts with copilot)
- GitLab: `GITLAB_HOST`, `GITLAB_USER`, `GITLAB_TOKEN`, `GITLAB_API_TOKEN`
- Conjur: `CONJUR_APPLIANCE_URL`, `CONJUR_ACCOUNT`, `CONJUR_SNS`, etc.
- Telemetry disabled: `AZURE_DEV_COLLECT_TELEMETRY=no`, `FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=true`

**Proxy configuration** (conditional):
```bash
{{- if .machine.proxy.enabled }}
export HTTP_PROXY={{ .machine.proxy.http }}
export HTTPS_PROXY={{ .machine.proxy.https }}
export NO_PROXY={{ .machine.proxy.no_proxy }}
{{- end }}
```

## Key Aliases & Functions

### Git Aliases
- `gcs` - `git commit --signoff`
- `gt` - `git town` (git-town workflow tool)
- `gts` - `git town sync`
- `gtb` - `git town branch`
- `gtsw` - `git town switch`

### GitLab Aliases
- `gpsci` - `git push -o ci.skip` (push without triggering CI)
- `glab-clone` - Clone with GitLab groups: `glab repo clone -g <group>`
- `gci` - `gitlab-ci-local` (run GitLab CI locally)

### Kubernetes Functions
- `ctx` / `ns` - kubectl context/namespace switchers (krew plugins)
- `argocd-login <context>` - Log into ArgoCD with auto port-forwarding

### Other Aliases
- `ls`, `ll`, `tree` - Enhanced with `eza` (icons, git integration)
- `neofetch` → `fastfetch` (faster system info)
- `ghc` - `gh copilot` (GitHub Copilot CLI)
- `dive` - Docker image explorer (via container)
- `jaeger` - Start Jaeger tracing container (all-in-one:1.60)
- `conjur-login` - Log into Conjur instance
- `flo` - Activate Flox environment
- `yt-mp3` - Extract MP3 from videos using yt-dlp
- `du-brew` - Show disk usage by Homebrew package (sorted by size)

### WSL-Specific Aliases
```bash
# Only available on WSL
whoami-wsl      # Display Windows username
cdw             # cd to Windows home directory
docs            # cd to Windows documents
```

## Shell-Specific Features

### Fish Shell

**Plugin management** (via fisher):
- Plugins listed in `~/.config/fish/fish_plugins`
- Auto-installed on first run if fisher is available
- Key plugins: fzf, z (directory jumping), nvm, git helpers

**Custom functions**:
- Git workflow: `gwip`, `gunwip`, `gbage`, `gbda`, `grename`, `grt`, `gtest`
- Fzf integration: `_fzf_search_directory`, `_fzf_search_git_log`, `_fzf_search_history`, `_fzf_search_processes`
- Directory navigation: `z` (frecency-based cd)
- Node version management: `nvm` functions

**Configuration features**:
- Async prompt for better performance
- Tmux integration (auto-start/attach)
- Git status in prompt
- Custom theme: "One Dark"

### Tmux Usage

**Key Bindings**:
- Prefix: `C-a` (Ctrl+A)
- Split horizontal: `C-a |`
- Split vertical: `C-a -`
- Reload config: `C-a r`
- Navigate panes: `Alt+Arrow` (no prefix needed)
- Previous window: `C-a p`

**Features**:
- Mouse support enabled (clickable panes, resizable)
- Vi mode keys for copy mode
- Windows/panes start at index 1 (not 0)
- New windows/panes open in current directory
- 256 color support with truecolor

### Starship Prompt

**Configuration**: `~/.config/starship.toml`
- Custom format with modules: OS, username, directory, git, languages, docker, time
- Color palette: Gruvbox Dark
- Language support: C, Rust, Go, Node.js, PHP, Java, Kotlin, Haskell, Python
- Git integration: branch and status display
- Docker context awareness

## Testing & CI

### GitHub Actions

**Workflow**: `.github/workflows/test_sast.yml`
- **Trigger**: On every push
- **Job**: Run gitleaks secret scanning
- Uses: `gitleaks/gitleaks-action@v2`

### Pre-commit Hooks

**Configuration**: `.pre-commit-config.yaml`
- **Hook**: gitleaks@v8.18.2
- Scans for secrets in commits before allowing push

### Python Testing

```bash
# Run tests
poetry run pytest

# Run linting
poetry run ruff check

# Format code
poetry run ruff format
```

## Important Gotchas

### Chezmoi-Specific

1. **Template syntax**: Use `{{-` to trim preceding whitespace, `-}}` for trailing
2. **File permissions**: Use `private_` prefix for sensitive files (0600 permissions)
3. **Run-once scripts**: Named `run_once_before_*.sh.tmpl` execute once, then chezmoi tracks state
4. **External resources**: `.chezmoiexternal.toml` defines external resources (e.g., nvim config from GitHub)
5. **Ignored files**: `.chezmoiignore` prevents certain files from being applied
   - Repository files: `README.md`, `LICENSE`, `Dockerfile`, `Makefile`, `pyproject.toml`, `poetry.lock`
   - Config templates: `config/`, `chezmoi.toml`, `.chezmoidata.yaml`
   - Scripts and development: `scripts/`, `.venv/`, `.vscode/`
   - Bootstrap scripts: `run_once_before_*.sh.tmpl`
   - Git/CI configs: `.gitignore`, `.pre-commit-config.yaml`

### Configuration

1. **Config file locations**:
   - Template: `~/.local/share/chezmoi/config/chezmoi.toml`
   - Active config: `~/.config/chezmoi/chezmoi.toml`
   - Wizard compares and removes active if identical to template

2. **Chezmoi settings**:
   - Auto-commit: enabled (`git.autoCommit = true`)
   - Auto-push: disabled (`git.autoPush = false`)
   - Editor: VSCode with `--wait` flag (`edit.command = "code"`)
   - Commit message: interactive prompt

3. **Netrc parsing**: Custom shell function `__parse_netrc` extracts credentials
   - Format: `machine <host> login <user> password <token>`

4. **GitHub CLI auth**: `GH_TOKEN` env var is commented out in env.zsh (conflicts with copilot)

5. **GitLab host**: Hardcoded to `gitlab.devops.telekom.de` in env.zsh.tmpl:107

### Shell Configuration

1. **Function cleanup**: Internal functions prefixed with `__` are unset at end of scripts
2. **Conditional sourcing**: Use `sourceIfExists` function to safely source optional files
3. **Plugin load order**: zsh-history-substring-search MUST load after zsh-syntax-highlighting (defer:3)
4. **Profiling**: Set `PROFILING=1` env var before loading zsh to enable `zprof`

### Python Development

1. **Poetry location**: `~/.local/bin/poetry` (installed via pipx)
2. **Python version**: Requires Python 3.14+ (`requires-python = ">=3.14"`)
3. **Package mode**: `package-mode = false` (not a published package)
4. **Config file permissions**: `configure.py` sets 0600 on chezmoi.toml for security

### Git Operations

1. **Auto-signoff**: ALL commits automatically include `Signed-off-by` line
2. **SSH signing**: Uses SSH key at `~/.ssh/id_rsa.pub` (not GPG)
3. **Context switching**: Git config changes automatically based on remote URL
4. **Git LFS**: Configured for large file support (filter in .gitconfig)

### External Dependencies

1. **Neovim config**: Fetched from `https://github.com/lvlcn-t/kickstart.nvim` as git-repo
2. **Homebrew path**: Hardcoded to `/home/linuxbrew/.linuxbrew/bin/brew` (Linux installation)
3. **Krew plugins**: Only install if `kubectl-krew` command exists
4. **Fisher (Fish)**: Plugin manager for Fish shell, auto-installed if missing

## Working with This Repository

### Making Changes to Dotfiles

```bash
# Edit a managed file (opens in VSCode by default)
chezmoi edit ~/.zshrc

# Or edit source file directly
vim ~/.local/share/chezmoi/dot_zshrc.tmpl

# See what would change before applying
chezmoi diff

# Apply changes
chezmoi apply

# Apply to specific file
chezmoi apply ~/.zshrc
```

### Adding New Dotfiles

```bash
# Add existing file to chezmoi
chezmoi add ~/.newfile

# Add as template if it needs variable substitution
chezmoi add --template ~/.newfile

# Add as private if it contains secrets
chezmoi add --template --private ~/.newsecret
```

### Updating Dependencies

```bash
# Update Brewfile and create PR automatically
make bump-deps

# This will:
# 1. Run `brew bundle dump --force`
# 2. Install from Brewfile
# 3. Create/checkout branch chore/bump-deps
# 4. Commit and push
# 5. Create PR if none exists
# 6. Switch back to main
```

### Testing Changes

```bash
# Test in Docker container (full bootstrap)
make debug

# This builds Dockerfile and runs:
# - Template rendering
# - Dependency installation  
# - chezmoi apply --verbose --force
# - Drops into zsh shell for testing
```

**Docker test environment**:
- Base image: Ubuntu 24.04
- Creates test user: `testuser` (with passwordless sudo)
- Installs chezmoi via get.chezmoi.io
- Copies entire dotfiles repo to `~/.local/share/chezmoi`
- Runs full bootstrap process in container
- Allows interactive testing in zsh shell

### Configuration Changes

```bash
# Run configuration wizard manually
cd ~/.local/share/chezmoi
poetry install
poetry run python3 scripts/configure.py

# Or via Make
make prep
```

## Security Considerations

1. **Secret scanning**: Gitleaks runs on pre-commit and in CI
2. **File permissions**: Sensitive files use `private_` prefix (0600 permissions)
3. **No secrets in git**: Use templates + external config for sensitive data
4. **Config file security**: `configure.py` sets 0600 on generated config files
5. **Netrc credentials**: Stored in `~/.netrc` (not committed), referenced in templates
6. **Signed commits**: All commits GPG-signed via SSH for authenticity

## References

- **Chezmoi docs**: https://www.chezmoi.io/docs/
- **Homebrew**: https://brew.sh/
- **Starship prompt**: https://starship.rs/
- **Powerlevel10k**: https://github.com/romkatv/powerlevel10k
- **zplug**: https://github.com/zplug/zplug
- **Poetry**: https://python-poetry.org/

## Quick Start for New Agents

1. **Understand the context**: This is a chezmoi-managed dotfiles repo (not a typical app)
2. **Check what's installed**: Review `Brewfile` for available tools
3. **Read templates carefully**: Files with `.tmpl` use Go template syntax
4. **Respect naming conventions**: `dot_` prefix and `private_` prefix have special meaning
5. **Test in Docker**: Use `make debug` to test changes safely
6. **Use Poetry**: Python scripts require `poetry install` first
7. **Don't commit secrets**: Use templates and external config files
8. **Run pre-commit**: Always run `pre-commit run --all-files` before committing

## Common Tasks

### Add a new Homebrew package
```bash
# Edit Brewfile manually or:
brew install <package>
brew bundle dump --force --file=./Brewfile
git add Brewfile
git commit -m "chore: add <package> to Brewfile"
```

### Add a new zsh plugin
```bash
# Edit dot_zshrc.d/plugins.zsh
# Add line like: zplug "plugin/name", from:oh-my-zsh
# Apply changes
chezmoi apply
# Reload shell or run: zplug install && zplug load
```

### Add a new shell alias
```bash
# Edit dot_zshrc.d/aliases.zsh
# Add conditional check if needed:
if command -v tool &>/dev/null; then
  alias shortcut='long command'
fi
```

### Modify environment variables
```bash
# Edit dot_zshrc.d/env.zsh.tmpl
# Use templates if values should come from config:
export VAR_NAME="{{ .machine.section.value }}"
```

### Add a new bootstrap step
```bash
# Create run_once_before_NN-step-name.sh.tmpl
# Add #!/bin/bash header
# Add logic (will run once during chezmoi apply)
# Higher NN = runs later (00, 01, 02, etc.)
```

### Add a new fish shell function
```bash
# Edit dot_config/private_fish/functions/new_function.fish
# Create new file with function definition
# Fish auto-loads functions from this directory
# Apply changes
chezmoi apply
```

### Configure tmux
```bash
# Edit dot_tmux.conf
# Add new key bindings or settings
# Apply changes
chezmoi apply
# Reload tmux config
tmux source-file ~/.tmux.conf
# Or use the key binding: C-a r
```

### Add a fisher plugin (Fish shell)
```bash
# Edit dot_config/private_fish/fish_plugins
# Add plugin URL or name
# Apply changes
chezmoi apply
# In fish shell: fisher update
```
