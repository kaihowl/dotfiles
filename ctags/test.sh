#!/usr/bin/env -S zsh -il
set -e

echo "Check if (universal-)ctags is available"
which ctags

echo "Check if ctags is runnable"
ctags --version
