if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source
source $HOME/.env.fish

bind tab complete-and-search
bind ctrl-j forward-char
bind ctrl-h backward-kill-path-component

set -g -x EDITOR nvim
set -g -x GOBIN $HOME/.local/bin

fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.local/go/bin
fish_add_path $HOME/.local/nvim/bin
fish_add_path $HOME/.local/krew/bin

alias fzfb="fzf_configure_bindings --help"
alias gcsm="git commit --signoff -m"
