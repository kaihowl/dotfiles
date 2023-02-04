#!/bin/bash
set -ex

# rustup-init might change with a new version that is called "stable"
# to support caching and not get stuck with the old version in the cache,
# introduce an artificial version
artificial_version=1

if [ "$(uname -s)" = "Darwin" ]; then
  download_url="https://static.rust-lang.org/rustup/dist/x86_64-apple-darwin/rustup-init"
  expect_hash="203dcef5a2fb0238ac5ac93edea8207eb63ef9823a150789a97f86965c4518f2"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-musl/rustup-init"
  expect_hash="241a99ff02accd2e8e0ef3a46aaa59f8d6934b1bb6e4fba158e1806ae028eb25"
fi

file_name=rustup-init-${artificial_version}

source "$DOTS/common/download.sh"
cache_file "$file_name" "$download_url" "$expect_hash"

rustupinit="$(cache_path "${file_name}")"
chmod +x "${rustupinit}"
"${rustupinit}" -y --verbose --component rust-analyzer
# shellcheck disable=SC1091
source "$HOME/.cargo/env"
ln -sf "$(rustup which rust-analyzer)" "$HOME/.cargo/bin/"

