#!/bin/bash
set -ex

if [ "$(uname -s)" = "Darwin" ]; then
  download_url="https://github.com/koalaman/shellcheck/releases/download/v0.8.0/shellcheck-v0.8.0.darwin.x86_64.tar.xz"
  expect_hash="e065d4afb2620cc8c1d420a9b3e6243c84ff1a693c1ff0e38f279c8f31e86634"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/koalaman/shellcheck/releases/download/v0.8.0/shellcheck-v0.8.0.linux.x86_64.tar.xz"
  expect_hash="ab6ee1b178f014d1b86d1e24da20d1139656c8b0ed34d2867fbb834dad02bf0a"
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

