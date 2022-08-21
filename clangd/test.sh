#!/bin/zsh -i
set -ex

echo "Check if clangd is available"
which clangd

echo "Check that clangd is installed from llvm apt repo (Ubuntu-only)"
if [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  apt policy clangd | grep -F '**' -A1 | grep -F apt.llvm.org
fi
