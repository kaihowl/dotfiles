#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

/nix/var/nix/profiles/default/bin/nix-env --install alacritty

if [ "$(uname)" == "Darwin" ]; then
  sudo cp -srf ~/.nix-profile/Applications/Alacritty.app /Applications/
fi
