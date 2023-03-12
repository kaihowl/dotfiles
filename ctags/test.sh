#!/bin/zsh -i
set -e

echo "Check if (universal-)ctags is available"
which ctags

echo "Check if ctags is runnable"
ctags --version
