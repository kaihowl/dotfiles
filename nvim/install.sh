#!/bin/bash
set -ex

if [ "$(uname -s)" = "Darwin" ]; then
  download_url="https://github.com/neovim/neovim/releases/download/v0.8.3/nvim-macos.tar.gz"
  expect_hash="26326708f34ead29e770514c2fb307702102166339c8f31660f7259ce9032925"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/neovim/neovim/releases/download/v0.8.3/nvim-linux64.tar.gz"
  expect_hash="58ac03b345e8675e13322f8c7135906ce26a1ca7a87d041344d64b207be7bedf"
fi

tmpfile=$(mktemp)
# shellcheck disable=SC2064
trap "rm -rf ${tmpfile}" EXIT
curl -Lo "${tmpfile}" "${download_url}"
actual_hash="$(shasum -a 256 "${tmpfile}" | cut -d' ' -f 1)"
if [[ "$expect_hash" != "$actual_hash" ]]; then
  echo "shasum mismatch for nvim. Aborting."
  exit 1
fi
mkdir -p ~/.nvim
tar -C ~/.nvim --extract -z -f "${tmpfile}" --strip-components 1

# Make freshly installed nvim available in path
script_dir=$(dirname "$0")
. "${script_dir}/path.zsh"

source "$DOTS/common/python.sh"
install_in_virtualenv pynvim

# update packages in Plug
# install plug if not already installed
plug_dir="${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim
if [ ! -d "$plug_dir" ]; then
  curl -fLo "${plug_dir}" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

nvim -u NONE --headless -c 'let g:first_time_startup=1' -c 'source ~/.config/nvim/init.vim' +PlugUpgrade '+PlugClean!' '+PlugUpdate!' +qall
