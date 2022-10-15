#!/bin/bash
set -e

if [[ "$(/usr/bin/uname -m)" == "arm64" ]]; then
  # On ARM macOS, this script installs to /opt/homebrew only
  HOMEBREW_PREFIX="/opt/homebrew"
else
  # On Intel macOS, this script installs to /usr/local only
  HOMEBREW_PREFIX="/usr/local"
fi

function ensure_brew_installed() {
  BREW_BIN=$HOMEBREW_PREFIX/bin/brew
  eval "$($BREW_BIN shellenv)" || true
  if test ! "$(which brew)"
  then
    echo "  Installing Homebrew for you."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$($BREW_BIN shellenv)"
}

function brew_install() {
  ensure_brew_installed
  # Install and upgrade if already installed (this is done by `install` if HOMEBREW_NO_INSTALL_UPGRADE is not set)
  brew install "$@"
}

function brew_remove() {
  ensure_brew_installed
  brew remove -f "$@"
}
