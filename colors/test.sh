#!/usr/bin/env zsh

set -e

echo "Test if change-color is available"
which change-color

echo "Check if change-color is runnable"
change-color

echo "Test if aliases are defined"
which dark
which light
