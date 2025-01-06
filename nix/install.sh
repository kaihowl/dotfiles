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

if [[ $DOTFILES_PROFILE == minimal ]]; then
  bash -c 'nix run --verbose home-manager/release-24.11 -- --impure switch --flake .#minimal -v | tee /tmp/nix.log'
else
  # TODO(kaihowl) remove the verbose in both invocations again
  bash -c 'nix run --verbose home-manager/release-24.11 -- --impure switch --flake .#full -v | tee /tmp/nix.log'
fi

# Run garbage collection
# nix-collect-garbage --delete-older-than 30d

closure_size=$(nix path-info -S ~/.nix-profile/ | awk '{print $2}')
add_measurement 'nix-closure-size' "$closure_size"
