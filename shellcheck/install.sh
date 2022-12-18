#!/bin/bash
set -ex

if [ "$(uname -s)" = "Darwin" ]; then
  # TODO(kaihowl) there is no arm64 support yet.
  download_url="https://github.com/koalaman/shellcheck/releases/download/v0.9.0/shellcheck-v0.9.0.darwin.x86_64.tar.xz"
  expect_hash="7d3730694707605d6e60cec4efcb79a0632d61babc035aa16cda1b897536acf5"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/koalaman/shellcheck/releases/download/v0.9.0/shellcheck-v0.9.0.linux.x86_64.tar.xz"
  expect_hash="700324c6dd0ebea0117591c6cc9d7350d9c7c5c287acbad7630fa17b1d4d9e2f"
fi

tmpfile=$(mktemp)
# shellcheck disable=SC2064
trap "rm -rf ${tmpfile}" EXIT
curl -Lo "${tmpfile}" "${download_url}"
actual_hash="$(shasum -a 256 "${tmpfile}" | cut -d' ' -f 1)"
if [[ "$expect_hash" != "$actual_hash" ]]; then
  echo "shasum mismatch for shellcheck. Aborting."
  exit 1
fi
mkdir -p ~/.shellcheck
tar -C ~/.shellcheck --extract -J -f "${tmpfile}" --strip-components 1

