#!/bin/bash
set -e

if [ "$(uname)" == "Darwin" ]; then
  source "$DOTS/common/brew.sh"
  brew_install cmake
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  # install latest
  # NOTE This explicitly forgoes using the kitware-archive-keyring for automatic key rotation.
  # For uniformity with other packages, we will manually rotate the key.
  source "$DOTS/common/apt.sh"
  apt_add_repo kitware https://apt.kitware.com/ubuntu ::codename:: 0bb2bbf7862c3fb082da7887e2d464b33738bd19
  apt_install cmake
fi

