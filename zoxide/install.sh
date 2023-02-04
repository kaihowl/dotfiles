#!/bin/bash
set -ex

# Remove old autojump installation.
# Otherwise old "j" compdef might still be sourced and conflicts with the zoxide definition.
if [ "$(uname -s)" = "Darwin" ]; then
  source "$DOTS/common/brew.sh"
  brew_remove autojump
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "$DOTS/common/apt.sh"
  apt_remove autojump
fi

version=0.9.0

if [ "$(uname -s)" = "Darwin" ]; then
  if [ "$(uname -m)" = "arm64" ]; then
    download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${version}/zoxide-${version}-aarch64-apple-darwin.tar.gz"
    expect_hash="91429d02e97183cbaba47a93de909d85528c2d3258be392bb695158834fd32f9"
  else
    download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${version}/zoxide-${version}-x86_64-apple-darwin.tar.gz"
    expect_hash="5e91baccbb175e57ac4a248cc6146de352f7a229777bd34bb040c1e9fc862317"
  fi
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${version}/zoxide-${version}-x86_64-unknown-linux-musl.tar.gz"
  expect_hash="291bfd218ee274812264cb5da6a67a00003b4b7637aed915356ec8fd92045e6a"
fi

file_name=zoxide-${version}.tar.gz

source "$DOTS/common/download.sh"
cache_file "$file_name" "$download_url" "$expect_hash"

mkdir -p ~/.zoxide
tar -C ~/.zoxide --extract -z -f "$(cache_path "${file_name}")"
