#!/bin/bash -e

cd "$(dirname "$0")"

if [ "$(uname)" == "Darwin" ]; then
  source $DOTS/common/brew.sh
  brew_install just
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source $DOTS/common/apt.sh
  apt_install curl
  tmpfile=$(mktemp)
  trap "rm -rf ${tmpfile}" EXIT
  curl -Lo "${tmpfile}" https://github.com/casey/just/releases/download/0.10.4/just-0.10.4-x86_64-unknown-linux-musl.tar.gz
  expect_hash="4d1f3e3bef97edeee26f1a3760ac404dcb3a1f52930405c8bd3cd3e5b70545d8"
  actual_hash="$(shasum -a 256 ${tmpfile} | cut -d' ' -f 1)"
  if [[ "$expect_hash" != "$actual_hash" ]]; then
    echo "shasum mismatch for just. Aborting."
    exit 1
  fi
  mkdir -p ~/bin
  echo "just" | tar -C ~/bin --extract -z -f "${tmpfile}" --files-from=-
fi

