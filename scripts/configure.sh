#!/bin/bash

# (c) 2024 lvlcn-t - configure.sh
# This script is used to configure the chezmoi configurations
# If terminated, the script will not make any changes to the configurations

CONFIG_DIR="$HOME/.config/chezmoi"
TEMPLATE_DIR="$HOME/.local/share/chezmoi"
CONFIG_FILE="$CONFIG_DIR/chezmoi.toml"
TEMPLATE_FILE="$TEMPLATE_DIR/chezmoi.toml"

# initialize_config copies the template configuration file if it does not exist
initialize_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Configuration file not found. Copying template..."
        cp "$TEMPLATE_FILE" "$CONFIG_FILE"
    fi
}

# ask_yes_no asks the user for a yes or no answer and returns 0 or 1
ask_yes_no() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
        [Yy]*) return 0 ;;
        [Nn]*) return 1 ;;
        *) echo "Please answer yes or no." ;;
        esac
    done
}

# ask_value asks the user for a value and returns it
ask_value() {
    read -p "$1: " value
    echo "$value"
}

initialize_config

temp_file=$(mktemp)

echo "[data.netrc]" >"$temp_file"
if ask_yes_no "Do you want to configure netrc machines?"; then
    while true; do
        echo "[[data.netrc.machines]]" >>"$temp_file"
        url=$(ask_value "Enter URL")
        username=$(ask_value "Enter Username")
        token=$(ask_value "Enter Token")
        echo "url = \"$url\"" >>"$temp_file"
        echo "username = \"$username\"" >>"$temp_file"
        echo "token = \"$token\"" >>"$temp_file"

        if ! ask_yes_no "Do you want to add another netrc machine?"; then
            break
        fi
    done
fi

echo "[data.machine.proxy]" >>"$temp_file"
if ask_yes_no "Enable proxy?"; then
    enabled=true
    http=$(ask_value "HTTP Proxy")
    https=$(ask_value "HTTPS Proxy")
    noProxy=$(ask_value "No Proxy")
else
    enabled=false
    http=""
    https=""
    noProxy=""
fi
echo "enabled = $enabled" >>"$temp_file"
echo "http = \"$http\"" >>"$temp_file"
echo "https = \"$https\"" >>"$temp_file"
echo "noProxy = \"$noProxy\"" >>"$temp_file"

# ask_packages asks the user for a yes or no answer for each package
ask_packages() {
    package_section=$1
    shift
    echo "[$package_section]" >>"$temp_file"
    for package in "$@"; do
        if ask_yes_no "Do you want to install $package?"; then
            echo "$package = true" >>"$temp_file"
        else
            echo "$package = false" >>"$temp_file"
        fi
    done
}

ask_packages "data.machine.packages.languages" "go" "python" "rust" "node"
ask_packages "data.machine.packages.devops" "docker" "kubernetes"
ask_packages "data.machine.packages.cloud" "aws" "azure" "gcp"
ask_packages "data.machine.packages.tools" "ytdlp" "ffmpeg"
ask_packages "data.machine.packages.editors" "nvim"
ask_packages "data.machine.packages.browsers" "firefox" "chromium"

mv "$temp_file" "$CONFIG_FILE"

echo "Configuration updated successfully!"
