#!/bin/bash
set -ex

if [ "$(uname)" == "Darwin" ]; then
  source "$DOTS/common/brew.sh"
  brew_install llvm
  # Force it into PATH
  sudo ln -sf "$(brew list llvm | grep 'bin/clangd$' | head -n1)" /usr/local/bin
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "$DOTS/common/apt.sh"
  apt_add_repo llvm https://apt.llvm.org/::codename:: llvm-toolchain-::codename:: 6084F3CF814B57C1CF12EFD515CF4D18AF4F7421
  apt_install clangd
fi
