#!/bin/bash
# e2e.sh - Assertion script for dotfiles bootstrap validation.
# Runs inside the test container after `dotfiles apply --non-interactive`.

set -euo pipefail

fail=0

assert() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    printf 'PASS: %s\n' "$desc"
  else
    printf 'FAIL: %s\n' "$desc"
    fail=1
  fi
}

echo "==> Config"
assert "chezmoi config exists"     test -f ~/.config/chezmoi/chezmoi.toml
assert "chezmoi config is valid"   chezmoi cat-config

echo "==> Dotfiles"
assert "~/.gitconfig exists"                    test -f ~/.gitconfig
assert "~/.config/fish/config.fish exists"      test -f ~/.config/fish/config.fish
assert "~/.tmux.conf exists"                    test -f ~/.tmux.conf
assert "~/.config/starship.toml exists"         test -f ~/.config/starship.toml
assert "~/.zshrc exists"                        test -f ~/.zshrc
assert "~/.config/ghostty/config.ghostty exists" test -f ~/.config/ghostty/config.ghostty

echo "==> Packages"
assert "git is installed"     command -v git
assert "fish is installed"    command -v fish
assert "chezmoi is installed" command -v chezmoi
assert "curl is installed"    command -v curl
assert "zsh is installed"     command -v zsh
assert "tmux is installed"    command -v tmux
assert "fzf is installed"     command -v fzf
assert "starship is installed" command -v starship

exit "$fail"
