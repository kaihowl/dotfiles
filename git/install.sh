#!/bin/bash
set -e

if [ "$(uname)" == "Darwin" ]; then
  source "$DOTS/common/brew.sh"
  # Use --overwrite due to #347, linking of git on GH Actions
  brew_install --overwrite git
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "$DOTS/common/apt.sh"
  # TODO(hoewelmk) replace with apt_add_repo (if needed)
  sudo add-apt-repository ppa:git-core/ppa -y
  apt_install git
fi
