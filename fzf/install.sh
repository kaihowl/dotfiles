#!/bin/bash
set -ex

cd "$(dirname "$0")"

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
