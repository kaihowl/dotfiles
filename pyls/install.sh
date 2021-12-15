#!/bin/bash
set -e

source "$DOTS/common/pip.sh"
ensure_pip_installed

# Install autopep8 to activate optional source formatting in pyls
sudo python3 -m pip install --upgrade "python-lsp-server[all]" autopep8
