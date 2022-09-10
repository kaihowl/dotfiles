#!/bin/bash
set -e

source "$DOTS/common/python.sh"

# Install autopep8 to activate optional source formatting in pyls
install_in_virtualenv "python-lsp-server[all]"
