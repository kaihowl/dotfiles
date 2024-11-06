#!/usr/bin/env zsh
set -e

echo "Check if git is installed"
which git

echo "Check if git is runnable"
git --version

echo "Ensure git is >= 2.34.0 to support ssh signing"
git --version
version=$(git --version 2>&1 | cut -d' ' -f3)
echo "${version}"

# If version is smaller than 2.34.0
if [ "$(printf "%s\n2.34.0" "${version}" | sort -V | head -n 1)" != "2.34.0" ]; then
  echo "Version too old, ssh signing not supported"
  echo "Version is ${version}"
  echo "You need at least 2.34.0"
  exit 1
fi
