#!/bin/bash
set -e

if [ "$(uname -s)" = "Darwin" ]; then
  source "$DOTS/common/brew.sh"
  brew_install tree jq htop automake libtool pkg-config lnav
  source "$DOTS/common/utilities.sh"
  if ! version_less_than "$(darwin_version)" 11.0.0 ; then
    brew_install ncdu
  fi
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "$DOTS/common/apt.sh"
  apt_install ncdu tree jq htop automake libtool pkg-config lnav
fi
