#!/bin/zsh -i
set -ex

echo "Check if cmake is available"
which cmake

echo "Check that cmake is installed from llvm apt repo (Ubuntu-only)"
# TODO(#440) cmake not yet available for jammy
if [[ "$(lsb_release -i)" == *"Ubuntu"* ]] && [[ "$(lsb_release -cs)" != *"jammy"* ]]; then
  apt policy cmake
  apt policy cmake | grep -F '**' -A1 | grep -F apt.kitware.com
fi
