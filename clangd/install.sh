#!/bin/bash
set -ex

if [ "$(uname)" == "Darwin" ]; then
  version=15.0.3
  download_url="https://github.com/clangd/clangd/releases/download/${version}/clangd-mac-${version}.zip"
  expect_hash="f46c49cbaaeb8878728b1173feae4b6af46b7fb899e5fe024e1027428e0a14d9"

  file_name=clangd-mac-${version}.zip

  source "$DOTS/common/download.sh"
  cache_file "$file_name" "$download_url" "$expect_hash"

  mkdir -p ~/.clangd
  # TODO(kaihowl) unpacking a zip with `tar` is "weird"
  tar -C ~/.clangd --extract -z -f "$(cache_path "${file_name}")" --strip-components 1
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "$DOTS/common/apt.sh"
  apt_add_repo llvm https://apt.llvm.org/::codename:: llvm-toolchain-::codename:: 6084F3CF814B57C1CF12EFD515CF4D18AF4F7421
  apt_install clangd
fi
