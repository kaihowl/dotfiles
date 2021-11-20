#!/bin/bash -e
set -e

if [ "$(uname -s)" = "Darwin" ]; then
  sudo python3 -m ensurepip --upgrade
  sudo python3 -m pip install --upgrade virtualenvwrapper
  sed -i ".backup" "/^export VIRTUALENVWRAPPER_PYTHON.*$/d" ~/.zprofile
  echo "export VIRTUALENVWRAPPER_PYTHON=$(which python3)" >> ~/.zprofile
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source $DOTS/common/apt.sh
  apt_install python3-virtualenvwrapper
fi
