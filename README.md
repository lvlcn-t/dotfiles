# dotfiles 🛠️

One command gives you a fully configured development machine — Fish
shell with smart completions, Git with SSH-signed commits and
per-host identity, Neovim, Kubernetes tooling (kubectl, helm, k9s,
argocd), cloud CLIs, AeroSpace tiling on macOS, Ghostty terminal,
and ~65 Homebrew packages. Works on Linux/WSL (Ubuntu) and macOS.

## Quick start

> [!WARNING]
> This will overwrite existing config files. Back up your dotfiles
> first.

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lvlcn-t
```

This configures passwordless `sudo` for your user, installs all
packages, and sets up the shell. Afterwards, a wizard asks for Git
tokens and optional proxy settings:

You can retrigger the wizard anytime by running:

```bash
uv run python3 scripts/configure.py
```

## What you get

- **Shell**: Fish (primary) with fzf, Zoxide, starship prompt; Zsh as
  fallback with Powerlevel10k; Passwordless `sudo` setup for convenience
- **Git**: SSH signing, auto-signoff, difftastic diffs, separate
  identities for GitHub / GitLab / work
- **Editor**: Neovim ([kickstart.nvim][nvim] config, pulled
  automatically)
- **Terminal**: [Ghostty][ghostty] config, tmux with `C-a` prefix
- **macOS**: [AeroSpace][aerospace] tiling window manager
- **Kubernetes**: k9s with custom aliases and plugins
- **AI**: [opencode][opencode] assistant with MCP servers and custom
  agents ([lvlcn-t/agents][agents])
- **VS Code**: Dozens of extensions bundled in
  [`Brewfile.vscode`][brewfile-vscode]

## Day-to-day commands

| Command        | What it does                                         |
| -------------- | ---------------------------------------------------- |
| `make install` | Fresh apply (wipes state, re-runs bootstrap scripts) |
| `make debug`   | Test the full bootstrap in Docker                    |
| `make bundle`  | Snapshot current brew/vscode packages into Brewfiles |

## Configuration

The wizard writes `~/.config/chezmoi/chezmoi.toml`. Key settings:

| Variable                | Purpose                          |
| ----------------------- | -------------------------------- |
| `machine.proxy.enabled` | Toggle proxy in npmrc/wgetrc/env |
| `machine.proxy.http`    | HTTP proxy URL                   |
| `netrc.github_token`    | GitHub PAT for private repos     |
| `netrc.gitlab_token`    | GitLab PAT for private repos     |

## Gotchas

Things that break silently or look like bugs but aren't:

| Trap                              | Fix                                                                    |
| --------------------------------- | ---------------------------------------------------------------------- |
| Bootstrap scripts won't re-run    | `make install` (wipes chezmoi state)                                   |
| `GH_TOKEN` set in env             | Breaks `gh copilot`. Keep it commented in `env.zsh.tmpl`               |
| Zsh keybindings don't work        | `history-substring-search` needs `defer:3` (after syntax-highlighting) |
| Config wizard keeps triggering    | Intentional — it deletes config when identical to template             |
| Neovim/agents missing after apply | Network required — `.chezmoiexternal.toml` pulls them at apply time    |

## See also

- [AGENTS.md](AGENTS.md) — repo internals, code style, CI
- [chezmoi documentation][chezmoi]

[chezmoi]: https://www.chezmoi.io/
[nvim]: https://github.com/lvlcn-t/kickstart.nvim
[ghostty]: https://ghostty.org/
[aerospace]: https://github.com/nikitabobko/AeroSpace
[opencode]: https://opencode.ai
[agents]: https://github.com/lvlcn-t/agents
[brewfile-vscode]: ./Brewfile.vscode
