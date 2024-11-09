#!/bin/bash
set -e

PATH=~/.nix-profile/bin/:$PATH

rustup update
rustup default stable
rustup component add rust-analyzer
