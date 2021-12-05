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
  # shellcheck disable=SC2064
  trap "rm -rf ${tmpfile}" EXIT
  curl -Lo "${tmpfile}" https://github.com/casey/just/releases/download/0.10.4/just-0.10.4-x86_64-unknown-linux-musl.tar.gz
  expect_hash="3898b3b4d34f9f7d80be578f4159e3c8000d9b08"
  actual_hash="$(sha1sum "${tmpfile}" | cut -d' ' -f 1)"
  if [[ "$expect_hash" != "$actual_hash" ]]; then
    echo "sha1sum mismatch for just. Aborting."
    exit 1
  fi
  mkdir -p ~/bin
  echo "just" | tar -C ~/bin --extract -z -f "${tmpfile}" --files-from=-
fi

