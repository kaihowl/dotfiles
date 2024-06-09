#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

if [ "$(uname)" == "Darwin" ]; then
  source "${SCRIPT_DIR}/../common/brew.sh"
  brew_install universal-ctags
elif [ -f /etc/centos-release ]; then
  # TOOD not the same thing?
  yum install -y ctags
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "${SCRIPT_DIR}/../common/apt.sh"
  apt_install --no-install-recommends universal-ctags
fi
