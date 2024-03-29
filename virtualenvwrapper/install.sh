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

# Not using in place editing as macOS and GNU sed
# have incompatible -i options.
touch ~/.zprofile
sed "/^export VIRTUALENVWRAPPER_PYTHON.*$/d" ~/.zprofile > ~/.zprofilenew
# Using "sudo which" to bypass any user PATH prefixed python versions
echo "export VIRTUALENVWRAPPER_PYTHON=$(sudo which python3)" >> ~/.zprofilenew
mv ~/.zprofilenew ~/.zprofile
