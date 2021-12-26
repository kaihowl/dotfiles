#!/bin/bash
set -e

source "$DOTS/common/pip.sh"
ensure_pip_installed

sudo python3 -m pip install --upgrade "vim-vint"

