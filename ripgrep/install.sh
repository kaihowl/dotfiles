#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

if [ "$(uname)" == "Darwin" ]; then
  source "${SCRIPT_DIR}/../common/brew.sh"
  brew_install ripgrep
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "${SCRIPT_DIR}/../common/apt.sh"
  apt_install curl

  source "${SCRIPT_DIR}/../common/download.sh"

  version=14.0.1
  file_name=ripgrep_${version}
  download_url=https://github.com/BurntSushi/ripgrep/releases/download/${version}/ripgrep_${version}-1_amd64.deb
  expect_hash="ab0de69388fde06c872525918572105beed6cee657d08a943e1c98c52a4a5139"

  cache_file "$file_name" "$download_url" "$expect_hash"
  sudo dpkg -i "$(cache_path "${file_name}")"
fi
