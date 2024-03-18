#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

version=0.0.53

if [ "$(uname -s)" = "Darwin" ]; then
  if [ "$(uname -m)" = "arm64" ]; then
    download_url="https://github.com/mattn/efm-langserver/releases/download/v${version}/efm-langserver_v${version}_darwin_arm64.zip"
    expect_hash="2449b3ce508de746548ac1f61e90bf0ee28bb57174c74dd7357bc385f6276411"
  else
    download_url="https://github.com/mattn/efm-langserver/releases/download/v${version}/efm-langserver_v${version}_darwin_amd64.zip"
    expect_hash="c7415c4b8a56953861e10e8ce5258c2850d87e47500ab4cd5b5873fed86a2980"
  fi
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/mattn/efm-langserver/releases/download/v${version}/efm-langserver_v${version}_linux_amd64.tar.gz"
  expect_hash="b9a81bd451cc645cc7a8b7af0f60c5a332a116b18cec57e9dd03e266c85e089d"
fi

file_name=efm-langserver-${version}.tar.gz

source "${SCRIPT_DIR}/../common/download.sh"
cache_file "$file_name" "$download_url" "$expect_hash"

mkdir -p ~/.efm
tar -C ~/.efm --extract -z -f "$(cache_path "${file_name}")" --strip-components 1

