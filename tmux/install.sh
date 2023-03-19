#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

if [ "$(uname)" == "Darwin" ]; then
  source "${SCRIPT_DIR}/../common/brew.sh"
  brew_install tmux
  terminfofile="$(dirname "$0")/tmux-256color.terminfo"
  tic -x "$terminfofile"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "${SCRIPT_DIR}/../common/apt.sh"
  apt_install tmux
fi
