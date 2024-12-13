#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

source "$SCRIPT_DIR/../common/utilities.sh"

touch ~/.gitconfig

sed_replace_in_file ~/.gitconfig "# dotfiles" "[include] path=~/.gitconfig_dotfiles # dotfiles"
