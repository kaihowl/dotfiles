#!/usr/bin/env -S zsh -il
set -e

echo "Check if cmake is available"
which cmake

echo "Check if cmake is nix controlled"
actual_path=$(realpath "$(which cmake)")
if [[ "${actual_path}" != /nix/store/* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected cmake to be managed by nix
  exit 1
fi
