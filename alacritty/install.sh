#!/bin/bash
set -e

/nix/var/nix/profiles/default/bin/nix-env --install alacritty

if [ "$(uname)" == "Darwin" ]; then
  sudo cp -srf ~/.nix-profile/Applications/Alacritty.app /Applications/
fi
