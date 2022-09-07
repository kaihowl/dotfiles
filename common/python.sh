#!/bin/bash

set -e

function ensure_pip_installed() {
  if [[ "$(uname)" == "Linux" && "$(lsb_release -i)" == *"Ubuntu"* ]]; then
    if test ! "$(python3 -m pip &> /dev/null)"
    then
      source "$DOTS/common/apt.sh"
      apt_install --no-install-recommends python3-pip python3-dev
    fi
  fi
}

function ensure_virtualenv_installed() {
  # TODO(kaihowl) there could be an old symlink in /usr/local/bin/virtualenv
  # TODO(kaihowl) remove that
  if test ! "$(python3 -m pip &> /dev/null)"; then
    if [[ "$(uname)" == "Linux" && "$(lsb_release -i)" == *"Ubuntu"* ]]; then
      source "$DOTS/common/apt.sh"
      apt_install --no-install-recommends python3-virtualenv
    elif [ "$(uname -s)" = "Darwin" ]; then
      source "$DOTS/common/brew.sh"
      brew_install virtualenv
    fi
  fi
}

function install_in_virtualenv() {
  ensure_pip_installed
  ensure_virtualenv_installed
  python3 -m virtualenv ~/.virtualenvs/dotfiles-run
  ~/.virtualenvs/dotfiles-run/bin/python3 -m pip install --upgrade "$*"
}
