#!/bin/zsh -i
set -e
set -x

echo "Checking whether fzf is on path"
which fzf

echo "Check that ctrl-xo is registered"
bindkey | grep -i '\^X\^O'
