#!/usr/bin/env -S zsh -il
set -e

echo "Check if vim-vint is on path"
PATH=~/.virtualenvs/dotfiles-run/bin:$PATH which vint

