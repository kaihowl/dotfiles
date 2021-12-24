#!/bin/zsh -i
set -e
set -x

echo "Check if zoxide is on path"
which zoxide

echo "Check if zoxide is user-installed one"
actual_path=$(realpath "$(which zoxide)")
if [[ "${actual_path}" != $(realpath ~/.zoxide/)* ]]; then
  echo "Actual Path: $actual_path"
  echo Expected to be in ~/.zoxide/ instead
  exit 1
fi

echo "Check if zoxide manpages are installed"
man_page=$(man -w zoxide)
if [[ "${man_page}" != $(realpath ~/.zoxide/man)* ]]; then
  echo "Actual manpage path: ${man_page}"
  echo Expect to be in ~/.zoxide/man instead
  exit 1
fi

echo "Check zoxide behavior"
my_dir=$(mktemp -d)
export _ZO_DATA_DIR=$my_dir
trap 'rm -rf ${my_dir}' EXIT

mkdir -p "${my_dir}/stuff"
cd "${my_dir}/stuff"
cd ..

# Jump in subshell to capture output
out=$(j stuff)
if [[ $out != *'stuff'* ]]; then
  echo "Expected jumped-to directory in output"
  echo "Instead only have output='$output'"
  exit 1
fi

# Actually jump
j stuff
if [[ $(pwd) != "${my_dir}/stuff" ]]; then
  echo "Expected to have jumped to ${my_dir}/stuff"
  echo "But actually pwd = $(pwd)"
  exit 1
fi

cd "${my_dir}"
j StuFF
newdir="$(pwd)"
expected_dir="${my_dir}/stuff"
if [[ ${newdir:u} != "${expected_dir:u}" ]]; then
  echo "Expected to have jumped to ${my_dir}/stuff with query 'StuFF'"
  echo "But actually pwd = $(pwd)"
  exit 1
fi

cd "${my_dir}"
rm -rf "${my_dir}/stuff"
j stuff
if [[ $(pwd) != "${my_dir}" ]]; then
  echo "Expected to still be in ${my_dir}"
  echo "But actually pwd = $(pwd)"
  exit 1
fi
