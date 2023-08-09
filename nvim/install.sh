#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

version=0.9.1

if [ "$(uname -s)" = "Darwin" ]; then
  download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-macos.tar.gz"
  expect_hash="6f7de66c494d7b73cdf878f060dedd1b2d66a648a387a245aa2aec76a5b4c777"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-linux64.tar.gz"
  expect_hash="6c083017304213c3a3efde8d332a52231b8df8206d35146942097c303ebf93d5"
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

source "${SCRIPT_DIR}/../common/python.sh"
install_in_virtualenv pynvim

# update packages in Plug
# install plug if not already installed
plug_dir="${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim
if [ ! -d "$plug_dir" ]; then
  curl -fLo "${plug_dir}" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

nvim -u NONE --headless -c 'let g:first_time_startup=1' -c 'source ~/.config/nvim/init.vim' +PlugUpgrade '+PlugClean!' '+PlugUpdate!' +qall
