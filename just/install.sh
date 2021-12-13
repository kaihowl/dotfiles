#!/bin/bash
set -e

cd "$(dirname "$0")"

if [ "$(uname)" == "Darwin" ]; then
  source "$DOTS/common/brew.sh"
  brew_install just
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "$DOTS/common/apt.sh"
  apt_install curl
  tmpfile=$(mktemp)
  trap "rm -rf ${tmpfile}" EXIT
  curl -Lo "${tmpfile}" https://github.com/casey/just/releases/download/0.10.5/just-0.10.5-x86_64-unknown-linux-musl.tar.gz
  expect_hash="261e6912e3f63a37baa69d2dee5cc9f95f2523eaab38e3b73030ec1a1afde80e"
  actual_hash="$(shasum -a 256 "${tmpfile}" | cut -d' ' -f 1)"
  if [[ "$expect_hash" != "$actual_hash" ]]; then
    echo "shasum mismatch for just. Aborting."
    exit 1
  fi
  mkdir -p ~/bin
  echo "just" | tar -C ~/bin --extract -z -f "${tmpfile}" --files-from=-
fi

