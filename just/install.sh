#!/bin/bash

set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

cd "$(dirname "$0")"

version=1.23.0

if [ "$(uname)" == "Darwin" ]; then
  source $DOTS/common/brew.sh
  brew_install just
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  # TODO(kaihowl) append to path
  # TODO(kaihowl) load completions
  # TODO(kaihowl) load man page
  expect_hash="8d8bce1af9c9dd618369302755c66cc940999ff42c3a3e66692cf56c235dd9e2"
  download_url=https://github.com/casey/just/releases/download/${version}/just-${version}-x86_64-unknown-linux-musl.tar.gz

  file_name=just-${version}.tar.gz

  source "${SCRIPT_DIR}/../common/download.sh"
  cache_file "$file_name" "$download_url" "$expect_hash"

  mkdir -p ~/.just
  tar -C ~/.just --extract -z -f "$(cache_path "${file_name}")"
fi

