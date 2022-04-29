#!/bin/bash
set -e

function ensure_brew_installed() {
  if test ! "$(which brew)"
  then
    echo "  Installing Homebrew for you."
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)" > /tmp/homebrew-install.log
  fi
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
