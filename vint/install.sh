#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

source "${SCRIPT_DIR}/../common/python.sh"
install_in_nvim_virtualenv "vim-vint"

