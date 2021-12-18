#!/bin/bash
set -ex

if [ "$(uname -s)" = "Darwin" ]; then
  download_url="https://github.com/mattn/efm-langserver/releases/download/v0.0.38/efm-langserver_v0.0.38_darwin_amd64.zip"
  expect_hash="89d42660ffa2d0642e709bfb00f5a8fa5a46b4f3b188632f778541f5709e4c28"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/mattn/efm-langserver/releases/download/v0.0.38/efm-langserver_v0.0.38_linux_amd64.tar.gz"
  expect_hash="a3e2ae7c28037c809478aa96f68049db7672e04f755a1d84a26a54e4a7d307dd"
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

