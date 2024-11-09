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

# Replace a given pattern in a file with the given replacement.
# Args:
#   - file
#   - search (partial line)
#   - replacement (full line)
# If the line does not exist, append it.
# If the line existed, move it to the end of the file.
function sed_replace_in_file() {
  target_file=$1
  search=$2
  replacement=$3
  # Not using in place editing as macOS and GNU sed
  # have incompatible -i options.
  touch "${target_file}"
  tempfile=$(mktemp)
  trap 'rm -rf ${tempfile}' EXIT
  sed "/${search}/d" "${target_file}" > "${tempfile}"
  echo "${replacement}" >> "${tempfile}"
  mv "${tempfile}" "${target_file}"
}
