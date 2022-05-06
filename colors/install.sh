#!/bin/bash
set -e

# Depends on an installed zsh for using zparseopts in change-color
"$DOTS/zsh/install.sh"

"$DOTS/colors/change-color"
