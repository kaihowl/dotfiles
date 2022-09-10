#!/bin/zsh -i
set -e

echo "Check if vim-vint is on path"
PATH=~/.virtualenvs/dotfiles-run/bin:$PATH which vint

