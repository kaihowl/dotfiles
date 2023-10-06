#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

# Assume git is installed on Darwin
if [ "$(uname)" != "Darwin" ] && [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "${SCRIPT_DIR}/../common/apt.sh"
  apt_install git
fi

if [ ! -d ~/.powerlevel10k ]; then
  git clone https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k --depth=1
fi
(cd ~/.powerlevel10k && git pull --rebase)
