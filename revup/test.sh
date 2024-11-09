#!/usr/bin/env -S zsh -il
set -e

echo "Check that 'revup' is on the path"
which revup

echo "Check that the pr body is not updated by default"
current_config=$(revup --verbose upload --dry-run | grep 'update_pr_body')
if [[ $current_config != *false* ]]; then
  echo "Expected revup to not update the PR body on upload"
  echo "Current config is: '$current_config'"
  exit 1
fi
