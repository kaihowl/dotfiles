#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

if [ "$(uname)" == "Darwin" ]; then
  source "${SCRIPT_DIR}/../common/brew.sh"
  # Use --overwrite due to #347, linking of git on GH Actions
  brew_install --overwrite git
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "${SCRIPT_DIR}/../common/apt.sh"
  # TODO(hoewelmk) replace with apt_add_repo (if needed)
  sudo add-apt-repository ppa:git-core/ppa -y
  apt_install git
fi
