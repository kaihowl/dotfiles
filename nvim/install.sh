#!/bin/bash -ex

if [ "$(uname -s)" = "Darwin" ]; then
  tmpfile=$(mktemp)
  trap "rm -rf ${tmpfile}" EXIT
  curl -Lo "${tmpfile}" https://github.com/neovim/neovim/releases/download/v0.6.0/nvim-macos.tar.gz
  expect_hash="03cdbfeec3493f50421a9ae4246abe4f9493715f5e151a79c4db79c5b5a43acc"
  actual_hash="$(shasum -a 256 ${tmpfile} | cut -d' ' -f 1)"
  if [[ "$expect_hash" != "$actual_hash" ]]; then
    echo "shasum mismatch for nvim. Aborting."
    exit 1
  fi
  mkdir -p ~/.nvim
  tar -C ~/.nvim --extract -z -f "${tmpfile}" --strip-components 1

  # Make freshly installed nvim available in path
  script_dir=$(dirname $0)
  . ${script_dir}/path.zsh
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  # Remove old installs
  sudo snap remove nvim
  # Add install via ppa
  sudo add-apt-repository --yes --update ppa:neovim-ppa/unstable
  source $DOTS/common/apt.sh
  apt_install neovim
  # Stable clipboard support
  apt_install --no-install-recommends xclip
fi

source $DOTS/common/pip.sh
ensure_pip_installed
sudo python3 -m pip install --upgrade pynvim

# update packages in Plug
# install plug if not already installed
plug_dir="${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim
if [ ! -d "$plug_dir" ]; then
  curl -fLo "${plug_dir}" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
nvim --headless +PlugUpdate +qall

