#!/bin/zsh -i
set -ex

echo "Check if git is installed"
which git

echo "Ensure git is >= 2.34.0 to support ssh signing"
git --version
version=$(git --version 2>&1 | cut -d' ' -f3)
echo $version

# If version is smaller than 2.34.0
if [ $(echo "${version}\n2.34.0" | sort -V | head -n 1) != "2.34.0" ]; then
  echo "Version too old, ssh signing not supported"
  echo "Version is ${version}"
  echo "You need at least 2.34.0"
  exit 1
fi
