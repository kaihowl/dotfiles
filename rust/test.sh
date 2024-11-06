#!/usr/bin/env zsh
set -e

echo "Check if rustc is on path"
which rustc

echo "Check if rustc is runnable"
rustc --version

echo "Check if cargo is on path"
which cargo

echo "Check if cargo is runnable"
cargo --version

echo "Check if rust-analyzer is on path"
which rust-analyzer

echo "Check if rust-analyzer is runnable"
rust-analyzer --version
