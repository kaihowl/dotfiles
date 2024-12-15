#!/bin/bash

set -e

function identity() {
  "$@"
}

if [[ $(uname) == *Darwin* ]]; then
  word_begin="[[:<:]]"
  word_end="[[:>:]]"
  # Use line buffering
  less_buffering="-l"
  # Do not use stdbuf (not available by default, not needed so far.)
  stdbuf=(identity)
else
  word_begin="\b"
  word_end="\b"
  # Do not buffer
  less_buffering="-u"
  stdbuf=(stdbuf -oL -eL)
fi

function decorate() {
  # Since BSD sed has no case-insensitive matching, spell it out. Perl was not
  # a proper replacement for cross-platform handling, as it was not immediately
  # obvious how to turn the buffering off.
  sed "${less_buffering}" \
    -e "s/^.*${word_begin}[dD][eE][pP][rR][eE][cC][aA][tT].*$/::notice:: &/" \
    -e "s/^.*${word_begin}[wW][aA][rR][nN][iI][nN][gG]${word_end}.*$/::warning:: &/" \
    -e "s/^.*${word_begin}[eE][rR][rR][oO][rR]${word_end}.*$/::error:: &/"
}

source common/perf.sh
CI_START=$(date +%s)

INSTALL_START=$(date +%s)
"${stdbuf[@]}" ./script/bootstrap > >(decorate) 2>&1
INSTALL_END=$(date +%s)
INSTALL_DURATION=$((INSTALL_END - INSTALL_START))
add_measurement install $INSTALL_DURATION

./script/versions.sh versions.txt

TEST_START=$(date +%s)
"${stdbuf[@]}" ./script/test > >(decorate) 2>&1
TEST_END=$(date +%s)
TEST_DURATION=$((TEST_END - TEST_START))
add_measurement test $TEST_DURATION

run_measurement nvim ~/.nix-profile/bin/nvim +qall
run_measurement zsh ~/.nix-profile/bin/zsh -i -c 'exit'

CI_END=$(date +%s)
CI_DURATION=$((CI_END - CI_START))

add_measurement ci $CI_DURATION

publish_measurements

audit_failed=false

if ! audit_measurements nvim; then
  echo "nvim audit failed"
  audit_failed=true
fi

if ! audit_measurements zsh; then
  echo "zsh audit failed"
  audit_failed=true
fi

if ! audit_measurements ci; then
  echo "ci audit failed"
  audit_failed=true
fi

if ! audit_measurements test; then
  echo "test audit failed"
  audit_failed=true
fi

if ! audit_measurements nix-closure-size; then
  echo "nix audit failed"
  audit_failed=true
fi

if [[ $audit_failed = true ]]; then
  echo "at least one perf audit failed"
  exit 1
fi

