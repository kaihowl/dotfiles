#!/bin/zsh -i
set -e

echo "Check if ninja is available"
which ninja

echo "Check if ninja is runnable"
ninja --version
