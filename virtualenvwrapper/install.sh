#!/bin/bash -e
set -e

if [ "$(uname -s)" = "Darwin" ]; then
  sudo python3 -m ensurepip --upgrade
  sudo python3 -m pip install --upgrade virtualenvwrapper
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source $DOTS/common/apt.sh
  apt_install python3-virtualenvwrapper
fi

# Not using in place editing as macOS and GNU sed
# have incompatible -i options.
touch ~/.zprofile
sed "/^export VIRTUALENVWRAPPER_PYTHON.*$/d" ~/.zprofile > ~/.zprofilenew
# Using "sudo which" to bypass any user PATH prefixed python versions
echo "export VIRTUALENVWRAPPER_PYTHON=$(sudo which python3)" >> ~/.zprofilenew
mv ~/.zprofilenew ~/.zprofile
