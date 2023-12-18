#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

version=0.0.48

if [ "$(uname -s)" = "Darwin" ]; then
  if [ "$(uname -m)" = "arm64" ]; then
    download_url="https://github.com/mattn/efm-langserver/releases/download/v${version}/efm-langserver_v${version}_darwin_arm64.zip"
    expect_hash="90f6aa5c9d3ac485b4cfc4595319b0466c64a12f894cb0bc05d22bbce7a17ade"
  else
    download_url="https://github.com/mattn/efm-langserver/releases/download/v${version}/efm-langserver_v${version}_darwin_amd64.zip"
    expect_hash="872f3d080fede08542aab114b58ff1cad8a1abdc2726207398d7c1debb6275ea"
  fi
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/mattn/efm-langserver/releases/download/v${version}/efm-langserver_v${version}_linux_amd64.tar.gz"
  expect_hash="9aa423f462b564994019dd757fa055a846bc27721172a6cdd64eb62c1e01a358"
fi

file_name=efm-langserver-${version}.tar.gz

source "${SCRIPT_DIR}/../common/download.sh"
cache_file "$file_name" "$download_url" "$expect_hash"

mkdir -p ~/.efm
tar -C ~/.efm --extract -z -f "$(cache_path "${file_name}")" --strip-components 1

