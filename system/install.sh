#!/bin/bash
set -e

if [ "$(uname -s)" = "Darwin" ]; then
  source "$DOTS/common/brew.sh"
  brew_install ncdu tree jq htop automake libtool pkg-config lnav
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "$DOTS/common/apt.sh"
  apt_install ncdu tree jq htop automake libtool pkg-config lnav
fi
