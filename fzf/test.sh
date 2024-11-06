#!/usr/bin/env zsh
set -e

echo "Checking whether fzf is on path"
which fzf

echo "Check if fzf is runnable"
fzf --version

echo "Check that ctrl-xo is registered"
bindkey | grep -i '\^X\^O'
