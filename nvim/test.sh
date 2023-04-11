#!/bin/zsh -i
set -euo pipefail

echo "Check if nvim is available"
which nvim

echo "Check if nvim is runnable"
nvim --version

echo "Check if vim alias is set"
which vim

echo "Check if nvim is user-installed one"
actual_path=$(realpath "$(which nvim)")
if [[ "${actual_path}" != $(realpath ~/.nvim/bin)* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected to be in ~/.nvim/bin instead
  exit 1
fi

echo "Check health for errors"
health_file=$(mktemp)
trap 'rm -rf $health_file' EXIT
nvim --headless +checkhealth "+write! $health_file" +qa!
if [[ $(wc -l < "$health_file") -eq 0 ]]; then
  echo "Health output is empty"
  exit 1
fi
cat "$health_file"
# Find all errors but exclude the optional node provider failure
if grep -ie 'error' "$health_file" | grep -vie 'node -v'; then
  echo "Found errors in health file"
  exit 1
fi

echo "Check that all test scripts are called afterwards in this script"
found_tests=$(find "$(realpath "$(dirname "$0")")" -name '*.test.vim' | wc -l)
registered_tests=$(grep -c 'run_vim_test .*test\.vim' "$0")
if [[ found_tests -ne registered_tests ]]; then
  echo "Expected number of tests: ${found_tests}"
  echo "Actual number of tests: ${registered_tests}"
  exit 1
fi

function run_vim_test {
  echo "Running $1"
  (set -e && cd "$DOTS/nvim/tests" && nvim --headless -c "source $DOTS/nvim/tests/test-support.vim" -c "source $DOTS/nvim/tests/$1" -c "call RunTest()")
}

echo "Check that plugins are installed"
run_vim_test completion.test.vim
run_vim_test editorconfig.test.vim
run_vim_test lsp-completion-cpp.test.vim
run_vim_test lsp-completion-python.test.vim
run_vim_test lsp-completion-rust.test.vim
run_vim_test lsp-efm.test.vim
run_vim_test nvim-cmp-select-enter.test.vim
run_vim_test restorecurpos.test.vim
run_vim_test sanitizer-errorformat.test.vim
run_vim_test sneak.test.vim
run_vim_test tagbar.test.vim
run_vim_test t_comment.test.vim
run_vim_test asyncrun-errorformat.test.vim
run_vim_test asynctasks.test.vim

echo "Check that git default folder detection works with a default"
cd "$DOTS/"
output=$(nvim --headless -c 'call stdioopen({})' -c 'call chansend(1, Get_default_branch())' -c 'quit')
if [[ "$output" != *"origin/master" ]]; then
  echo "Detected wrong default branch, should have been origin/master but was"
  echo "$output"
  exit 1
fi

echo "Check that git default folder detection works"
cdtmp
mkdir "source"
cd "source"
git init
touch a
git add a
git commit --no-gpg-sign -m 'test'
git branch -M specialdefault
cd ..
git clone "source" "target"
cd target
output=$(nvim --headless -c 'call stdioopen({})' -c 'call chansend(1, Get_default_branch())' -c 'quit')
if [[ "$output" != *"origin/specialdefault" ]]; then
  echo "Detected wrong default branch, should have been origin/specialdefault but was"
  echo "$output"
  exit 1
fi

echo "Check that git default folder detection works with submodules"
cdtmp
mkdir "source"
cd "source"
git init
touch a
git add a
git commit --no-gpg-sign -m 'test'
git branch -M specialdefault
cd ..
mkdir modules
cd modules
git init
git -c protocol.file.allow=always submodule add ../source
git commit --no-gpg-sign -m 'test'
# pwd == main repo but open file in submodule
output=$(nvim --headless -c 'call stdioopen({})' -c "edit source/a" -c 'call chansend(1, Get_default_branch())' -c 'quit')
if [[ "$output" != *"origin/specialdefault" ]]; then
  echo "Detected wrong default branch, should have been origin/specialdefault but was"
  echo "$output"
  exit 1
fi
