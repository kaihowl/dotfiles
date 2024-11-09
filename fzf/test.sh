#!/usr/bin/env -S zsh -il
set -e

echo "Checking whether fzf is on path"
which fzf

echo "Check if fzf is nix controlled"
actual_path=$(realpath "$(which fzf)")
if [[ "${actual_path}" != /nix/store/* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected fzf to be managed by nix
  exit 1
fi

echo "Check if fzf is runnable"
fzf --version

echo "Check that ctrl-t is registered for fzf"
bindkey | grep -i '"\^T".*fzf'

echo "Check that ctrl-xo is registered"
bindkey | grep -i '\^X\^O'
