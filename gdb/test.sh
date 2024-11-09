#!/bin/bash
set -e

if [ "$(uname)" == "Darwin" ]; then
  # Not needed on macOS with default lldb as the debugger
  exit 0
fi

echo "Check if gdb is nix controlled"
actual_path=$(realpath "$(which gdb)")
if [[ "${actual_path}" != /nix/store/* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected gdb to be managed by nix
  exit 1
fi

# Example output:
#   GNU gdb (Ubuntu 10.2-0ubuntu1~20.04~1) 10.2
version=$(gdb --version | awk 'NR==1 {print $(NF)}')

# If version is smaller than 3.10
if [ "$(printf "%s\n10.2" "${version}" | sort -V | head -n 1)" != "10.2" ]; then
  echo "gdb version should have been at least 10.2 but was ${version}."
  exit 1
fi

cd "$(mktemp -d)"

clang++ -std=c++17 -O0 -g3 -o mytest "${DOTS}/gdb/mytest.cpp"
gdb --batch -x "${DOTS}/gdb/test.gdb" -ex=quit mytest &> test.log
if ! grep -F '[2] = "mystuff"' test.log; then
  echo Failed
  cat test.log
  exit 1
fi
