#!/bin/bash
set -ex

if [ "$(uname -s)" = "Darwin" ]; then
  download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v0.7.9/zoxide-v0.7.9-x86_64-apple-darwin.tar.gz"
  expect_hash="f120c034c3a70c0de304ebcbbdc0419aa4b54370891a4626aefb5396e2115dbf"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v0.7.9/zoxide-v0.7.9-x86_64-unknown-linux-musl.tar.gz"
  expect_hash="94dd29ca9bee0fed3a5d045b02d699b3c3415d6f40d2303b2d71fe0746e6be30"
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

# Fix up man page structure for man AUTOPATH
# See https://github.com/ajeetdsouza/zoxide/issues/319
mkdir -p ~/.zoxide/man/man1
mv ~/.zoxide/man/*.1 ~/.zoxide/man/man1
