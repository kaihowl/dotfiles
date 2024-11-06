#!/usr/bin/env zsh
set -e

echo "Test that start up and basic user input to shell work without errors"
# This was added after a faulty linter change led to printing the following on all key presses
# sh:1: url-quote-magic: function definition file not found
expect -c "strace 4" "$DOTS/zsh/userinput.test.expect"

# shellcheck disable=SC1090
source ~/.zshrc

echo "Check that ctrl-z is registered"
bindkey | grep -i '^"\^Z'
