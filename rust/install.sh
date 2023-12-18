#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

version=2
download_url="https://sh.rustup.rs"
expect_hash="be3535b3033ff5e0ecc4d589a35d3656f681332f860c5fd6684859970165ddcc"

file_name=rustup-sh-${version}

source "${SCRIPT_DIR}/../common/download.sh"
cache_file "$file_name" "$download_url" "$expect_hash"

rustupinit="$(cache_path "${file_name}")"
chmod +x "${rustupinit}"
"${rustupinit}" -y --verbose --component rust-analyzer
# shellcheck disable=SC1091
source "$HOME/.cargo/env"
ln -sf "$(rustup which rust-analyzer)" "$HOME/.cargo/bin/"

