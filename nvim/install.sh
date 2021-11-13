#!/bin/bash -ex

source $DOTS/common/brew.sh

if [ "$(uname -s)" = "Darwin" ]; then
  # If this installed version crashes, install from source instead.
  brew_head_install neovim
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

