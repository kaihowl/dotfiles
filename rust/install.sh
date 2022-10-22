#!/bin/bash
set -ex

if [ "$(uname -s)" = "Darwin" ]; then
  download_url="https://static.rust-lang.org/rustup/dist/x86_64-apple-darwin/rustup-init"
  expect_hash="a45f826cdf2509dae65d53a52372736f54412cf92471dc8dba1299ef0885a03e"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-musl/rustup-init"
  expect_hash="95427cb0592e32ed39c8bd522fe2a40a746ba07afb8149f91e936cddb4d6eeac"
fi

tmpdir=$(mktemp -d)
rustupinit=${tmpdir}/rustup-init
# shellcheck disable=SC2064
trap "rm -rf ${tmpdir}" EXIT
curl -Lo "${rustupinit}" "${download_url}"
actual_hash="$(shasum -a 256 "${rustupinit}" | cut -d' ' -f 1)"
if [[ "$expect_hash" != "$actual_hash" ]]; then
  echo "shasum mismatch for shellcheck. Aborting."
  exit 1
fi
chmod +x "${rustupinit}"
# "${rustupinit}" -y --verbose

