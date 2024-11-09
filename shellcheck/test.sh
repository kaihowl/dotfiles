#!/usr/bin/env -S zsh -il
set -e

echo "Check if shellcheck is on path"
which shellcheck

echo "Check if shellcheck is runnable"
shellcheck --version

echo "Check if shellcheck is user-installed one"
actual_path=$(realpath "$(which shellcheck)")
if [[ "${actual_path}" != /nix/store/* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected shellcheck to be managed by nix
  exit 1
fi
