#!/bin/bash

if [[ $(uname) == *Darwin* ]]; then
  word_begin="[[:<:]]"
  word_end="[[:>:]]"
  # Use line buffering
  less_buffering="-l"
else
  word_begin="\b"
  word_end="\b"
  # Do not buffer
  less_buffering="-u"
fi

function decorate() {
  sed "${less_buffering}" \
    -e "s/^.*${word_begin}deprecat.*$/::info:: &/" \
    -e "s/^.*${word_begin}warning${word_end}.*$/::warning:: &/" \
    -e "s/^.*${word_begin}error${word_end}.*$/::error:: &/"
}

./script/bootstrap 2>&1 | decorate
./script/install 2>&1 | decorate
# There is no actual error to silence. This is a parsing error due to the file name "test".
# shellcheck disable=SC2266
./script/test 2>&1 | decorate
