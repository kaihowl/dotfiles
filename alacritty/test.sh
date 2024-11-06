#!/usr/bin/env zsh

set -e

echo "Check if alacritty is installed"
which alacritty

echo "Check if alacritty is runnable"
alacritty --version
