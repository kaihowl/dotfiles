#!/bin/bash
set -ex

if [ "$(uname)" == "Darwin" ]; then
  # Do nothing
  exit 0
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "$DOTS/common/apt.sh"
  # This will break if it is a different version used for the standard library.
  # We have a test to detect this.
  codename=$(lsb_release -cs)
  if [[ "$codename" == *"focal"* ]]; then
    apt_install clang gdb libstdc++6-10-dbg
  elif [[ "$codename" == *"jammy"* ]]; then
    apt_install clang gdb libstdc++6-12-dbg
  else
    echo "Unsupported Ubuntu version $codename"
    echo "Maybe the following command will point to the correct version"
    apt-cache depends libstdc++6 | sed -n "s/.*Replaces: \(.*\)$/\1/p"
    exit 1
  fi
  
fi
