#!/usr/bin/env -S zsh -il
set -e

if [ "$(uname)" != "Darwin" ]; then
  exit 0
fi

echo "Check if Maccy.app is installed"
if [[ ! -d "$HOME/.nix-profile/Applications/Maccy.app" ]]; then
  echo "Maccy.app not found in nix profile"
  exit 1
fi

echo "Check if Maccy.app is nix controlled"
actual_path=$(realpath "$HOME/.nix-profile/Applications/Maccy.app")
if [[ "${actual_path}" != /nix/store/* ]]; then
  echo "Actual Path: $actual_path"
  echo "Expected Maccy.app to be managed by nix"
  exit 1
fi
