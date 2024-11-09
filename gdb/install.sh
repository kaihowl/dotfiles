#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

if [[ "$(lsb_release -i 2> /dev/null)" == *"Ubuntu"* ]]; then
  source "${SCRIPT_DIR}/../common/apt.sh"
  # This will break if it is a different version used for the standard library.
  # We have a test to detect this.
  codename=$(lsb_release -cs)
  apt_add_repo ubuntu-toolchain-test https://ppa.launchpadcontent.net/ubuntu-toolchain-r/test/ubuntu ::codename:: 60C317803A41BA51845E371A1E9377A2BA9EF27F
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
