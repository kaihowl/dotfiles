#!/bin/bash
set -e

if [ "$(uname)" == "Darwin" ]; then
  # Actual copy needed, otherwise Spotlight will not show the app
  sudo cp -rfL ~/.nix-profile/Applications/Alacritty.app /Applications/
fi
