#!/bin/bash

function version_less_than() {
  actual_version=$1
  expected_min_version=$2

  ! [[ "$(sort -V <(printf "%s\n%s" "$actual_version" "$expected_min_version") | head -n 1)" == "$expected_min_version" ]]
  return $?
}

function darwin_version() {
  sw_vers -productVersion
}
