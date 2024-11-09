#!/usr/bin/env -S zsh -il
set -e

echo "Check if ninja is available"
which ninja

echo "Check if ninja is nix controlled"
actual_path=$(realpath "$(which ninja)")
if [[ "${actual_path}" != /nix/store/* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected ninja to be managed by nix
  exit 1
fi

echo "Check if ninja is runnable"
ninja --version
