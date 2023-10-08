#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

if ! command -v git > /dev/null; then
  "${SCRIPT_DIR}/../git/install.sh"
fi

if [ ! -d ~/.zsh-autocomplete ]; then
  git clone https://github.com/marlonrichert/zsh-autocomplete.git ~/.zsh-autocomplete --depth=1
fi

(cd ~/.zsh-autocomplete && git pull --rebase)
