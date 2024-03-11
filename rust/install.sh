#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

version=3
download_url="https://sh.rustup.rs"
expect_hash="7b826d2c84318cf44897da29225cb9bc0b4e859b05568b5979bf2cc264840d05"

file_name=rustup-sh-${version}

source "${SCRIPT_DIR}/../common/download.sh"
cache_file "$file_name" "$download_url" "$expect_hash"

rustupinit="$(cache_path "${file_name}")"
chmod +x "${rustupinit}"
"${rustupinit}" -y --verbose --component rust-analyzer
# shellcheck disable=SC1091
source "$HOME/.cargo/env"
ln -sf "$(rustup which rust-analyzer)" "$HOME/.cargo/bin/"

