#!/bin/bash
set -e

/nix/var/nix/profiles/default/bin/nix-env --install tree jq htop ncdu tree

# TODO WHY????
# automake libtool pkg-config
