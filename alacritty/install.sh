#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

if [ "$(uname)" == "Darwin" ]; then
  source "${SCRIPT_DIR}/../common/brew.sh"
  brew_install alacritty
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  sudo snap remove alacritty || true
  source "${SCRIPT_DIR}/../common/apt.sh"
  apt_add_repo alacritty http://ppa.launchpad.net/aslatter/ppa/ubuntu ::codename:: 3a160895cc2ce253085d08a552b24df7d43b5377
  apt_install alacritty
fi

