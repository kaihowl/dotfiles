#!/bin/bash
set -e

if [ "$(uname)" == "Darwin" ]; then
  source "$DOTS/common/brew.sh"
  # Use --overwrite due to #347, linking of git on GH Actions
  brew_install --overwrite git
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "$DOTS/common/apt.sh"
  apt_install git
fi
