#!/bin/zsh -i
set -ex

source "$DOTS/common/utilities.sh"
if [ "$(uname)" != "Darwin" ] || ! version_less_than "$(darwin_version)" 11.0.0 ; then
  echo "Check if ncdu is available"
  which ncdu
fi

echo "Check if tree is available"
which tree

echo "Check if jq is available"
which jq

echo "Check if htop is available"
which htop

echo "Check if lnav is available"
which lnav
