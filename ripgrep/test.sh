#!/bin/zsh -i
set -e

echo "Check if ripgrep is available"
which rg

echo "Check if ripgrep is runnable"
rg --version
