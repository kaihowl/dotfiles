#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

version=0.10.1

if [ "$(uname -s)" = "Darwin" ]; then
  if [ "$(uname -m)" = "arm64" ]; then
    download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-macos-arm64.tar.gz"
    expect_hash="4b322a8da38f0bbdcdcc9a2b224a7b5267f0b1610b7345cb880d803e03bb860b"
  else
    download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-macos-x86_64.tar.gz"
    expect_hash="dd88c86164e6fb34ee364c4a2b42c6a1832890003ae7c9c733032697d92cf7a6"
  fi
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-linux64.tar.gz"
  expect_hash="4867de01a17f6083f902f8aa5215b40b0ed3a36e83cc0293de3f11708f1f9793"
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
