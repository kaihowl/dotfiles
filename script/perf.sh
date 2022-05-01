#!/bin/zsh -i

set -e
set -x
export PATH=~/.local/bin:$PATH
python3 -m pip install git+https://github.com/kaihowl/git-perf.git@latest

git perf measure -n 10 -kv "os=${RUNNER_OS}" -m nvim -- nvim +qall
git perf measure -n 10 -kv "os=${RUNNER_OS}" -m zsh -- zsh -i -c 'exit'
git perf push

set +e
git perf audit -n 40 -m nvim -s "os=${RUNNER_OS}"
nvim_exit=$?
git perf audit -n 40 -m zsh -s "os=${RUNNER_OS}"
zsh_exit=$?

if [[ $zsh_exit -ne 0 ]] || [[ $nvim_exit -ne 0 ]]; then
  echo $zsh_exit
  echo $nvim_exit
  exit 1
fi
