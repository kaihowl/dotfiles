#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

source "${SCRIPT_DIR}/../common/python.sh"

# Install autopep8 to activate optional source formatting in pyls
install_in_virtualenv "python-lsp-server[all]"
install_in_virtualenv "pyls-black"
