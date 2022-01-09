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

stdbuf -oL -eL ./script/bootstrap > >(decorate) 2>&1
stdbuf -oL -eL ./script/install > >(decorate) 2>&1
stdbuf -oL -eL ./script/test > >(decorate) 2>&1
