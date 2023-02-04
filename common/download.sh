#!/bin/bash
set -e

cachedir=~/.dotfile-binary-cache

mkdir -p "${cachedir}"

# Download file from url and store under name in cache if not yet present.
# Verify integrity with sha256 sum
function cache_file() {
  file_name=$1
  file_url=$2
  file_hash=$3

  cache_file=$(cache_path "${file_name}")

  if ! [ -f "${cache_file}" ]; then
    curl -Lo "${cache_file}" "${file_url}"
  else
    echo File already exists, skipping download.
  fi

  actual_hash="$(shasum -a 256 "$(cache_path "${file_name}")" | cut -d' ' -f 1)"
  if [[ "$file_hash" != "$actual_hash" ]]; then
    echo "shasum mismatch for ${file_name}. Aborting."
    exit 1
  fi
}

# Return the path of the cached file
function cache_path() {
  filename=$1
  echo "${cachedir}/${filename}"
}
