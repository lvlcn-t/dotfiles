# ~/.zshrc.d/plugins.zsh
# Plugins & Completions Module - Setup and load plugins using zplug, and configure completions

# Load zplug if available
sourceIfExists "$HOME/.zplug/init.zsh"
if ! command -v zplug &>/dev/null; then
  echo "zplug not found. Installing zplug..."
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
  sourceIfExists "$HOME/.zplug/init.zsh"
fi

# Starship is a cross-shell prompt that can be used with zsh.
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
# Powerlevel10k Configuration - https://github.com/romkatv/powerlevel10k
# This will be used as fallback if starship is not available
else
  sourceIfExists "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$(whoami).zsh"
  # Customized prompt - run `p10k configure`, or edit ~/.p10k.zsh to change it
  sourceIfExists "$HOME/.p10k.zsh"
  zplug "romkatv/powerlevel10k", as:theme, depth:1
fi

if command -v direnv &>/dev/null; then
  zplug "plugins/direnv", from:oh-my-zsh
else
  zplug "plugins/dotenv", from:oh-my-zsh
fi

# Declare plugins with zplug
zplug "plugins/brew", from:oh-my-zsh
zplug "plugins/autojump", from:oh-my-zsh
zplug "plugins/command-not-found", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/jsontools", from:oh-my-zsh, defer:1
zplug "reegnz/jq-zsh-plugin", defer:1
zplug "plugins/vscode", from:oh-my-zsh, defer:1

zplug "plugins/pyenv", from:oh-my-zsh, defer:1
zplug "plugins/nvm", from:oh-my-zsh, defer:1

zplug "plugins/docker", from:oh-my-zsh, defer:1
zplug "plugins/docker-compose", from:oh-my-zsh, defer:1

zplug "plugins/kubectl", from:oh-my-zsh
zplug "plugins/argocd", from:oh-my-zsh
zplug "plugins/helm", from:oh-my-zsh, defer:1
zplug "plugins/kind", from:oh-my-zsh, defer:1

zplug "plugins/aws", from:oh-my-zsh, defer:1
zplug "plugins/azure", from:oh-my-zsh, defer:1
zplug "plugins/gcloud", from:oh-my-zsh, defer:1

zplug "plugins/gh", from:oh-my-zsh, defer:1
zplug "plugins/chezmoi", from:oh-my-zsh, defer:1

zplug "marlonrichert/zsh-autocomplete", depth:2
zplug "zsh-users/zsh-autosuggestions", defer:3
zplug "zsh-users/zsh-syntax-highlighting", defer:3
zplug "zsh-users/zsh-completions", defer:3
# Note: zsh-history-substring-search must be loaded after zsh-syntax-highlighting
zplug "zsh-users/zsh-history-substring-search", defer:4

# Check for missing plugins and prompt installation if needed
if ! zplug check --verbose; then
  printf "Install missing plugins? [y/N]: "
  if read -q; then
    echo
    zplug install
  fi
fi

zplug load

# Ensure several completions are available for common tools
mkdir -p "$HOME/.zsh/completions"
fpath=("$HOME/.zsh/completions" $fpath)
fpath+=("$HOME/.zfunc")
autoload -Uz compinit && compinit

# GitLab CLI (glab) completion
# TODO: Replace this with the plugins/glab oh-my-zsh plugin
# once it is available with https://github.com/ohmyzsh/ohmyzsh/issues/13054
if command -v glab &>/dev/null; then
  source <(glab completion -s zsh)
  compdef _glab glab
fi

# GitHub Copilot CLI (gh-copilot) completion
if ! gh extension list 2>&1 | grep -q "gh-copilot"; then
  echo "Installing GitHub Copilot CLI extension..."
  gh extension install github/copilot-cli
  eval "$(gh copilot alias -- zsh)"
else
  eval "$(gh copilot alias -- zsh)"
fi

# Azure Dev CLI (azd) completion
if command -v azd &>/dev/null; then
  source <(azd completion zsh)
fi

# Install Python using pyenv if not already installed.
# Args:
#   python_version: The version of Python to install.
# Returns:
#   0 if successful, 1 if pyenv is not found or the installation fails.
function __install_python() {
  local python_version="$1"
  if python3 --version | grep -q "$python_version" &>/dev/null; then
    return 0
  fi

  if ! command -v pyenv &>/dev/null; then
    echo "pyenv not found. Please install pyenv to install Python $python_version."
    return 1
  fi

  if ! pyenv versions --bare | grep -q "$python_version" &>/dev/null; then
    pyenv install -v "$python_version" || return 1
  fi

  pyenv global "$python_version" || return 1
}

__install_python "3.13" || {
  echo "Failed to install the latest Python version. Please check your pyenv installation."
}
unset -f __install_python
