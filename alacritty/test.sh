#!/usr/bin/env -S zsh -il

set -e

echo "Check if alacritty is installed"
which alacritty

echo "Check if alacritty is nix controlled"
actual_path=$(realpath "$(which alacritty)")
if [[ "${actual_path}" != /nix/store/* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected alacritty to be managed by nix
  exit 1
fi

echo "Check if alacritty is runnable"
alacritty --version
