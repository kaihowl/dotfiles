#!/bin/bash

set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null; pwd -P)

function ensure_python_installed() {
  if [[ "$(uname)" == "Linux" && "$(lsb_release -i)" == *"Ubuntu"* ]]; then
    source "${SCRIPT_DIR}/apt.sh"
    # venv is needed as Ubuntu 22.04 otherwise has no ensurepip and venv fails.
    # Install all of these packages as a sane baseline.
    apt_install --no-install-recommends python3-pip python3-dev python3-venv
  else
    # The apple xcode python is broken. Use brew's python version instead.
    source "${SCRIPT_DIR}/brew.sh"
    brew_install python
  fi
}

function install_in_virtualenv() {
  ensure_python_installed
  # Using venv instead of virtualenv as homebrews virtualenv is completely
  # separate from its python. I.e., it is not installed as a site package.
  # Installing virtualenv globally defeats the purpose of having venvs in the
  # first place. venv seems to have the most support throughout macOS / Ubuntu.
  # Major difference, it does not seed wheel (needed by pynvim) into the
  # virtualenv. This is done manually including an upgrade of pip and
  # setuptools.
  python3 -m venv ~/.virtualenvs/dotfiles-run
  # Must run independently as wheel is a non-declared dependency of some packages.
  ~/.virtualenvs/dotfiles-run/bin/python3 -m pip install --upgrade pip setuptools wheel
  ~/.virtualenvs/dotfiles-run/bin/python3 -m pip install --upgrade "$*"
  deactivate
}
