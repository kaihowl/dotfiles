#!/bin/bash
set -ex

version=0.9.0

if [ "$(uname -s)" = "Darwin" ]; then
  # TODO(kaihowl) there is no arm64 support yet.
  download_url="https://github.com/koalaman/shellcheck/releases/download/v${version}/shellcheck-v${version}.darwin.x86_64.tar.xz"
  expect_hash="7d3730694707605d6e60cec4efcb79a0632d61babc035aa16cda1b897536acf5"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/koalaman/shellcheck/releases/download/v${version}/shellcheck-v${version}.linux.x86_64.tar.xz"
  expect_hash="700324c6dd0ebea0117591c6cc9d7350d9c7c5c287acbad7630fa17b1d4d9e2f"
fi

file_name=shellcheck-v${version}.tar.xz

source "$DOTS/common/download.sh"
cache_file "$file_name" "$download_url" "$expect_hash"

mkdir -p ~/.shellcheck
tar -C ~/.shellcheck --extract -J -f "$(cache_path "${file_name}")" --strip-components 1

