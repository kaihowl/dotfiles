#!/bin/bash
set -e
if [ "$(uname)" == "Darwin" ]; then
  source "$DOTS/common/brew.sh"
  brew_install alacritty
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  sudo snap remove alacritty || true
  source "$DOTS/common/apt.sh"
  apt_install gpg ca-certificates lsb-release
  sudo mkdir -p /etc/apt/keyrings
  sudo gpg --homedir /tmp --batch --keyserver keyserver.ubuntu.com --no-default-keyring --keyring /etc/apt/keyrings/alacritty.gpg --receive-keys 3a160895cc2ce253085d08a552b24df7d43b5377
  echo "deb [signed-by=/etc/apt/keyrings/alacritty.gpg] http://ppa.launchpad.net/aslatter/ppa/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/alacritty.list
  echo "deb-src [signed-by=/etc/apt/keyrings/alacritty.gpg] http://ppa.launchpad.net/aslatter/ppa/ubuntu $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/alacritty.list
  sudo apt-get update
  apt_install alacritty
fi

