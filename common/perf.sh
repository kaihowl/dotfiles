#!/bin/bash
set -e

export PATH=~/.local/bin:$PATH
python3 -m pip install git+https://github.com/kaihowl/git-perf.git@latest

function add_measurement {
  if [[ $# -ne 2 ]]; then
    echo "Expected name and value for add_measurement"
    false
  fi

  name=$1
  value=$2

  git perf add -m "$name" -kv "os=${RUNNER_OS}" "$value"
}

function run_measurement {
  echo $#
  if [[ $# -lt 2 ]]; then
    echo "Expected name and command for run_measurement"
    false
  fi

  name=$1
  git perf measure -n 10 -m "$name" -kv "os=${RUNNER_OS}" -- "${@:2}"
}

function publish_measurements {
  git perf push
}

# Make functions available in called bash scripts as well
export -f add_measurement
export -f run_measurement
export -f publish_measurements

export DOTS_PERF_EXPORTED=true
