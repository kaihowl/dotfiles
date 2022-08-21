#!/bin/zsh -i
set -ex

echo "Check if cmake is available"
which cmake

echo "Check that cmake is installed from llvm apt repo (Ubuntu-only)"
if [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  apt policy clangd | grep -F '**' -A1 | grep -F apt.kitware.com
fi
