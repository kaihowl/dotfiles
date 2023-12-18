#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

if [ "$(uname -s)" = "Darwin" ]; then
  source "${SCRIPT_DIR}/../common/brew.sh"
  brew_install tree jq htop automake libtool pkg-config
  source "${SCRIPT_DIR}/../common/utilities.sh"
  if ! version_less_than "$(darwin_version)" 11.0.0 ; then
    brew_install ncdu
  fi
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "${SCRIPT_DIR}/../common/apt.sh"
  apt_install ncdu tree jq htop automake libtool pkg-config
fi
