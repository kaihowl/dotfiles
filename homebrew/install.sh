#!/bin/bash
set -eux
#
# Homebrew
#
# This installs some of the common dependencies needed (or at least desired)
# using Homebrew.

# If not OSX, just exit cleanly
if [ "$(uname -s)" != "Darwin" ]; then
  exit 0
fi

source "$DOTS/common/brew.sh"

if ! grep "brew shellenv" ~/.zprofile; then
  echo "eval \"\$($HOMEBREW_PREFIX/bin/brew shellenv)\"" >> ~/.zprofile
fi

# Install homebrew packages
brew_install coreutils

brew_install flock

# Install reattach-to-user-namespace
# This makes sure that tmux + vim is able to use the system clipboard
brew_install reattach-to-user-namespace
