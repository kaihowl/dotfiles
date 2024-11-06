#!/usr/bin/env zsh
set -e

echo "Check if cmake is available"
which cmake

echo "Check that cmake is installed from llvm apt repo (Ubuntu-only)"
if [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  apt-cache policy cmake
  apt-cache policy cmake | grep -F '**' -A1 | grep -F apt.kitware.com
fi
