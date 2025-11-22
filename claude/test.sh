#!/usr/bin/env -S zsh -il
set -e

echo "Check if Claude settings symlink exists"
if [[ ! -L ~/.claude/settings.json ]]; then
  echo "Expected ~/.claude/settings.json to be a symlink"
  exit 1
fi

echo "Check if Claude settings symlink points to dotfiles"
target=$(readlink ~/.claude/settings.json)
if [[ "${target}" != *"dotfiles"*"claude"*"settings.json"* ]]; then
  echo "Expected ~/.claude/settings.json to point to dotfiles claude settings"
  echo "Actual target: ${target}"
  exit 1
fi

echo "Check if Claude settings file is readable"
if [[ ! -r ~/.claude/settings.json ]]; then
  echo "Expected ~/.claude/settings.json to be readable"
  exit 1
fi

echo "Check if Claude settings file contains expected permissions structure"
if ! grep -q '"permissions"' ~/.claude/settings.json; then
  echo "Expected ~/.claude/settings.json to contain permissions structure"
  exit 1
fi

echo "Claude settings test passed"
