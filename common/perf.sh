#!/bin/bash
set -e

function add_measurement {
  # Needed as the -e is not preserved in _called_ scripts
  set -e

  if [[ $# -ne 2 ]]; then
    echo "Expected name and value for add_measurement"
    false
  fi

  name=$1
  value=$2

  git perf add -m "$name" -k "os=${VERSION_RUNNER_OS}" "$value"
}

function run_measurement {
  # Needed as the -e is not preserved in _called_ scripts
  set -e

  echo $#
  if [[ $# -lt 2 ]]; then
    echo "Expected name and command for run_measurement"
    false
  fi

  name=$1
  git perf measure -n 10 -m "$name" -k "os=${VERSION_RUNNER_OS}" -- "${@:2}"
}

function publish_measurements {
  # Needed as the -e is not preserved in _called_ scripts
  set -e

  git perf push
}

# Make functions available in called bash scripts as well
export -f add_measurement
export -f run_measurement
export -f publish_measurements

export DOTS_PERF_EXPORTED=true
