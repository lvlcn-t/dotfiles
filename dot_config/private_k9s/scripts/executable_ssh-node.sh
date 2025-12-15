#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/k9s"
LOG_FILE="$LOG_DIR/ssh-node.log"
mkdir -p "$LOG_DIR"

ts() { date -Is; }
log() { printf '%s %s\n' "$(ts)" "$*" >>"$LOG_FILE"; }

exec 2> >(while IFS= read -r line; do log "ERR: $line"; done)

CTX="${1:?usage: ssh-node.sh <context> <node-name>}"
NODE_NAME="${2:?usage: ssh-node.sh <context> <node-name>}"
SSH_HOST="jump"

log "checking ssh config for host '$SSH_HOST'..."
if ! ssh -G "$SSH_HOST" >/dev/null 2>&1; then
	log "FATAL: ssh config has no Host entry for '$SSH_HOST'"
	cat >&2 <<EOF
Missing SSH host configuration.

Expected an entry like this in ~/.ssh/config (or an included file):

Host $SSH_HOST
  HostName <jump-host>
  User <user>
  IdentityFile ~/.ssh/id_ecdsa.ansible_admin
  ForwardAgent no

Aborting.
EOF
	exit 1
fi

log "----"
log "start pid=$$ user=$(id -un) cwd=$PWD"
log "ctx=$CTX node=$NODE_NAME"
log "PATH=$PATH"
log "KUBECONFIG=${KUBECONFIG:-}"
log "SSH_HOST=$SSH_HOST"

# Resolve node IP
log "resolving InternalIP via kubectl..."
ip="$(kubectl --context "$CTX" get node "$NODE_NAME" \
	-o jsonpath='{range .status.addresses[?(@.type=="InternalIP")]}{.address}{"\n"}{end}{.status.addresses[0].address}' |
	awk 'NF{print;exit}' || true)"

log "resolved ip (first pass)='$ip'"

if [[ -z "$ip" ]]; then
	log "fallback to first address..."
	ip="$(kubectl --context "$CTX" get node "$NODE_NAME" -o jsonpath='{.status.addresses[0].address}' 2>/dev/null | awk 'NF{print;exit}' || true)"
	log "resolved ip (fallback)='$ip'"
fi

if [[ -z "$ip" ]]; then
	log "FATAL: failed to resolve IP"
	echo "Failed to resolve IP for node: $NODE_NAME (context: $CTX)" >&2
	exit 1
fi

# Build remote command (keep it as one string so it’s easy to see in logs)
remote_cmd="ssh-keygen -R '$ip' >/dev/null 2>&1 || true; ssh -i ~/.ssh/id_ecdsa.ansible_admin -o StrictHostKeyChecking=no ansible_admin@$ip"
log "remote_cmd=$remote_cmd"

log "executing: ssh -tt -o StrictHostKeyChecking=no jump <remote_cmd>"
log "log_file=$LOG_FILE"

exec ssh -tt -o StrictHostKeyChecking=no jump "$remote_cmd"
