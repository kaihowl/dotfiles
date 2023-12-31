#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

version=0.9.5

if [ "$(uname -s)" = "Darwin" ]; then
  download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-macos.tar.gz"
  expect_hash="19d2366e0d6da001583bd0b8a3db59f69ce3dda5fa41f3064c6778cef3edd34c"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-linux64.tar.gz"
  expect_hash="44ee395d9b5f8a14be8ec00d3b8ead34e18fe6461e40c9c8c50e6956d643b6ca"
fi

file_name=nvim-${version}.tar.gz

source "${SCRIPT_DIR}/../common/download.sh"
cache_file "$file_name" "$download_url" "$expect_hash"

# Ensure a clean install with no left behind files
rm -rf ~/.nvim
mkdir -p ~/.nvim
tar -C ~/.nvim --extract -z -f "$(cache_path "${file_name}")" --strip-components 1

# Make freshly installed nvim available in path
script_dir=$(dirname "$0")
. "${script_dir}/path.zsh"

# update packages in Plug
# install plug if not already installed
plug_dir="${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim
if [ ! -d "$plug_dir" ]; then
  curl -fLo "${plug_dir}" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

nvim -u NONE --headless -c 'let g:first_time_startup=1' -c 'source ~/.config/nvim/init.vim' +PlugUpgrade '+PlugClean!' '+PlugUpdate!' +qall
