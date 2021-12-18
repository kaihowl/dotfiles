#!/bin/zsh
# shellcheck shell=bash
set -e

echo "Check if efm-langserver is on path"
which efm-langserver

echo "Check if efm-langserver is user-installed one"
actual_path=$(realpath "$(which efm-langserver)")
if [[ "${actual_path}" != $(realpath ~/.efm/)* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected to be in ~/.efm/ instead
  exit 1
fi

