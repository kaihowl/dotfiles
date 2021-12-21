#!/bin/bash
set -ex

if [ "$(uname -s)" = "Darwin" ]; then
  download_url="https://github.com/neovim/neovim/releases/download/v0.6.0/nvim-macos.tar.gz"
  expect_hash="03cdbfeec3493f50421a9ae4246abe4f9493715f5e151a79c4db79c5b5a43acc"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/neovim/neovim/releases/download/v0.6.0/nvim-linux64.tar.gz"
  expect_hash="9a7f72e25747c3839f2c8978ef4f902aada0c60ad4b5ff0cb8b9d4c1f0b35586"
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

source "$DOTS/common/pip.sh"
ensure_pip_installed
sudo python3 -m pip install --upgrade pynvim

# update packages in Plug
# install plug if not already installed
plug_dir="${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim
if [ ! -d "$plug_dir" ]; then
  curl -fLo "${plug_dir}" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
nvim --headless +PlugUpgrade +PlugUpdate +qall

