#!/usr/bin/env zsh
set -e

echo "Check if cmake is available"
which cmake

echo "Check if cmake is nix controlled"
actual_path=$(realpath "$(which cmake)")
if [[ "${actual_path}" != /nix/store/* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected cmake to be managed by nix
  exit 1
fi

echo "Check that cmake is installed from llvm apt repo (Ubuntu-only)"
if [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  apt-cache policy cmake
  apt-cache policy cmake | grep -F '**' -A1 | grep -F apt.kitware.com
fi
