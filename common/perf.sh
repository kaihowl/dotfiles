#!/bin/bash
set -e

mkdir -p ~/.git-perf/
pushd ~/.git-perf
if [ "$(uname)" == "Darwin" ]; then
  curl -L https://github.com/kaihowl/git-perf/releases/download/0.0.2/gitperf-0.0.2-x86_64-apple-darwin.tar.gz | tar -xz --strip-components=1
elif [[ "$(lsb_release -i)" == *"Ubuntu"* ]]; then
  curl -L https://github.com/kaihowl/git-perf/releases/download/0.0.2/gitperf-0.0.2-x86_64-unknown-linux-musl.tar.gz | tar -xz --strip-components=1
fi
popd

function add_measurement {
  if [[ $# -ne 2 ]]; then
    echo "Expected name and value for add_measurement"
    false
  fi

  name=$1
  value=$2

  ~/.git-perf/git-perf add -m "$name" -k "os=${VERSION_RUNNER_OS}" "$value"
}

function run_measurement {
  echo $#
  if [[ $# -lt 2 ]]; then
    echo "Expected name and command for run_measurement"
    false
  fi

  name=$1
  ~/.git-perf/git-perf measure -n 10 -m "$name" -k "os=${VERSION_RUNNER_OS}" -- "${@:2}"
}

function publish_measurements {
  ~/.git-perf/git-perf push
}

# Make functions available in called bash scripts as well
export -f add_measurement
export -f run_measurement
export -f publish_measurements

export DOTS_PERF_EXPORTED=true
