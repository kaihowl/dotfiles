#!/usr/bin/env -S zsh -il
set -e

echo "Check if (universal-)ctags is available"
which ctags

echo "Check if ctags is nix controlled"
actual_path=$(realpath "$(which ctags)")
if [[ "${actual_path}" != /nix/store/* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected ctags to be managed by nix
  exit 1
fi

echo "Check if ctags is runnable"
ctags --version
