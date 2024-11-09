#!/usr/bin/env -S zsh -il
set -e

echo "Check if ncdu is available"
which ncdu

echo "Check if ncdu is runnable"
ncdu --version

echo "Check if tree is available"
which tree

echo "Check if tree is runnable"
tree --version

echo "Check if jq is available"
which jq

echo "Check if jq is runnable"
jq --version

echo "Check if htop is available"
which htop

echo "Check if htop is runnable"
htop --version

echo "Check if python3 is nix controlled"
actual_path=$(realpath "$(which python3)")
if [[ "${actual_path}" != /nix/store/* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected python3 to be managed by nix
  exit 1
fi
