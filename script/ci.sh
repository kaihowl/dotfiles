#!/bin/bash

if [[ $(uname) == *Darwin* ]]; then
  word_begin="[[:<:]]"
  word_end="[[:>:]]"
  # Use line buffering
  less_buffering="-l"
  # Do not use stdbuf (not available by default, not needed so far.)
  stdbuf=()
else
  word_begin="\b"
  word_end="\b"
  # Do not buffer
  less_buffering="-u"
  stdbuf=(stdbuf -oL -eL)
fi

function decorate() {
  sed "${less_buffering}" \
    -e "s/^.*${word_begin}deprecat.*$/::info:: &/" \
    -e "s/^.*${word_begin}warning${word_end}.*$/::warning:: &/" \
    -e "s/^.*${word_begin}error${word_end}.*$/::error:: &/"
}

"${stdbuf[@]}" ./script/bootstrap > >(decorate) 2>&1
"${stdbuf[@]}" ./script/install > >(decorate) 2>&1
"${stdbuf[@]}" ./script/test > >(decorate) 2>&1
