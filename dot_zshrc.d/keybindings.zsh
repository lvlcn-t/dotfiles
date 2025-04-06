# ~/.zshrc.d/keybindings.zsh
# Keybindings Module - Configure keybindings and shell options

# Disable specific options for a cleaner prompt experience
unsetopt beep extendedglob nomatch

# Set Emacs keybindings (default for many users)
bindkey -e

# Custom keybindings for word navigation and editing
bindkey "^[[1;5C" forward-word  # Move forward one word (e.g., Option+Right Arrow)
bindkey "^[[1;5D" backward-word # Move backward one word (e.g., Option+Left Arrow)
bindkey "^H" backward-kill-word # Ctrl+H to kill the word behind the cursor
bindkey "5~" kill-word          # Kill word forward (if supported by your terminal)
bindkey "^[[3~" delete-char     # Delete the character under the cursor

# For zsh-history-substring-search to work, we need to change
# the key bindings for history substring search.
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
