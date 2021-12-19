#!/bin/zsh
set -e

echo "Check if shellcheck is on path"
which shellcheck

echo "Check if shellcheck is user-installed one"
actual_path=$(realpath "$(which shellcheck)")
if [[ "${actual_path}" != $(realpath ~/.shellcheck/)* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected to be in ~/.shellcheck/ instead
  exit 1
fi
