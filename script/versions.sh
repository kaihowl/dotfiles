#!/bin/bash

if [ $# != 1 ]; then
  echo Missing output file argument
  exit 1
fi

output_file=$1
echo "output to $output_file"

# Need to have proper PATH
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  # shellcheck disable=SC1091
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# TODO use nix-env reporting
