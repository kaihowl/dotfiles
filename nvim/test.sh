#!/usr/bin/env -S zsh -il
set -euo pipefail

echo "Check if nvim is available"
which nvim

echo "Check if nvim is runnable"
nvim --version

echo "Check if vim alias is set"
which vim

echo "Check if efm is available"
which efm-langserver
efm-langserver -v

echo "Check if nvim is user-installed one"
actual_path=$(realpath "$(which nvim)")
if [[ "${actual_path}" != /nix/store/* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected nvim to be managed by nix
  exit 1
fi

echo "Check health for errors"
health_file=$(mktemp)
process_file=$(mktemp)
trap 'rm -rf $health_file' EXIT
nvim --headless +checkhealth "+write! $health_file" +qa! &> "$process_file"
if [[ $(wc -l < "$health_file") -eq 0 ]]; then
  echo "Health output is empty"
  exit 1
fi
echo "----- health -----"
cat "$health_file"
echo "----- process -----"
cat "$process_file"
echo "----- end -----"

# Find all errors
if grep -ie 'error' "$health_file" "$process_file"; then
  echo "Found errors in health or process file"
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

failed_tests=0

function run_vim_test {
  echo "Running $1"
  if ! (set -e && cd "$DOTS/nvim/tests" && nvim --headless -c "source $DOTS/nvim/tests/test-support.vim" -c "source $DOTS/nvim/tests/$1" -c "call RunTest()"); then
    echo "error: test $1 failed"
    ((failed_tests+=1))
  fi
}

echo "Check that plugins are installed"
run_vim_test editorconfig.test.vim
# TODO(kaihowl) flaky (various tests)
# run_vim_test fzf-git.test.vim
if [[ $DOTFILES_PROFILE != minimal ]]; then
  run_vim_test completion.test.vim
  run_vim_test lsp-completion-cpp.test.vim
  run_vim_test lsp-completion-rust.test.vim
fi
run_vim_test lsp-completion-python.test.vim
# TODO(kaihowl)
# run_vim_test lsp-efm.test.vim
run_vim_test nvim-cmp-select-enter.test.vim
run_vim_test restorecurpos.test.vim
run_vim_test sanitizer-errorformat.test.vim
run_vim_test sneak.test.vim
run_vim_test tagbar.test.vim
run_vim_test t_comment.test.vim
run_vim_test asyncrun-errorformat.test.vim
run_vim_test asynctasks.test.vim

if [[ $failed_tests -ne 0 ]]; then
  echo "Found $failed_tests test(s)"
  exit 1
fi

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
