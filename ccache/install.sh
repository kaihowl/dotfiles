#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

if [ "$(uname)" == "Darwin" ]; then
  source "${SCRIPT_DIR}/../common/brew.sh"
  brew_install ccache
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  # Installing build-essential to have a working compiler for the test.sh
  # Not necessary on macOS as a full llvm is installed
  source "${SCRIPT_DIR}/../common/apt.sh"
  apt_install ccache build-essential
fi

