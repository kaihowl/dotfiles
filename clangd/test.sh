#!/usr/bin/env -S zsh -il
set -e

echo "Check if clangd is available"
which clangd

echo "Check if clangd is runnable"
clangd --version

echo "Check that clangd can be started"
clangd --help > /dev/null

echo "Check that clangd is nix managed"
actual_path=$(realpath "$(which clangd)")
if [[ "${actual_path}" != /nix/store/* ]]; then
  echo "Actual Path: $actual_path"
  echo "TODO(kaihowl) All paths: $PATH"
  echo Expected clangd to be managed by nix
  exit 1
fi
