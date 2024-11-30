#!/usr/bin/env -S zsh -il
set -e

echo "Check if vim-vint is on path"
PATH=~/.virtualenvs/dotfiles-run/bin:$PATH which vint

echo "Check if vint is nix controlled"
actual_path=$(realpath "$(which vint)")
if [[ "${actual_path}" != /nix/store/* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected vint to be managed by nix
  exit 1
fi

