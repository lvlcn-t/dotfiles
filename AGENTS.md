# AGENTS.md

Dotfiles repository managed by [chezmoi](https://www.chezmoi.io/). It bootstraps
a consistent development environment on Linux/WSL machines via templated config
files, Homebrew, and bootstrap scripts.

## Build, lint, and test commands

```bash
# Install Python deps and run config wizard
make prep                        # = poetry install && poetry run python3 scripts/configure.py

# Apply dotfiles to the live system
make install                     # = poetry install + chezmoi apply

# Test a full bootstrap in Docker (Ubuntu 24.04)
make debug

# Bump Homebrew deps and open PR
make bump-deps
```

### Python toolchain

```bash
poetry install                   # install dev deps (pytest, ruff, toml)

poetry run pytest                # run all tests
poetry run pytest tests/test_configure.py::test_load_config   # run a single test
poetry run ruff check            # lint
poetry run ruff format           # format
```

### Pre-commit / CI

```bash
pre-commit install               # wire hooks
pre-commit run --all-files       # run gitleaks on every file
pre-commit run gitleaks --all-files   # run gitleaks only
```

CI runs gitleaks SAST on every push (`.github/workflows/test_sast.yml`).

### Chezmoi operations

```bash
chezmoi diff                     # preview changes
chezmoi apply                    # apply to system
chezmoi apply --verbose          # verbose apply
chezmoi edit ~/.zshrc            # edit a managed file (opens VSCode)
```

## Repository structure

```
dot_*               →  ~/.* after chezmoi apply  (dot_zshrc → ~/.zshrc)
dot_config/         →  ~/.config/
dot_zshrc.d/        →  ~/.zshrc.d/  (aliases.zsh, env.zsh.tmpl, keybindings.zsh, plugins.zsh)
*.tmpl              →  processed as Go template before writing
private_*           →  written with 0600 permissions
run_once_before_NN-*.sh.tmpl  →  bootstrap scripts, run once in order (00→01→02)
scripts/configure.py           →  interactive chezmoi.toml wizard
config/chezmoi.toml            →  config template (copied to ~/.config/chezmoi/chezmoi.toml)
Brewfile                       →  Homebrew package list
```

## Chezmoi template conventions

Templates use Go template syntax. Variables come from `~/.config/chezmoi/chezmoi.toml`.

```
{{ .chezmoi.sourceDir }}          source directory
{{ .machine.proxy.enabled }}      custom data key
{{- if .machine.proxy.enabled }}  trim whitespace with -
{{- end }}
```

The active config lives at `~/.config/chezmoi/chezmoi.toml`; the template lives at
`config/chezmoi.toml` in this repo. The bootstrap wizard removes the active file
when it is identical to the template, forcing re-configuration on next apply.

## Python code style

- **Version**: Python 3.14+; `requires-python = ">=3.14"` in `pyproject.toml`
- **Type hints**: required on all function signatures — `def foo(x: str) -> int:`
- **Imports**: stdlib first, then third-party; `from __future__ import annotations`
  at top of every file
- **TOML I/O**: `tomllib` (stdlib) to read, `toml` package to write
- **Docstrings**: Google style — one-liner summary, then `Args:` / `Returns:` blocks
- **User-facing strings**: emoji prefix (🚀 ✅ ❌ ⚠️ 🔐 🌐 etc.)
- **Classes**: PascalCase; **functions/variables**: snake_case
- **Constants**: SCREAMING_SNAKE_CASE at module level
- **No bare `except`**: always catch a specific exception type
- **File permissions**: set `0600` on any file that holds credentials

Example function signature:

```python
def configure_section(config: dict[str, Any]) -> dict[str, Any]:
    """Update or preserve a configuration section.

    Args:
        config: The current configuration dictionary.

    Returns:
        The updated configuration dictionary.
    """
```

## Shell script style

- **Public functions**: `snake-case` or `snake_case` (e.g., `argocd-login`)
- **Private helpers**: `__double_underscore` prefix; `unset -f __name` at end of file
- **Guard aliases on availability**: `if command -v tool &>/dev/null; then`
- **Safe sourcing**: use `sourceIfExists "$file"` instead of bare `source`
- **Plugin load order**: `zsh-history-substring-search` must load after
  `zsh-syntax-highlighting` (`defer:3` in `plugins.zsh`)
- **Profiling**: `PROFILING=1 zsh` enables `zprof` output

Document functions with:

```bash
# Brief description
# Args:
#   arg1: Description
# Returns:
#   0 on success, 1 on error
function_name() { ... }
```

## Git conventions

- All commits are **SSH-signed** (`commit.gpgsign = true`) and include
  `Signed-off-by` (`format.signoff = true`) — do not use `--no-verify` or
  `--no-gpg-sign`.
- Commit messages follow **Conventional Commits** (`feat:`, `fix:`, `chore:`, etc.).
- Context-aware git identity: `github.com` → `.gitconfig-personal`;
  `gitlab.devops.telekom.de` → `.gitconfig-work`.
- `GH_TOKEN` is **intentionally commented out** in `env.zsh.tmpl` — it conflicts
  with GitHub Copilot CLI.

## Security rules

- **No secrets in source**: use `*.tmpl` + `~/.config/chezmoi/chezmoi.toml` for
  credentials; never hardcode tokens.
- **Sensitive files**: use `private_` prefix so chezmoi sets `0600` permissions.
- **Gitleaks** runs on pre-commit and in CI — all commits are scanned.
- Run `pre-commit run --all-files` before every commit.

## Critical gotchas

| Issue                        | Detail                                                                                           |
| ---------------------------- | ------------------------------------------------------------------------------------------------ |
| `run_once_before_*` scripts  | Chezmoi tracks execution state; to re-run, delete the state or use `chezmoi state delete-bucket` |
| Docker Homebrew path         | Hardcoded to `/home/linuxbrew/.linuxbrew/bin/brew` — Linux only                                  |
| Config wizard re-run trigger | Wizard deletes active config when identical to template, forcing re-config                       |
| `GH_TOKEN` conflict          | Must stay commented in `env.zsh.tmpl`; breaks `gh copilot` if set                                |
| Plugin defer order           | `zsh-history-substring-search` needs `defer:3` (after syntax-highlighting)                       |

## See also

### Chezmoi documentation

| Topic                                                        | URL                                                                           |
| ------------------------------------------------------------ | ----------------------------------------------------------------------------- |
| Quick start                                                  | https://www.chezmoi.io/quick-start/                                           |
| Daily operations                                             | https://www.chezmoi.io/user-guide/daily-operations/                           |
| Manage different file types                                  | https://www.chezmoi.io/user-guide/manage-different-types-of-file/             |
| Machine-to-machine differences                               | https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/      |
| Templating guide                                             | https://www.chezmoi.io/user-guide/templating/                                 |
| Use scripts to perform actions                               | https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/             |
| Include files from elsewhere (`.chezmoiexternal`)            | https://www.chezmoi.io/user-guide/include-files-from-elsewhere/               |
| Source state attributes (`dot_`, `private_`, `run_once_`, …) | https://www.chezmoi.io/reference/source-state-attributes/                     |
| Configuration file reference                                 | https://www.chezmoi.io/reference/configuration-file/                          |
| Template variables                                           | https://www.chezmoi.io/reference/templates/variables/                         |
| Template functions                                           | https://www.chezmoi.io/reference/templates/functions/                         |
| Special files (`.chezmoiignore`, `.chezmoiexternal`, …)      | https://www.chezmoi.io/reference/special-files/                               |
| `chezmoi apply` reference                                    | https://www.chezmoi.io/reference/commands/apply/                              |
| `chezmoi state` reference                                    | https://www.chezmoi.io/reference/commands/state/                              |
| Linux machine setup                                          | https://www.chezmoi.io/user-guide/machines/linux/                             |
| Containers and VMs                                           | https://www.chezmoi.io/user-guide/machines/containers-and-vms/                |
| Troubleshooting FAQ                                          | https://www.chezmoi.io/user-guide/frequently-asked-questions/troubleshooting/ |
