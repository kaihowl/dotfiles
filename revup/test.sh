#!/usr/bin/env -S zsh -il
set -e

echo "Check that 'revup' is on the path"
which revup

echo "Check if revup is nix controlled"
actual_path=$(realpath "$(which revup)")
if [[ "${actual_path}" != /nix/store/* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected revup to be managed by nix
  exit 1
fi

echo "Check that the pr body is not updated by default"
current_config=$(revup --verbose upload --dry-run | grep 'update_pr_body')
if [[ $current_config != *false* ]]; then
  echo "Expected revup to not update the PR body on upload"
  echo "Current config is: '$current_config'"
  exit 1
fi
