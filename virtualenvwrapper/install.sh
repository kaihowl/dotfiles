#!/bin/bash
set -e

/nix/var/nix/profiles/default/bin/nix-env --install python312Packages.virtualenvwrapper

source "${SCRIPT_DIR}/../common/utilities.sh"
# Using "sudo which" to bypass any user PATH prefixed python versions
sed_replace_in_file ~/.zprofile "^export VIRTUALENVWRAPPER_PYTHON.*$" "export VIRTUALENVWRAPPER_PYTHON=$(sudo which python3)"
