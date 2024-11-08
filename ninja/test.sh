#!/usr/bin/env -S zsh -il
set -e

echo "Check if ninja is available"
which ninja

echo "Check if ninja is runnable"
ninja --version
