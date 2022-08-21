#!/bin/bash
set -e
if [ "$(uname)" == "Darwin" ]; then
  source "$DOTS/common/brew.sh"
  brew_install alacritty
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  sudo snap remove alacritty || true
  source "$DOTS/common/apt.sh"
  apt_add_repo alacritty http://ppa.launchpad.net/aslatter/ppa/ubuntu ::codename:: 3a160895cc2ce253085d08a552b24df7d43b5377
  apt_install alacritty
fi

