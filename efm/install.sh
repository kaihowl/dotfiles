#!/bin/bash
set -ex

version=0.0.44

if [ "$(uname -s)" = "Darwin" ]; then
  if [ "$(uname -m)" = "arm64" ]; then
    download_url="https://github.com/mattn/efm-langserver/releases/download/v${version}/efm-langserver_v${version}_darwin_arm64.zip"
    expect_hash="18858e84d31464a7fd7ae0040fd298002f616f39b94369a14027c6c66324acf0"
  else
    download_url="https://github.com/mattn/efm-langserver/releases/download/v${version}/efm-langserver_v${version}_darwin_amd64.zip"
    expect_hash="a94f4410d59d299cf73b3709e63f6ee9d86c1aff397c14b44275927a8312cc7a"
  fi
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/mattn/efm-langserver/releases/download/v${version}/efm-langserver_v${version}_linux_amd64.tar.gz"
  expect_hash="ec426dd75cd3afa1f921a25c9cd635958091a1f2d4d7f747181eef8d355cb432"
fi

file_name=efm-langserver-${version}.tar.gz

source "$DOTS/common/download.sh"
cache_file "$file_name" "$download_url" "$expect_hash"

mkdir -p ~/.efm
tar -C ~/.efm --extract -z -f "$(cache_path "${file_name}")" --strip-components 1

