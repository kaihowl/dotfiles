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
  download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v0.8.0/zoxide-v0.8.0-x86_64-apple-darwin.tar.gz"
  expect_hash="296f5b95db461ae8c081ab43b337362a4389bdbc289d1107753baf5676466b77"
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  download_url="https://github.com/ajeetdsouza/zoxide/releases/download/v0.8.0/zoxide-v0.8.0-x86_64-unknown-linux-musl.tar.gz"
  expect_hash="cbf4044be68c901f0fb29b7511fd8c645f466afba0e98a6ca6d9d21ab932f41b"
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

# Fix up man page structure for man AUTOPATH
# See https://github.com/ajeetdsouza/zoxide/issues/319
mkdir -p ~/.zoxide/man/man1
mv ~/.zoxide/man/*.1 ~/.zoxide/man/man1
