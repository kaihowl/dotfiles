#!/bin/bash
set -ex

set -o pipefail

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

if [ "$(uname)" == "Darwin" ]; then
  source "${SCRIPT_DIR}/../common/brew.sh"
  brew_install cmake
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  # install latest
  source "${SCRIPT_DIR}/../common/apt.sh"
  # bootstrap automatic key rotation
  if ! [[ -f /usr/share/keyrings/kitware-archive-keyring.gpg ]]; then
    apt_install wget
    list_name=/etc/apt/sources.list.d/temp_kitware.list
    trap 'sudo rm -rf $list_name' EXIT
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ $(lsb_release -c -s) main" | sudo tee "$list_name" >/dev/null
    sudo apt-get update
    sudo rm -rf /usr/share/keyrings/kitware-archive-keyring.gpg
    apt_install kitware-archive-keyring
    rm -rf "$list_name"
  fi
  apt_add_repo_with_keyfile kitware https://apt.kitware.com/ubuntu ::codename:: /usr/share/keyrings/kitware-archive-keyring.gpg
  apt_install cmake
fi

