#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

# TODO hack bring in PATH
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  # shellcheck disable=SC1091
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# Depends on an installed zsh for using zparseopts in change-color
if ! command -v zsh > /dev/null; then
  "${SCRIPT_DIR}/../zsh/install.sh"
fi

"${SCRIPT_DIR}/../colors/bin/change-color"
