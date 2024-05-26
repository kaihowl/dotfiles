#!/bin/bash
set -e

SCRIPT_DIR=$(unset CDPATH; cd "$(dirname "$0")" > /dev/null; pwd -P)

version=4
download_url="https://sh.rustup.rs"
# Compare with https://github.com/rust-lang/rustup/blob/master/rustup-init.sh
expect_hash="32a680a84cf76014915b3f8aa44e3e40731f3af92cd45eb0fcc6264fd257c428"

file_name=rustup-sh-${version}

source "${SCRIPT_DIR}/../common/download.sh"
cache_file "$file_name" "$download_url" "$expect_hash"

rustupinit="$(cache_path "${file_name}")"
chmod +x "${rustupinit}"
"${rustupinit}" -y --verbose --component rust-analyzer
# shellcheck disable=SC1091
source "$HOME/.cargo/env"
ln -sf "$(rustup which rust-analyzer)" "$HOME/.cargo/bin/"

