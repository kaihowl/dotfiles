#!/bin/bash

set -e

function ensure_python_installed() {
  local script_dir
  script_dir=$(unset CDPATH; cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null; pwd -P)
  if [[ "$(uname)" == "Linux" && "$(lsb_release -i)" == *"Ubuntu"* ]]; then
    source "${script_dir}/apt.sh"
    # venv is needed as Ubuntu 22.04 otherwise has no ensurepip and venv fails.
    # Install all of these packages as a sane baseline.
    apt_install --no-install-recommends python3-pip python3-dev python3-venv
  else
    # The apple xcode python is broken. Use brew's python version instead.
    source "${script_dir}/brew.sh"
    brew_install python
  fi
}

function install_in_named_virtualenv() {
  local venvname
  venvname=$1
  shift

  ensure_python_installed
  # Using venv instead of virtualenv as homebrews virtualenv is completely
  # separate from its python. I.e., it is not installed as a site package.
  # Installing virtualenv globally defeats the purpose of having venvs in the
  # first place. venv seems to have the most support throughout macOS / Ubuntu.
  # Major difference, it does not seed wheel (needed by pynvim) into the
  # virtualenv. This is done manually including an upgrade of pip and
  # setuptools.
  python3 -m venv "$HOME/.virtualenvs/$venvname"
  # Must run independently as wheel is a non-declared dependency of some packages.
  "$HOME/.virtualenvs/$venvname/bin/python3" -m pip install --upgrade pip setuptools wheel
  "$HOME/.virtualenvs/$venvname/bin/python3" -m pip install --upgrade "$*"
}

function install_in_nvim_virtualenv() {
  install_in_named_virtualenv "dotfiles-run" "$*"
}
