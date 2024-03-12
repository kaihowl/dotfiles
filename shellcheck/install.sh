#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

version=0.10.0

if [ "$(uname -s)" = "Darwin" ]; then
  if [ "$(uname -m)" = "arm64" ]; then
    download_url="https://github.com/koalaman/shellcheck/releases/download/v${version}/shellcheck-v${version}.darwin.aarch64.tar.xz"
    expect_hash="bbd2f14826328eee7679da7221f2bc3afb011f6a928b848c80c321f6046ddf81"
  else
    download_url="https://github.com/koalaman/shellcheck/releases/download/v${version}/shellcheck-v${version}.darwin.x86_64.tar.xz"
    expect_hash="ef27684f23279d112d8ad84e0823642e43f838993bbb8c0963db9b58a90464c2"
  fi
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/koalaman/shellcheck/releases/download/v${version}/shellcheck-v${version}.linux.x86_64.tar.xz"
  expect_hash="6c881ab0698e4e6ea235245f22832860544f17ba386442fe7e9d629f8cbedf87"
fi

file_name=shellcheck-v${version}.tar.xz

source "${SCRIPT_DIR}/../common/download.sh"
cache_file "$file_name" "$download_url" "$expect_hash"

mkdir -p ~/.shellcheck
tar -C ~/.shellcheck --extract -J -f "$(cache_path "${file_name}")" --strip-components 1

