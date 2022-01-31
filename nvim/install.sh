#!/bin/bash
set -ex

if [ "$(uname -s)" = "Darwin" ]; then
  download_url="https://github.com/neovim/neovim/releases/download/v0.6.1/nvim-macos.tar.gz"
  expect_hash="3546be6a13f45411731dc4c93b0932f7d6197b4318ea082cafe7b28d843248f9"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/neovim/neovim/releases/download/v0.6.1/nvim-linux64.tar.gz"
  expect_hash="06f1c19b09dd8cc63f970ef7edab8fa3850a154c296f453393d00854f514a847"
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

nvim -u NONE --headless -c 'let g:first_time_startup=1' -c 'source ~/.config/nvim/init.vim' +PlugUpgrade +PlugUpdate +qall
