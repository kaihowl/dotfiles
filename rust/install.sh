#!/bin/bash
set -ex

download_url="https://sh.rustup.rs"
expect_hash="41262c98ae4effc2a752340608542d9fe411da73aca5fbe947fe45f61b7bd5cf"

file_name=rustup-sh-1

source "$DOTS/common/download.sh"
cache_file "$file_name" "$download_url" "$expect_hash"

rustupinit="$(cache_path "${file_name}")"
chmod +x "${rustupinit}"
"${rustupinit}" -y --verbose --component rust-analyzer
# shellcheck disable=SC1091
source "$HOME/.cargo/env"
ln -sf "$(rustup which rust-analyzer)" "$HOME/.cargo/bin/"
chmod +x "$HOME/.cargo/bin/rust-analyzer"
