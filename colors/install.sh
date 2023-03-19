#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

# Depends on an installed zsh for using zparseopts in change-color
"${SCRIPT_DIR}/../zsh/install.sh"

"${SCRIPT_DIR}/../colors/change-color"
