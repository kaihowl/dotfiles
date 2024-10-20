#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

if [ "$(uname -s)" = "Darwin" ]; then
  source "${SCRIPT_DIR}/../common/brew.sh"
  brew_install virtualenvwrapper
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "${SCRIPT_DIR}/../common/apt.sh"
  apt_install python3-virtualenvwrapper
fi

source "${SCRIPT_DIR}/../common/utilities.sh"
# Using "sudo which" to bypass any user PATH prefixed python versions
sed_replace_in_file ~/.zprofile "^export VIRTUALENVWRAPPER_PYTHON.*$" "export VIRTUALENVWRAPPER_PYTHON=$(sudo which python3)"
