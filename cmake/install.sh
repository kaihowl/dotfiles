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
  apt_add_repo kitware https://apt.kitware.com/ubuntu ::codename:: f41e5eaee6993e4dec254b3542d5a192b819c5da
  apt_install cmake
fi

