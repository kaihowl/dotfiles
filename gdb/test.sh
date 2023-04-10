#!/bin/bash
set -ex

if [ "$(uname)" == "Darwin" ]; then
  # Not needed on macOS with default lldb as the debugger
  exit 0
fi

gdb --version

exit 1

cd "$(mktemp -d)"

clang++ -std=c++17 -O0 -g3 -o mytest "${DOTS}/gdb/mytest.cpp"
gdb --batch -x "${DOTS}/gdb/test.gdb" -ex=quit mytest &> test.log
if ! grep -F '[2] = "mystuff"' test.log; then
  echo Failed
  cat test.log
  exit 1
fi
