#!/bin/sh
# Install script for dotfiles CLI.
# Usage: sh -c "$(curl -fsLS https://raw.githubusercontent.com/lvlcn-t/dotfiles/main/scripts/install.sh)"

set -e

REPO="lvlcn-t/dotfiles"
INSTALL_DIR="/usr/local/bin"
BINARY="dotfiles"

detect_os() {
  case "$(uname -s)" in
    Linux*)  echo "linux" ;;
    Darwin*) echo "darwin" ;;
    *)       echo "unsupported" ;;
  esac
}

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64)  echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    *)             echo "unsupported" ;;
  esac
}

main() {
  OS=$(detect_os)
  ARCH=$(detect_arch)

  if [ "$OS" = "unsupported" ] || [ "$ARCH" = "unsupported" ]; then
    echo "Error: unsupported platform $(uname -s)/$(uname -m)" >&2
    exit 1
  fi

  VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)
  if [ -z "$VERSION" ]; then
    echo "Error: could not determine latest version" >&2
    exit 1
  fi

  ARCHIVE="${BINARY}_${OS}_${ARCH}.tar.gz"
  URL="https://github.com/${REPO}/releases/download/${VERSION}/${ARCHIVE}"

  echo "Downloading ${BINARY} ${VERSION} for ${OS}/${ARCH}..."
  TMP=$(mktemp -d)
  curl -fsSL "$URL" -o "${TMP}/${ARCHIVE}"
  tar -xzf "${TMP}/${ARCHIVE}" -C "$TMP"

  echo "Installing to ${INSTALL_DIR}/${BINARY}..."
  if [ -w "$INSTALL_DIR" ]; then
    mv "${TMP}/${BINARY}" "${INSTALL_DIR}/${BINARY}"
  else
    sudo mv "${TMP}/${BINARY}" "${INSTALL_DIR}/${BINARY}"
  fi
  chmod +x "${INSTALL_DIR}/${BINARY}"

  rm -rf "$TMP"
  echo "Done. Run 'dotfiles apply' to set up your environment."
}

main
