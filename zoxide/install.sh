#!/bin/bash
set -ex

# Remove old autojump installation.
# Otherwise old "j" compdef might still be sourced and conflicts with the zoxide definition.
if [ "$(uname -s)" = "Darwin" ]; then
  source "$DOTS/common/brew.sh"
  brew_remove autojump
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "$DOTS/common/apt.sh"
  apt_remove autojump
fi

if [ "$(uname -s)" = "Darwin" ]; then
  if [ "$(uname -m)" = "arm64" ]; then
    download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v0.9.0/zoxide-0.9.0-aarch64-apple-darwin.tar.gz"
    expect_hash="91429d02e97183cbaba47a93de909d85528c2d3258be392bb695158834fd32f9"
  else
    download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v0.9.0/zoxide-0.9.0-x86_64-apple-darwin.tar.gz"
    expect_hash="5e91baccbb175e57ac4a248cc6146de352f7a229777bd34bb040c1e9fc862317"
  fi
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v0.9.0/zoxide-0.9.0-x86_64-unknown-linux-musl.tar.gz"
  expect_hash="291bfd218ee274812264cb5da6a67a00003b4b7637aed915356ec8fd92045e6a"
fi

tmpfile=$(mktemp)
# shellcheck disable=SC2064
trap "rm -rf ${tmpfile}" EXIT
curl -Lo "${tmpfile}" "${download_url}"
actual_hash="$(shasum -a 256 "${tmpfile}" | cut -d' ' -f 1)"
if [[ "$expect_hash" != "$actual_hash" ]]; then
  echo "shasum mismatch for zoxide. Aborting."
  exit 1
fi
mkdir -p ~/.zoxide
tar -C ~/.zoxide --extract -z -f "${tmpfile}"
