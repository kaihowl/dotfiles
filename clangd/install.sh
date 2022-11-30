#!/bin/bash
set -ex

if [ "$(uname)" == "Darwin" ]; then
  download_url="https://github.com/clangd/clangd/releases/download/15.0.3/clangd-mac-15.0.3.zip"
  expect_hash="f46c49cbaaeb8878728b1173feae4b6af46b7fb899e5fe024e1027428e0a14d9"

  tmpfile=$(mktemp)
  # shellcheck disable=SC2064
  trap "rm -rf ${tmpfile}" EXIT
  curl -Lo "${tmpfile}" "${download_url}"
  actual_hash="$(shasum -a 256 "${tmpfile}" | cut -d' ' -f 1)"
  if [[ "$expect_hash" != "$actual_hash" ]]; then
    echo "shasum mismatch for clangd. Aborting."
    exit 1
  fi
  mkdir -p ~/.clangd
  # TODO(kaihowl) unpacking a zip with `tar` is "weird"
  tar -C ~/.clangd --extract -z -f "${tmpfile}" --strip-components 1
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "$DOTS/common/apt.sh"
  apt_add_repo llvm https://apt.llvm.org/::codename:: llvm-toolchain-::codename:: 6084F3CF814B57C1CF12EFD515CF4D18AF4F7421
  apt_install clangd
fi
