#!/bin/bash
#!/bin/bash
set -ex

# Remove old autojump installation.
# Otherwise old "j" compdef might still be sourced and conflicts with the zoxide definition.
if [ "$(uname -s)" = "Darwin" ]; then
  source "$DOTS/common/brew.sh"
  brew_remove autojump
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  source "$DOTS/common/apt.sh"
  apt_remove autojump
fi

if [ "$(uname -s)" = "Darwin" ]; then
  download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v0.8.3/zoxide-0.8.3-x86_64-apple-darwin.tar.gz"
  expect_hash="c9000934d28d8c7de0130a1eade8152e37ae4bf521ed1b2df90d362cb1ed1611"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v0.8.3/zoxide-0.8.3-x86_64-unknown-linux-musl.tar.gz"
  expect_hash="a3fea067a719b921881bdcde81b52c5ad1017bd39f835b3684f91ddfbb596d8f"
fi

tmpfile=$(mktemp)
# shellcheck disable=SC2064
trap "rm -rf ${tmpfile}" EXIT
curl -Lo "${tmpfile}" "${download_url}"
actual_hash="$(shasum -a 256 "${tmpfile}" | cut -d' ' -f 1)"
if [[ "$expect_hash" != "$actual_hash" ]]; then
  echo "shasum mismatch for zoxide. Aborting."
  exit 1
fi
mkdir -p ~/.zoxide
tar -C ~/.zoxide --extract -z -f "${tmpfile}"
