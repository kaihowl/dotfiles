#!/bin/zsh
set -ex

echo "Test that start up and basic user input to shell work without errors"
# This was added after a faulty linter change led to printing the following on all key presses
# sh:1: url-quote-magic: function definition file not found
expect -c "strace 4" "$DOTS/zsh/userinput.test.expect"


echo "Check if startup is sufficiently fast"
measure-runtime.py --repeat=10 --expected-ms 300 zsh -i -c 'exit'
