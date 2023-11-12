#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

version=0.0.49

if [ "$(uname -s)" = "Darwin" ]; then
  if [ "$(uname -m)" = "arm64" ]; then
    download_url="https://github.com/mattn/efm-langserver/releases/download/v${version}/efm-langserver_v${version}_darwin_arm64.zip"
    expect_hash="945bdc2b37393ec3720bb06cecf729a43a38890edff71ef92ccf1fd033ffd48a"
  else
    download_url="https://github.com/mattn/efm-langserver/releases/download/v${version}/efm-langserver_v${version}_darwin_amd64.zip"
    expect_hash="8d34445fddb590caadc97027f27a340e639f9e13cd80cc929b170eeafa9e1398"
  fi
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/mattn/efm-langserver/releases/download/v${version}/efm-langserver_v${version}_linux_amd64.tar.gz"
  expect_hash="01e0836b4a211ebfc34eaa25ca988b6826b020125f8e488589ad29bcf0664d4d"
fi

file_name=efm-langserver-${version}.tar.gz

source "${SCRIPT_DIR}/../common/download.sh"
cache_file "$file_name" "$download_url" "$expect_hash"

mkdir -p ~/.efm
tar -C ~/.efm --extract -z -f "$(cache_path "${file_name}")" --strip-components 1

