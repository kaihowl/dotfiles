#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

source "${SCRIPT_DIR}/../common/utilities.sh"

mkdir -p ~/.ssh/controlmasters

touch ~/.ssh/config
sed_replace_in_file ~/.ssh/config "# dotfiles customization" "include ~/.ssh/config_dotfiles # dotfiles customization"
