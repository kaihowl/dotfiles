#!/usr/bin/env -S zsh -il
set -e

echo "Check if zsh is nix controlled"
actual_path=$(realpath "$(which zsh)")
if [[ "${actual_path}" != /nix/store/* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected zsh to be managed by nix
  exit 1
fi

echo "Test that zshrc can be sourced without errors"
# shellcheck disable=SC1090
zsh -c 'set -e; source ~/.zshrc'

echo "Test that start up and basic user input to shell work without errors"
# This was added after a faulty linter change led to printing the following on all key presses
# sh:1: url-quote-magic: function definition file not found
# Could only get test passing on macOS.
if [[ "$(uname)" == "Darwin" ]]; then
  timeout 10s expect -c "strace 4" "$DOTS/zsh/userinput.test.expect"
fi

echo "Check that ctrl-z is registered"
bindkey | grep -i '^"\^Z'
