#!/bin/zsh -i
set -ex

echo "Check if clangd is available"
which clangd

echo "Check that clangd can be started"
clangd --help > /dev/null

echo "Check that clangd is installed from llvm apt repo (Ubuntu-only)"
if [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  apt-cache policy clangd
  apt-cache policy clangd | grep -F '**' -A1 | grep -F apt.llvm.org
fi
