#!/usr/bin/env -S zsh -il

set -e

echo "Check if alacritty is installed"
which alacritty

echo "Check if alacritty is runnable"
alacritty --version
