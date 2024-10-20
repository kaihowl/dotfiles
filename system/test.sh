#!/usr/bin/env zsh
set -e

source "$DOTS/common/utilities.sh"
if [ "$(uname)" != "Darwin" ] || ! version_less_than "$(darwin_version)" 11.0.0 ; then
  echo "Check if ncdu is available"
  which ncdu

  echo "Check if ncdu is runnable"
  ncdu --version
fi

echo "Check if tree is available"
which tree

echo "Check if tree is runnable"
tree --version

echo "Check if jq is available"
which jq

echo "Check if jq is runnable"
jq --version

echo "Check if htop is available"
which htop

echo "Check if htop is runnable"
htop --version
