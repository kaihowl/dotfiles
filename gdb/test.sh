#!/bin/bash -ex

if [ "$(uname)" == "Darwin" ]; then
  # Not needed on macOS with default lldb as the debugger
  exit 0
fi

cd $(mktemp -d)

clang++ -std=c++17 -O0 -g3 -o mytest ${DOTS}/gdb/mytest.cpp
gdb -x ${DOTS}/gdb/test.gdb mytest &> test.log
grep -F 'std::unordered_map with 1 element = {[2] = "mystuff"}' test.log
