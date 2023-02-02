#!/bin/bash
set -ex

if [ "$(uname -s)" = "Darwin" ]; then
  download_url="https://static.rust-lang.org/rustup/dist/x86_64-apple-darwin/rustup-init"
  expect_hash="203dcef5a2fb0238ac5ac93edea8207eb63ef9823a150789a97f86965c4518f2"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-musl/rustup-init"
  expect_hash="241a99ff02accd2e8e0ef3a46aaa59f8d6934b1bb6e4fba158e1806ae028eb25"
fi

tmpdir=$(mktemp -d)
rustupinit=${tmpdir}/rustup-init
# shellcheck disable=SC2064
trap "rm -rf ${tmpdir}" EXIT
curl -Lo "${rustupinit}" "${download_url}"
actual_hash="$(shasum -a 256 "${rustupinit}" | cut -d' ' -f 1)"
if [[ "$expect_hash" != "$actual_hash" ]]; then
  echo "shasum mismatch for rustup-init. Aborting."
  exit 1
fi
chmod +x "${rustupinit}"
"${rustupinit}" -y --verbose --component rust-analyzer
# shellcheck disable=SC1091
source "$HOME/.cargo/env"
ln -sf "$(rustup which rust-analyzer)" "$HOME/.cargo/bin/"

