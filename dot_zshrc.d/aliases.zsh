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

# fastfetch is a fast and minimal system information tool: https://github.com/fastfetch-cli/fastfetch
if command -v fastfetch &>/dev/null; then
  alias neofetch='fastfetch'
fi

if command -v git &>/dev/null; then
  alias gcs="git commit --signoff"
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

# Set up aliases for kubectl plugins
plugins=(kubectl-ctx kubectl-ns)
for plugin in "${plugins[@]}"; do
  if command -v "$plugin" &>/dev/null; then
    name="${plugin#kubectl-}"
    alias "$name"="$plugin"
  fi
done

if command -v argocd &>/dev/null; then
  # Log in to ArgoCD using the provided context.
  # Args:
  #   context: The kubectl context to use. Must be provided.
  # Returns:
  #   0 if successful, 1 if the context is not provided or the port-forwarding fails.
  argocd-login() {
    local ctx="$1"
    local ns="argocd"
    local svc="argo-cd-upstream-argocd-server"
    local port_file="/tmp/argocd-port-$ctx"
    local port password

    if [[ "$ctx" =~ ^(-h|--help)$ ]]; then
      cat <<EOF
Usage: argocd-login <context>
Logs into ArgoCD in the given context, auto-port-forwarding
to a private port per context.

Args:
  context: The kubectl context to use. Must be provided.
Returns:
  0 if successful, 1 if the context is not provided or the port-forwarding fails.
EOF
      return 0
    fi

    if [[ -z "$ctx" ]]; then
      echo "Error: no context provided."
      return 1
    fi

    [[ -f "$port_file" ]] && port=$(<"$port_file")

    if [[ -z "$port" ]] || ! bash -c ">/dev/tcp/localhost/$port" &>/dev/null; then
      for p in {10240..11240}; do
        if ! bash -c ">/dev/tcp/localhost/$p" &>/dev/null; then
          port=$p
          break
        fi
      done

      if [[ -z "$port" ]]; then
        echo "Error: no free port found."
        return 1
      fi

      echo "$port" >"$port_file"
      echo "→ Port-forwarding $svc in '$ctx' to localhost:$port…"
      kubectl --context "$ctx" -n "$ns" port-forward svc/"$svc" "$port":443 &>/dev/null &
      sleep 1
    else
      echo "→ Reusing existing localhost:$port for context '$ctx'."
    fi

    password=$(kubectl get secret argocd-initial-admin-secret \
      --context "$ctx" -n "$ns" \
      -o jsonpath="{.data.password}" | base64 -d)

    argocd login "localhost:$port" \
      --username admin \
      --password "$password" \
      --plaintext
  }

  # Autocomplete for argocd-login
  __argocd_contexts() {
    local contexts
    IFS=$'\n' contexts=($(kubectl config get-contexts -o=name 2>/dev/null))
    compadd -- "${contexts[@]}"
  }

  compdef __argocd_contexts argocd-login
fi

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

# Log in to Conjur using the provided host and token.
# Args:
#   host: The host to log in to. If not provided, it defaults to the value of $CONJUR_AUTHN_LOGIN_HOST.
#   token: The token to use for authentication. If not provided, the token will be read from stdin.
# Returns:
#   0 if successful, 1 if the host is not provided or the token is not valid.
# Exports:
#   CONJUR_AUTHN_LOGIN_HOST: The Conjur host URL.
#   CONJUR_AUTHN_API_KEY: The Conjur API key.
__conjur_login() {
  local host=${1:-$CONJUR_AUTHN_LOGIN_HOST}
  local token=$2

  if [[ "$1" == "--help" || "$1" == "-h" || -z "$host" ]]; then
    cat <<EOF

Usage: conjur_login [host] [token]

Logs into conjur using the provided host and token.

Args:
  host: The host to login to. If not provided, it defaults to '$CONJUR_AUTHN_LOGIN_HOST'.
  token: The token to use for authentication. If not provided, the token will be read from stdin.

EOF
    return 0
  fi

  if [ -z "$token" ]; then
    echo -n "Enter Conjur authentication token: "
    read -s token
    echo
  fi

  if [[ "$host" == "$CONJUR_SNS"* ]]; then
    host="${host#$CONJUR_SNS/}"
  fi

  unset -v CONJUR_AUTHN_LOGIN_HOST CONJUR_AUTHN_API_KEY
  export CONJUR_AUTHN_LOGIN_HOST="$CONJUR_SNS/$host"
  export CONJUR_AUTHN_API_KEY="$token"
  rm "$CONJUR_AUTHN_TOKEN_FILE" || true
  echo "Logged into Conjur host '$host'"
}

# Aliases for the conjur-utils CLI
if [[ -d "$HOME/.local/share/conjur-utils" ]]; then
  alias conjur-login="__conjur_login"
fi
