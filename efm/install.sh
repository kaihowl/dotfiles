#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

version=0.0.46

if [ "$(uname -s)" = "Darwin" ]; then
  if [ "$(uname -m)" = "arm64" ]; then
    download_url="https://github.com/mattn/efm-langserver/releases/download/v${version}/efm-langserver_v${version}_darwin_arm64.zip"
    expect_hash="6c1524f31236c3ca775635a5fb8ad1b3b07aa12f7e0d0ed8b2bb8b5878a5b6dc"
  else
    download_url="https://github.com/mattn/efm-langserver/releases/download/v${version}/efm-langserver_v${version}_darwin_amd64.zip"
    expect_hash="6ded4bfc3de1896487f0e643b70a31ce474a9e2bd77b1e995c3af73ba82a594b"
  fi
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/mattn/efm-langserver/releases/download/v${version}/efm-langserver_v${version}_linux_amd64.tar.gz"
  expect_hash="1423e11df7b684886028eddd7fce6b2f7178c120eb263615464dfacf25da9a3a"
fi

file_name=efm-langserver-${version}.tar.gz

source "${SCRIPT_DIR}/../common/download.sh"
cache_file "$file_name" "$download_url" "$expect_hash"

mkdir -p ~/.efm
tar -C ~/.efm --extract -z -f "$(cache_path "${file_name}")" --strip-components 1

