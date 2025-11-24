#!/bin/bash
set -e

cd "$(dirname "$0")"/..
source common/perf_stubs.sh

if ! [ -f /nix/var/nix/profiles/default/bin/nix ]; then
  curl -L https://nixos.org/nix/install | sh -s -- --daemon
fi

if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  # shellcheck disable=SC1090,SC1091
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# NOTE twice impure flag needed as I don't want to hardcode system and user name combinations
if [[ $DOTFILES_PROFILE == minimal ]]; then
  bash -c 'nix run --impure .#home-manager -- --impure switch --flake .#minimal'
else
  bash -c 'nix run --impure .#home-manager -- --impure switch --flake .#full'
fi

# Create / update GC root to protect flake inputs from garbage collection
nix build --impure --profile ~/.nix-dotfiles-gc-root .#default

# Run garbage collection
nix-collect-garbage --delete-older-than 30d

closure_size=$(nix path-info -S ~/.nix-profile/ | awk '{print $2}')
add_measurement 'nix-closure-size' "$closure_size"
