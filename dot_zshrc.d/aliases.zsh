# ~/.zshrc.d/aliases.zsh
# Aliases Module - Contains all command shortcuts and aliases

# Brew alias (only if brew is available)
if command -v brew &>/dev/null; then
  alias du-brew='du -sch $(brew --cellar)/*/* | sed "s|$(brew --cellar)/\([^/]*\)/.*|\1|" | sort -k1h'
fi

# WSL specific aliases to handle Windows paths and user information
if command -v wslinfo &>/dev/null && command -v powershell.exe &>/dev/null; then
  export WINDOWS_USER="$(powershell.exe -Command "[System.Security.Principal.WindowsIdentity]::GetCurrent().Name" | awk -F'\\\\' '{print $2}' | tr -d '\r')"
  export WINDOWS_HOME="/mnt/c/Users/$WINDOWS_USER"

  alias whoami-wsl="echo $WINDOWS_USER"
  alias cdw="cd \"$WINDOWS_HOME\""
  alias docs="cd \"$WINDOWS_HOME/docs/internal\""
fi

# eza is a command line tool for file management: https://github.com/eza-community/eza
if command -v eza &>/dev/null; then
  alias ls='eza'
  alias ll='eza -lah --icons'
  __auto_tree() {
    local dir="${1:-.}"
    if git rev-parse --is-inside-work-tree &>/dev/null; then
      eza --tree --icons --git "$dir"
    else
      eza --tree --icons -a "$dir"
    fi
  }
  alias tree='__auto_tree'
fi

# Git-town aliases for streamlined git workflows
if command -v git-town &>/dev/null; then
  alias gt="git town"
  alias gts="git town sync"
  alias gtb="git town branch"
  alias gtsw="git town switch"
fi

# docker is a containerization platform: https://www.docker.com/
if command -v docker &>/dev/null; then
  # dive is a tool for exploring a docker image: https://github.com/wagoodman/dive
  alias dive="docker run -ti --rm  -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive"

  # jaeger is a distributed tracing platform: https://www.jaegertracing.io/
  alias jaeger="docker run -d --name jaeger \
  -e COLLECTOR_OTLP_ENABLED=true \
  -e COLLECTOR_ZIPKIN_HOST_PORT=:9411 \
  -p 5775:5775/udp \
  -p 6831:6831/udp \
  -p 6832:6832/udp \
  -p 5778:5778 \
  -p 16686:16686 \
  -p 14250:14250 \
  -p 14268:14268 \
  -p 14269:14269 \
  -p 4317:4317 \
  -p 4318:4318 \
  -p 9411:9411 \
  jaegertracing/all-in-one:1.60"
fi

plugins=(kubectl-ctx kubectl-ns)
for plugin in "${plugins[@]}"; do
  if command -v "$plugin" &>/dev/null; then
    name="${plugin#kubectl-}"
    alias "$name"="$plugin"
  fi
done

# GitHub CLI alias for Copilot
if command -v gh &>/dev/null; then
  alias ghc='gh copilot'
fi

# GitLab CLI alias for skipping CI in git commands
if command -v glab &>/dev/null; then
  alias gpsci='git push -o ci.skip'
  __glab_clone() { glab repo clone -g "$1" -a=false -p --paginate "${@:2}"; }
  alias glab-clone='__glab_clone'
fi

# GitLab CI local alias
if command -v gitlab-ci-local &>/dev/null; then
  alias gci='gitlab-ci-local'
fi

# yt-dlp alias for extracting mp3 from videos
if command -v yt-dlp &>/dev/null; then
  alias yt-mp3='yt-dlp -x --audio-format mp3'
fi
