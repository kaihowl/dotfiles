#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

if ! which zsh; then
  printf '\033[0;31m%s\033[0m\n' 'Please install zsh first.'
  exit 1
fi

if [ "$(uname)" == "Darwin" ]; then
  source "${SCRIPT_DIR}/../common/brew.sh"
  if ! which curl > /dev/null; then
    brew_install curl
  fi
  if ! which wget > /dev/null; then
    brew_install wget
  fi
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "${SCRIPT_DIR}/../common/apt.sh"
  apt_install wget curl git
fi

if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
fi
(cd ~/.fzf && git pull --rebase)
~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
