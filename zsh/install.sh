#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

cd "$(dirname "$0")"

if [ "$(uname -s)" = "Darwin" ]; then
  source "${SCRIPT_DIR}/../common/brew.sh"
  brew_install zsh
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "${SCRIPT_DIR}/../common/apt.sh"
  # Install 'expect' for testing
  apt_install zsh expect
fi

if ! command -v git > /dev/null; then
  "${SCRIPT_DIR}/../git/install.sh"
fi

if [ ! -d ~/.powerlevel10k ]; then
  git clone https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k --depth=1
fi
(cd ~/.powerlevel10k && git pull --rebase)

if [ ! -d ~/.zsh-autocomplete ]; then
  git clone https://github.com/marlonrichert/zsh-autocomplete.git ~/.zsh-autocomplete --depth=1
fi
(cd ~/.zsh-autocomplete && git pull --rebase)

if [ ! -d ~/.zsh-autosuggestions ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh-autosuggestions --depth=1
fi
(cd ~/.zsh-autosuggestions && git pull --rebase)

if [ ! -d ~/.powerlevel10k ]; then
  git clone https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k --depth=1
fi
(cd ~/.powerlevel10k && git pull --rebase)

if [ ! -d ~/.zsh-z ]; then
  git clone https://github.com/agkozak/zsh-z.git ~/.zsh-z --depth=1
fi
(cd ~/.zsh-z && git pull --rebase)

if (grep -q '/bin/zsh' /etc/shells) && [[ -x /bin/zsh ]]; then
  if [[ "${CI}" == "true" ]]; then
    echo "Running on CI, not changing login shell"
  else
    # Allow for unattended upgrade
    sudo chsh -s "$(which zsh)" "$(whoami)"
  fi
fi

