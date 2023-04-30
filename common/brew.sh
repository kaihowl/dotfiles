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

  # Use last argv as name
  # TODO This does not work if formulae / casks are supplied inter-mixed.
  for name in "$@"; do :; done

  if brew list --cask "$name" > /dev/null 2>&1; then
    # name is CASK and it is installed
    brew upgrade "$name"
  else
    # Install (FORMULA or CASK) or upgrade (only FORMULA) if already installed (this is done by `install` if HOMEBREW_NO_INSTALL_UPGRADE is not set)
    brew install "$@"
  fi
}

function brew_remove() {
  ensure_brew_installed
  brew remove -f "$@"
}
