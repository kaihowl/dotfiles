#!/bin/bash

if [[ $(uname) == *Darwin* ]]; then
  word_end="[[:>:]]"
  # Use line buffering
  less_buffering="-l"
else
  word_end="\b"
  # Do not buffer
  less_buffering="-u"
fi

function decorate() {
  sed "${less_buffering}" \
    -e "s/^.*deprecat.*$/::info:: &/" \
    -e "s/^.*warning${word_end}.*$/::warning:: &/" \
    -e "s/^.*error${word_end}.*$/::error:: &/"
}

./script/bootstrap 2>&1 | decorate
./script/install 2>&1 | decorate
# There is no actual error to silence. This is a parsing error due to the file name "test".
# shellcheck disable=SC2266
./script/test 2>&1 | decorate
