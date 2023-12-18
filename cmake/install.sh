#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

if [ "$(uname)" == "Darwin" ]; then
  source "${SCRIPT_DIR}/../common/brew.sh"
  brew_install cmake
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  # install latest
  # NOTE This explicitly forgoes using the kitware-archive-keyring for automatic key rotation.
  # For uniformity with other packages, we will manually rotate the key.
  source "${SCRIPT_DIR}/../common/apt.sh"
  apt_add_repo kitware https://apt.kitware.com/ubuntu ::codename:: f41e5eaee6993e4dec254b3542d5a192b819c5da
  apt_install cmake
fi

