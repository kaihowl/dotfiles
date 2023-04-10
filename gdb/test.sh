#!/bin/bash
set -ex

if [ "$(uname)" == "Darwin" ]; then
  # Not needed on macOS with default lldb as the debugger
  exit 0
fi

# Example output:
#   GNU gdb (Ubuntu 10.2-0ubuntu1~20.04~1) 10.2
version=$(gdb --version | awk 'NR==1 {print $(NF)}')

# If version is smaller than 3.10
if [ "$(printf "%s\n3.10" "${version}" | sort -V | head -n 1)" != "3.10" ]; then
  echo "gdb version should have been at least 3.10 but was ${version}."
  exit 1
fi

exit 1

cd "$(mktemp -d)"

clang++ -std=c++17 -O0 -g3 -o mytest "${DOTS}/gdb/mytest.cpp"
gdb --batch -x "${DOTS}/gdb/test.gdb" -ex=quit mytest &> test.log
if ! grep -F '[2] = "mystuff"' test.log; then
  echo Failed
  cat test.log
  exit 1
fi
