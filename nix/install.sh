#!/bin/bash
set -e

cd "$(dirname "$0")"/..
source common/perf_stubs.sh

set -x

if ! [ -S /nix/var/nix/daemon-socket/socket ] || ! (echo "" | nc -U /nix/var/nix/daemon-socket/socket); then
  curl -L https://nixos.org/nix/install | sh -s -- --daemon
fi

if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  # shellcheck disable=SC1090,SC1091
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

if [[ $DOTFILES_PROFILE == minimal ]]; then
  # TODO(kaihowl) twice impure
  bash -c 'nix run --impure .#home-manager -- --impure switch --flake .#minimal'
else
  bash -c 'nix run --impure .#home-manager -- --impure switch --flake .#full'
fi

# Create / update GC root
nix develop --impure --profile ~/.nix-dotfiles-gc-root --command bash -c 'exit'

# Run garbage collection
nix-collect-garbage --delete-older-than 30d

closure_size=$(nix path-info -S ~/.nix-profile/ | awk '{print $2}')
add_measurement 'nix-closure-size' "$closure_size"
