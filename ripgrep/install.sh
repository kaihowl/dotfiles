#!/bin/bash
set -e
if [ "$(uname)" == "Darwin" ]; then
  source "$DOTS/common/brew.sh"
  brew_install ripgrep
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "$DOTS/common/apt.sh"
  apt_install curl

  source "$DOTS/common/download.sh"

  file_name=ripgrep_13.0.0_amd64.deb
  download_url=https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
  expect_hash="6d78bed13722019cb4f9d0cf366715e2dcd589f4cf91897efb28216a6bb319f1"

  cache_file "$file_name" "$download_url" "$expect_hash"
  sudo dpkg -i "$(cache_path "${file_name}")"
fi
