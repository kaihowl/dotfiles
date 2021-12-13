#!/bin/bash
set -ex

if [ "$(uname)" == "Darwin" ]; then
  # Do nothing
  exit 0
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source $DOTS/common/apt.sh
  # TODO(kaihowl) this will break if it is a different version used for the standard library
  apt_install clang gdb libstdc++6-10-dbg
fi
