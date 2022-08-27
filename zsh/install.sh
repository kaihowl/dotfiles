#!/bin/bash
set -ex

checkout_path=~/.oh-my-zsh

cd "$(dirname "$0")"

if [ "$(uname -s)" = "Darwin" ]; then
  source "$DOTS/common/brew.sh"
  brew_install zsh
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "$DOTS/common/apt.sh"
  # Install 'expect' for testing
  apt_install zsh expect
fi

if [ -d "$checkout_path" ]; then
  if [[ "${ZSH}" == "" ]]; then
    # Older zsh templates did not export ZSH var
    export ZSH=$checkout_path
  fi
  zsh -i -e -c "omz update --unattended"
else
  ../git/install.sh
  git clone https://github.com/ohmyzsh/ohmyzsh.git $checkout_path
fi

if (grep -q '/bin/zsh' /etc/shells) && [[ -x /bin/zsh ]]; then
  if [[ "${CI}" == "true" ]]; then
    echo "Running on CI, not changing login shell"
  else
    # Allow for unattended upgrade
    sudo chsh -s "$(which zsh)" "$(whoami)"
  fi
fi

