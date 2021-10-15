#!/bin/zsh -ex

echo "Check if startup is sufficiently fast"
measure-runtime.py --repeat=10 --expected-ms 250 zsh -i -c 'exit'
