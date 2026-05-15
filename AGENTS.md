# AGENTS.md

Dotfiles repository managed by [chezmoi](https://www.chezmoi.io/). Bootstraps
a development environment on Linux/WSL via templated config, Homebrew, and
bootstrap scripts.

## Commands

```bash
make install       # clean-state + chezmoi apply (WARNING: deletes state buckets first)
make clean-state   # delete chezmoi entryState + scriptState buckets
make bundle        # dump current brew packages into Brewfile + Brewfile.vscode
make image         # build Docker test image
make debug         # build image + run chezmoi apply in container interactively
```

### Python

The project uses `uv` (see `uv.lock`). Python ≥ 3.14 required.

```bash
uv sync                          # install deps
uv run ruff check                # lint
uv run ruff format               # format
uv run pytest                    # tests (none exist yet)
```

### Pre-commit

```bash
pre-commit install
pre-commit run --all-files       # gitleaks only
```

CI: gitleaks SAST on every push (`.github/workflows/`).

## Repository structure

```text
dot_*                             → ~/.* after chezmoi apply
dot_config/                       → ~/.config/
dot_zshrc.d/                      → ~/.zshrc.d/ (aliases, env, keybindings, plugins)
*.tmpl                            → Go-templated before writing
private_*                         → written with 0600 permissions
run_once_before_NN-*.sh.tmpl      → bootstrap scripts, run once in order (00→01→02)
scripts/configure.py              → interactive chezmoi.toml wizard
config/chezmoi.toml               → config template
Brewfile                          → Homebrew package list
```

## Chezmoi templates

Variables come from `~/.config/chezmoi/chezmoi.toml`:

```text
{{ .chezmoi.sourceDir }}
{{ .machine.proxy.enabled }}
{{- if .machine.proxy.enabled }}...{{- end }}
```

The wizard (`scripts/configure.py`) deletes the active config when identical
to the template, forcing re-configuration on next apply.

## Python code style

- Python 3.14+; type hints on all signatures
- `tomllib` (stdlib) to read TOML, `toml` package to write
- Google-style docstrings; emoji prefix on user-facing strings
- No bare `except`; `0600` on credential files

## Shell script style

- Private helpers: `__double_underscore` prefix; `unset -f` at end of file
- Guard on availability: `if command -v tool &>/dev/null; then`
- Safe sourcing: `sourceIfExists "$file"`
- Plugin order: `zsh-history-substring-search` must load after
  `zsh-syntax-highlighting` (`defer:3` in `plugins.zsh`)

## Git conventions

- SSH-signed commits + `Signed-off-by` — never use `--no-verify` or
  `--no-gpg-sign`
- Conventional Commits (`feat:`, `fix:`, `chore:`)
- `GH_TOKEN` intentionally commented out in `env.zsh.tmpl` — conflicts
  with `gh copilot`

## Security

- No secrets in source — use `*.tmpl` + chezmoi.toml for credentials
- `private_` prefix → 0600 permissions
- Gitleaks on pre-commit and CI; run before every commit

## Critical gotchas

| Issue                      | Detail                                                           |
| -------------------------- | ---------------------------------------------------------------- |
| `make install`             | Deletes all chezmoi state first — re-runs all `run_once` scripts |
| `run_once_before_*` re-run | Use `chezmoi state delete-bucket` to force re-execution          |
| Docker Homebrew path       | Hardcoded `/home/linuxbrew/.linuxbrew/bin/brew` — Linux only     |
| Config wizard trigger      | Wizard deletes active config when identical to template          |
| Plugin defer order         | `zsh-history-substring-search` needs `defer:3`                   |
