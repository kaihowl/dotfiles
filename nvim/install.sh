#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

version=0.10.0

if [ "$(uname -s)" = "Darwin" ]; then
  if [ "$(uname -m)" = "arm64" ]; then
    download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-macos-arm64.tar.gz"
    expect_hash="e00452adbe1e90fb8c2d9bd41855b3f585bf6e2db31b9c35456d6253b0a152dd"
  else
    download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-macos-x86_64.tar.gz"
    expect_hash="ac4dc050f83e8537cfad3cbaf61ca4e5870ed30a7d0187cdaa33f8fa421aca1f"
  fi
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/neovim/neovim/releases/download/v${version}/nvim-linux64.tar.gz"
  expect_hash="be1f0988d0de71c375982b87b86cd28d2bab35ece8285abe3b0aac57604dfc5a"
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
