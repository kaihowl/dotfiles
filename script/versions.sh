#!/bin/bash

if [ $# != 1 ]; then
  echo Missing output file argument
  exit 1
fi

output_file=$1
echo "output to $output_file"

echo "" > "$output_file"

# TODO use nix-env reporting

# Need to have proper PATH
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  # shellcheck disable=SC1091
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

tmp_file=$(mktemp)
trap 'rm -rf $tmp_file' EXIT
nvim --headless "+PlugSnapshot! $tmp_file" +qall

{ echo "nvim plugins installed:"; cat "$tmp_file"; } >> "$output_file"
