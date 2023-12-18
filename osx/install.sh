#!/bin/bash
set -e

if [ "$(uname -s)" != "Darwin" ]; then
  exit
fi

if [ "$(uname -m)" != "arm64" ]; then
  exit
fi

if ! [[ -f /Library/Apple/usr/libexec/oah/libRosettaRuntime ]]; then
  sudo softwareupdate --install-rosetta --agree-to-license
fi
