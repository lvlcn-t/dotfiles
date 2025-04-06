# ~/.zshrc.d/env.zsh
# Environment Module - Sets up locale, history, profiles, and development tool configurations

# Parse the .netrc file to extract credentials for a specific host.
# Args:
#   netrc: Path to the .netrc file.
#   searched_host: The host to search for in the .netrc file.
# Returns:
#   host: The host found in the .netrc file.
#   user: The username associated with the host.
#   token: The token associated with the host.
# If the host is not found, it returns 1.
function __parse_netrc() {
  local netrc="$1"
  local searched_host="$2"

  local host user token
  while IFS= read -r line; do
    case $line in
    machine*)
      host=$(echo "$line" | awk '{print $2}')
      ;;
    *login*)
      user=$(echo "$line" | awk '{print $2}')
      ;;
    *password*)
      token=$(echo "$line" | awk '{print $2}')
      if [[ $host == *"$searched_host"* ]]; then
        echo "$host $user $token"
        return
      fi
      ;;
    esac
  done <"$netrc"
  # This should only happen if the searched host is not
  # found or the .netrc file is malformed
  return 1
}

# Set GitHub environment variables from the .netrc file.
# Args:
#   netrc: Path to the .netrc file.
# Returns:
#   0 if successful, 1 if the .netrc file is not found, malformed,
#   or if the host is not found.
# Exports:
#   GH_HOST: The GitHub host URL.
#   GH_USER: The GitHub username.
#   GH_TOKEN: The GitHub token.
function __set_github_env() {
  local netrc="$1"

  if [[ -f "$netrc" ]]; then
    read -r host user token < <(__parse_netrc "$netrc" "github.com")
    # TODO: Investigate why gh auth login fails when we set $GH_HOST here
    # export GH_HOST="https://$host"
    export GH_USER="$user"
    export GH_TOKEN="$token"
  else
    echo 'No .netrc file found at $(realpath "$netrc"). Please create one with your GitHub credentials.'
    return 1
  fi
}

# Log in to GitHub CLI if not already logged in
# Returns:
#   0 if successful,
#   1 if the user is not logged in or the GH_TOKEN environment variable
#   is not set to be able to log in.
function __gh_login() {
  if gh auth status &>/dev/null; then
    return 0
  fi

  local token="$GH_TOKEN"
  if [[ -z "$token" ]]; then
    echo <<EOF
You are not logged in to GitHub nor have the \$GH_TOKEN environment variable set.
Please run 'gh auth login' to authenticate or set the \$GH_TOKEN environment variable.
EOF
    return 1
  fi

  echo "Logging in to GitHub CLI..."
  gh auth login --with-token <<<"$token" || {
    echo "Failed to log in to GitHub CLI. Please check your credentials."
    return 1
  }
}

# Set GitLab environment variables from the .netrc file.
# Args:
#   netrc: Path to the .netrc file.
# Returns:
#   0 if successful, 1 if the .netrc file is not found, malformed,
#   or if the host is not found.
# Exports:
#   GITLAB_HOST: The GitLab host URL.
#   GITLAB_USER: The GitLab username.
#   GITLAB_TOKEN: The GitLab token.
#   GITLAB_API_TOKEN: The GitLab API token.
function __set_gitlab_env() {
  local netrc="$1"

  if [[ -f "$netrc" ]]; then
    read -r host user token < <(__parse_netrc "$netrc" "gitlab.devops.telekom.de")
    export GITLAB_HOST="https://$host"
    export GITLAB_USER="$user"
    export GITLAB_TOKEN="$token"
    export GITLAB_API_TOKEN="$token"
  else
    echo 'No .netrc file found at $(realpath "$netrc"). Please create one with your GitLab credentials.'
    return 1
  fi
}

# Set locale and load user-defined environment variables
export LANG=C.UTF-8
sourceIfExists "$HOME/.env"
sourceIfExists "$HOME/.zshrc.d/.zshenv"

export PATH=$HOME/bin:/usr/local/bin:$PATH

# History configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Load the default .profile if it exists
[[ -e "$HOME/.profile" ]] && emulate sh -c 'source "$HOME/.profile"'

# Cargo environment for Rust
sourceIfExists "$HOME/.cargo/env"

if command -v gh &>/dev/null; then
  __set_github_env "$HOME/.netrc" || {
    echo "Failed to set GitHub environment variables. Please check your .netrc file."
  }
  __gh_login || {
    echo "Failed to log in to GitHub CLI. Please check your credentials."
  }
fi

if command -v glab &>/dev/null; then
  __set_gitlab_env "$HOME/.netrc" || {
    echo "Failed to set GitLab environment variables. Please check your .netrc file."
  }
fi

if command -v gitlab-ci-local &>/dev/null; then
  export GCL_NEEDS='true'
  # export GCL_FILE='.gitlab-ci-local.yml'
  # export GCL_VARIABLE="IMAGE=alpine:latest"
fi

# Go language settings
if command -v go &>/dev/null; then
  export PATH="$PATH:$HOME/go/bin"
  export GOPRIVATE=gitlab.devops.telekom.de
  export GO111MODULE=on
fi

# pnpm setup
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

if command -v kubectl-krew &>/dev/null; then
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
fi

# Disable telemetry for the Azure Developer CLI
if command -v azd &>/dev/null; then
  export AZURE_DEV_COLLECT_TELEMETRY="no"
fi

# Disable telemetry for the Azure Functions Core Tools
if command -v func &>/dev/null; then
  export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT="true"
fi

# Unset all internal functions to unpollute the environment.
unset -f __parse_netrc
unset -f __set_github_env
unset -f __gh_login
unset -f __set_gitlab_env
