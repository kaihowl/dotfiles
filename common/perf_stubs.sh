#!/bin/bash
set -e

if [ -n "$DOTS_PERF_EXPORTED" ]; then
  return 0;
fi

function add_measurement() {
  /usr/bin/true
}

function run_measurement {
  /usr/bin/true
}

function audit_measurements {
  /usr/bin/true
}

function publish_measurements {
  /usr/bin/true
}

# Make functions available in called bash scripts as well
export -f add_measurement
export -f run_measurement
export -f audit_measurements
export -f publish_measurements

export DOTS_PERF_EXPORTED=true
