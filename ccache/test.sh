#!/usr/bin/env -S zsh -il
set -e

echo "Check if ccache is available"
which ccache

echo "Check if ccache is nix controlled"
actual_path=$(realpath "$(which ccache)")
if [[ "${actual_path}" != /nix/store/* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected ccache to be managed by nix
  exit 1
fi

echo "Check if ccache is runnable"
ccache --version

echo "Check if ccache is used as a compiler launcher in cmake"
cd "$(dirname "$0")/test_project/"
rm -rf build
cmake -G Ninja -Bbuild -H.
ninja -C build -t commands | grep ccache
