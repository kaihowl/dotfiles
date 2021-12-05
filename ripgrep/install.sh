#!/bin/bash -e
if [ "$(uname)" == "Darwin" ]; then
  source $DOTS/common/brew.sh
  brew_install ripgrep
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source $DOTS/common/apt.sh
  apt_install curl
  tmpfile=$(mktemp)
  trap "rm -rf ${tmpfile}" EXIT
  curl -Lo "${tmpfile}" https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
  expect_hash="6d78bed13722019cb4f9d0cf366715e2dcd589f4cf91897efb28216a6bb319f1"
  actual_hash="$(shasum -a 256 ${tmpfile} | cut -d' ' -f 1)"
  if [[ "$expect_hash" != "$actual_hash" ]]; then
    echo "shasum mismatch for ripgrep. Aborting."
    exit 1
  fi
  sudo dpkg -i "${tmpfile}"
fi
