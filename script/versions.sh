#!/bin/zsh -i
set -eu
set -o pipefail

if [ $# != 1 ]; then
  echo Missing output file argument
  exit 1
fi

output_file=$1
echo "output to $output_file"

echo "" > "$output_file"

if [[ "$(uname)" == "Darwin" ]]; then
  echo "brew installed:" >> "$output_file"
  brew info --installed --json | jq '.[] | .name + "@" + .installed[0].version' | tee -a "$output_file"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  echo "apt installed:" >> "$output_file"
  # Not using `apt list --installed` as apt does not have a stable interface
  dpkg-query --show | tee -a "$output_file"
fi

tmp_file=$(mktemp)
trap 'rm -rf $tmp_file' EXIT
nvim --headless "+PlugSnapshot! $tmp_file" +qall

{ echo "nvim plugins installed:"; cat "$tmp_file"; } >> "$output_file"

{ echo "pip packages installed:"; python3 -m pip list; } >> "$output_file"
