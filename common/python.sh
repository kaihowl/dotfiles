#!/bin/bash

set -e

function ensure_python_installed() {
  if [[ "$(uname)" == "Linux" && "$(lsb_release -i)" == *"Ubuntu"* ]]; then
    source "$DOTS/common/apt.sh"
    # venv is needed as Ubuntu 22.04 otherwise has no ensurepip and venv fails.
    # wheel is sometimes needed by python packages, e.g., pynvim.
    # Install all of these packages as a sane baseline.
    apt_install --no-install-recommends python3-pip python3-dev python3-wheel python3-venv
  fi
}

function install_in_virtualenv() {
  ensure_python_installed
  python3 -m venv ~/.virtualenvs/dotfiles-run
  ~/.virtualenvs/dotfiles-run/bin/python3 -m pip install --upgrade "$*"
}
