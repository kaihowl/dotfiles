#!/bin/bash
set -ex

if [ "$(uname -s)" = "Darwin" ]; then
  download_url="https://github.com/mattn/efm-langserver/releases/download/v0.0.40/efm-langserver_v0.0.40_darwin_amd64.zip"
  expect_hash="9310b419e91423e398d1078bbaf24cfc95f0e50bccdbd5b30b69118f224592b7"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/mattn/efm-langserver/releases/download/v0.0.40/efm-langserver_v0.0.40_linux_amd64.tar.gz"
  expect_hash="101be2f9ed8de0357363f90868442802c8ea0be4f1b8f1e0ad327e3923e9fe31"
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

