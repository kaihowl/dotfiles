#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

# Remove old autojump installation.
# Otherwise old "j" compdef might still be sourced and conflicts with the zoxide definition.
if [ "$(uname -s)" = "Darwin" ]; then
  source "${SCRIPT_DIR}/../common/brew.sh"
  brew_remove autojump
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "${SCRIPT_DIR}/../common/apt.sh"
  apt_remove autojump
fi

version=0.9.2

if [ "$(uname -s)" = "Darwin" ]; then
  if [ "$(uname -m)" = "arm64" ]; then
    download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${version}/zoxide-${version}-aarch64-apple-darwin.tar.gz"
    expect_hash="2e312acdbe4befb3f2df0cf91e298bedfbb34f4bafccae02ea54e67702693112"
  else
    download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${version}/zoxide-${version}-x86_64-apple-darwin.tar.gz"
    expect_hash="978c5702481001f343fc6a953539f7c0815f3492a76fc0229aa88c01ab026760"
  fi
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${version}/zoxide-${version}-x86_64-unknown-linux-musl.tar.gz"
  expect_hash="d5598a321eb9ba0bf4c8c54f991fe4be69a65a6a81094c586539225c47ef2c7b"
fi

file_name=zoxide-${version}.tar.gz

source "${SCRIPT_DIR}/../common/download.sh"
cache_file "$file_name" "$download_url" "$expect_hash"

mkdir -p ~/.zoxide
tar -C ~/.zoxide --extract -z -f "$(cache_path "${file_name}")"
