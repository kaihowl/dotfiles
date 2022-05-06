#!/bin/bash
set -ex

if [ "$(uname -s)" = "Darwin" ]; then
  download_url="https://github.com/mattn/efm-langserver/releases/download/v0.0.44/efm-langserver_v0.0.44_darwin_amd64.zip"
  expect_hash="a94f4410d59d299cf73b3709e63f6ee9d86c1aff397c14b44275927a8312cc7a"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/mattn/efm-langserver/releases/download/v0.0.44/efm-langserver_v0.0.44_linux_amd64.tar.gz"
  expect_hash="ec426dd75cd3afa1f921a25c9cd635958091a1f2d4d7f747181eef8d355cb432"
fi

tmpfile=$(mktemp)
# shellcheck disable=SC2064
trap "rm -rf ${tmpfile}" EXIT
curl -Lo "${tmpfile}" "${download_url}"
actual_hash="$(shasum -a 256 "${tmpfile}" | cut -d' ' -f 1)"
if [[ "$expect_hash" != "$actual_hash" ]]; then
  echo "shasum mismatch for efm-langserver. Aborting."
  exit 1
fi
mkdir -p ~/.efm
tar -C ~/.efm --extract -z -f "${tmpfile}" --strip-components 1

