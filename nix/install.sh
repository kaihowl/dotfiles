#!/bin/bash
set -e

if ! [ -f /nix/var/nix/profiles/default/bin/nix ]; then
  curl -L https://nixos.org/nix/install | sh -s -- --daemon
fi

if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  # shellcheck disable=SC1090,SC1091
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

if [[ $DOTFILES_PROFILE == minimal ]]; then
  bash -c 'nix run home-manager/release-24.05 -- --impure switch --flake .#minimal'
else
  bash -c 'nix run home-manager/release-24.05 -- --impure switch --flake .#full'
fi
