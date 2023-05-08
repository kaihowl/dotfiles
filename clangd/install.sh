#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

if [ "$(uname)" == "Darwin" ]; then
  version=16.0.2
  download_url="https://github.com/clangd/clangd/releases/download/${version}/clangd-mac-${version}.zip"
  expect_hash="0c2d19e200e5a2ce1f10f7a7ade8e9c0ee57be306022a8b9eb0c79d0c8af1cdd"

  file_name=clangd-mac-${version}.zip

  source "${SCRIPT_DIR}/../common/download.sh"
  cache_file "$file_name" "$download_url" "$expect_hash"

  mkdir -p ~/.clangd
  # TODO(kaihowl) unpacking a zip with `tar` is "weird"
  tar -C ~/.clangd --extract -z -f "$(cache_path "${file_name}")" --strip-components 1
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "${SCRIPT_DIR}/../common/apt.sh"
  apt_add_repo llvm https://apt.llvm.org/::codename:: llvm-toolchain-::codename:: 6084F3CF814B57C1CF12EFD515CF4D18AF4F7421
  apt_install clangd
fi
