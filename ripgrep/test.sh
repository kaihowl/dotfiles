#!/usr/bin/env zsh -il
set -e

echo "Check if ripgrep is available"
which rg

echo "Check if ripgrep is runnable"
rg --version
