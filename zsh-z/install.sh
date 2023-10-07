#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

# TODO(kaihowl) short-cut git check
# Assume git is installed on Darwin
if [ "$(uname)" != "Darwin" ] && [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "${SCRIPT_DIR}/../common/apt.sh"
  apt_install git
fi

if [ ! -d ~/.zsh-z ]; then
  git clone https://github.com/agkozak/zsh-z.git ~/.zsh-z --depth=1
fi

(cd ~/.zsh-z && git pull --rebase)
