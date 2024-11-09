#!/bin/bash

set -e

function install_in_named_virtualenv() {
  local venvname
  venvname=$1
  shift

  # Using venv instead of virtualenv as homebrews virtualenv is completely
  # separate from its python. I.e., it is not installed as a site package.
  # Installing virtualenv globally defeats the purpose of having venvs in the
  # first place. venv seems to have the most support throughout macOS / Ubuntu.
  # Major difference, it does not seed wheel (needed by pynvim) into the
  # virtualenv. This is done manually including an upgrade of pip and
  # setuptools.
  python3Binary=$HOME/.virtualenvs/$venvname/bin/python3 
  if [[ -f $python3Binary ]] && ! [[ $(realpath "$python3Binary") == /nix/store/* ]]; then
      echo "Delete pre-nix-era venv, start fresh"
      rm -rf "$HOME/.virtualenvs/$venvname/"
  fi
  ~/.nix-profile/bin/python3 -m venv "$HOME/.virtualenvs/$venvname"
  # Must run independently as wheel is a non-declared dependency of some packages.
  "$python3Binary" -m pip install --upgrade pip setuptools wheel
  "$python3Binary" -m pip install --upgrade "$*"
}

function install_in_nvim_virtualenv() {
  install_in_named_virtualenv "dotfiles-run" "$*"
}
