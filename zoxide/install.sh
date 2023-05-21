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

version=0.9.1

if [ "$(uname -s)" = "Darwin" ]; then
  if [ "$(uname -m)" = "arm64" ]; then
    download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${version}/zoxide-${version}-aarch64-apple-darwin.tar.gz"
    expect_hash="31a09d196616d889cc4a9dc703b470eb47c0c9593a73c15d898c194fd6923cf5"
  else
    download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${version}/zoxide-${version}-x86_64-apple-darwin.tar.gz"
    expect_hash="19ca1507a836cb746c4af03d85cc300ab18840b13ec8e3df6239b928df59d3b1"
  fi
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v${version}/zoxide-${version}-x86_64-unknown-linux-musl.tar.gz"
  expect_hash="29163749c99fb2e919f8d685eec4b91de6f5e5a5c46d0d094abe7ad4e042e091"
fi

file_name=zoxide-${version}.tar.gz

source "${SCRIPT_DIR}/../common/download.sh"
cache_file "$file_name" "$download_url" "$expect_hash"

mkdir -p ~/.zoxide
tar -C ~/.zoxide --extract -z -f "$(cache_path "${file_name}")"
