#!/bin/bash
set -ex

if [ "$(uname -s)" = "Darwin" ]; then
  download_url="https://github.com/mattn/efm-langserver/releases/download/v0.0.42/efm-langserver_v0.0.42_darwin_amd64.zip"
  expect_hash="a8dd648146fe192daccbfbe6ee5ac0d06a98ecc4c1eb3ff577629464da97aedf"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/mattn/efm-langserver/releases/download/v0.0.42/efm-langserver_v0.0.42_linux_amd64.tar.gz"
  expect_hash="56faf05c2fb4d8a0275c0b9fde71840af7b51e303f0ddaeebd965ddd368f11a2"
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

