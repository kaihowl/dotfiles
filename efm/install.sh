#!/bin/bash
set -ex

if [ "$(uname -s)" = "Darwin" ]; then
  download_url="https://github.com/mattn/efm-langserver/releases/download/v0.0.41/efm-langserver_v0.0.41_darwin_amd64.zip"
  expect_hash="438c619c8ed279ebdc8839d37982317eb23aebf384b1fcafcb8c20d7cf24bf34"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/mattn/efm-langserver/releases/download/v0.0.41/efm-langserver_v0.0.41_linux_amd64.tar.gz"
  expect_hash="9a36444544bb079bc3ca17cacca70f309a6b786bbd1dcadf674c395d821caf8e"
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

