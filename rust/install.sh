#!/bin/bash
set -e

/nix/var/nix/profiles/default/bin/nix-env --install rustup

PATH=~/.nix-profile/bin/:$PATH

rustup update
rustup component add rust-analyzer

# shellcheck disable=SC1091
source "$HOME/.cargo/env"
ln -sf "$(rustup which rust-analyzer)" "$HOME/.cargo/bin/"

