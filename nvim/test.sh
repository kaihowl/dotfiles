#!/bin/zsh -i
set -ex

echo "Check if nvim is available"
which nvim

echo "Check if vim alias is set"
which vim

echo "Check if nvim is user-installed one"
actual_path=$(realpath "$(which nvim)")
if [[ "${actual_path}" != $(realpath ~/.nvim/bin)* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected to be in ~/.nvim/bin instead
  exit 1
fi

echo "Check that all test scripts are called afterwards in this script"
found_tests=$(find "$(realpath "$(dirname "$0")")" -name '*.test.vim' | wc -l)
registered_tests=$(grep -c '\-s .*\.test\.vim' "$0")
if [[ found_tests -ne registered_tests ]]; then
  echo "Expected number of tests: ${found_tests}"
  echo "Actual number of tests: ${registered_tests}"
  exit 1
fi

echo "Check that plugins are installed"
nvim --headless -s "$DOTS/nvim/tagbar.test.vim"
nvim --headless -s "$DOTS/nvim/lsp-clangd.test.vim"
nvim --headless -s "$DOTS/nvim/lsp-pyls.test.vim"
nvim --headless -s "$DOTS/nvim/completion.test.vim"
nvim --headless -s "$DOTS/nvim/sneak.test.vim"
nvim --headless -s "$DOTS/nvim/t_comment.test.vim"
nvim --headless -s "$DOTS/nvim/restorecurpos.test.vim"
nvim --headless -s "$DOTS/nvim/nvim-cmp-select-enter.test.vim"
cd "$DOTS/test-editorconfig/" && nvim --headless -s "$DOTS/nvim/editorconfig.test.vim"
cd "$DOTS/nvim/test-ripgrep/" && nvim --headless -s "$DOTS/nvim/ripgrep.test.vim"
cd "$DOTS/nvim/test-efm/" && nvim --headless -s "$DOTS/nvim/lsp-efm.test.vim"

echo "Check that git default folder detection works with a default"
cd "$DOTS/"
output=$(nvim --headless -c "echo Get_default_branch()" -c 'quit' 2>&1)
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
git commit -m 'test'
git branch -M specialdefault
cd ..
git clone "source" "target"
cd target
output=$(nvim --headless -c "echo Get_default_branch()" -c 'quit' 2>&1)
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
git commit -m 'test'
git branch -M specialdefault
cd ..
mkdir modules
cd modules
git init
git submodule add ../source
git commit -m 'test'
# pwd == main repo but open file in submodule
# TODO(kaihowl) remove
stat source/a
output=$(nvim "source/a" --headless -c "echo Get_default_branch()" -c 'quit' 2>&1)
if [[ "$output" != *"origin/specialdefault" ]]; then
  echo "Detected wrong default branch, should have been origin/specialdefault but was"
  echo "$output"
  exit 1
fi

echo "Check if startup is sufficiently fast"
measure-runtime.py --repeat=10 --expected-ms 250 nvim +qall
