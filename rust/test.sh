#!/bin/zsh -i
set -e
set -x

echo "Check if rustc is on path"
which rustc

echo "Check if cargo is on path"
which cargo

echo "Check if rust-analyzer is on path"
which rust-analyzer
