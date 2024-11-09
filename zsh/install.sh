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


# Replace `chsh` with a fail-safe profile/exec dance:
# When /bin/sh -> /bin/bash or /bin/zsh are the default shells on the system,
# starting a login shell with source ~/.bash_profile or ~/.zprofile respectively.
# In those places dry-run the nix-managed zsh to ensure it works. If so, exec it.
# In case it fails, we fall back to the login shell.
# This will not affect the hot path (tmux creating a new pane) as the default shell
# for tmux is determined from the SHELL variable when the server is first started.
# The server is started AFTER the initial profile dance concluded.
#
# HOW TO TEST
# - Check that /bin/bash, /bin/sh, and /bin/zsh as login shells start up right:
# `env -u SHELL /bin/bash -il`
# - All these invocations should result in a ZSH shell running.
# Check with
# `ps -p $$ -o 'comm='`
# - There should be no infitite recursions.
# - when exiting the login shell, it should exit cleanly.
#   - There should be no need to doubly exit the shell.

source "$SCRIPT_DIR/../common/utilities.sh"

nixzsh=$(which zsh)

touch ~/.bash_profile
sed_replace_in_file ~/.bash_profile "# fail-safe exec" "${nixzsh} --version >/dev/null && SHELL=${nixzsh} exec ${nixzsh} # fail-safe exec"

touch ~/.zprofile
sed_replace_in_file ~/.zprofile "# fail-safe exec" "[[ \$SHELL != $nixzsh ]] && ${nixzsh} --version >/dev/null && SHELL=${nixzsh} exec ${nixzsh} # fail-safe exec"
