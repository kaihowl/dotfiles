#!/usr/bin/env zsh
set -e

echo "Check if efm-langserver is on path"
which efm-langserver

echo "Check if efm-langserver is runnable"
efm-langserver -v

echo "Check if efm-langserver is user-installed one"
actual_path=$(realpath "$(which efm-langserver)")
if [[ "${actual_path}" != $(realpath ~/.efm/)* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected to be in ~/.efm/ instead
  exit 1
fi

echo "Check if efm-langserver has shellcheck config"
config=$(efm-langserver -d)
if [[ "${config}" != *"shellcheck"* ]]; then
  echo "Expected the following config to contain 'shellcheck'"
  echo "${config}"
  exit 1
fi

echo "Check if efm-langserver has zsh config"
config=$(efm-langserver -d)
if [[ "${config}" != *"zsh"* ]]; then
  echo "Expected the following config to contain 'zsh'"
  echo "${config}"
  exit 1
fi

