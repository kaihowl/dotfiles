#!/usr/bin/env zsh
set -e

echo "Check if ripgrep is available"
which rg

echo "Check if ripgrep is runnable"
rg --version
