#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

# Depends on an installed zsh for using zparseopts in change-color
if ! command -v zsh > /dev/null; then
  "${SCRIPT_DIR}/../zsh/install.sh"
fi

"${SCRIPT_DIR}/../colors/bin/change-color"
