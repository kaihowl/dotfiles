#!/bin/bash
set -ex

cd "$(dirname "$0")"

if ! which zsh; then
  printf '\033[0;31m%s\033[0m\n' 'Please install zsh first.'
  exit 1
fi

if [ "$(uname)" == "Darwin" ]; then
  source "$DOTS/common/brew.sh"
  brew_install curl wget
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "$DOTS/common/apt.sh"
  apt_install wget curl git
fi

if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
fi
(cd ~/.fzf && git pull --rebase)
~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
