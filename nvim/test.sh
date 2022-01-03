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
registered_tests=$(($(grep -c 'nvim --headless' "$0") - 1))
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

echo "Check if startup is sufficiently fast"
measure-runtime.py --repeat=10 --expected-ms 250 nvim +qall
