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

if [ -z $GIT_PERF_DISABLED ]; then
  source common/perf.sh
fi

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

source nvim/path.zsh
run_measurement nvim nvim +qall
run_measurement zsh zsh -i -c 'exit'

CI_END=$(date +%s)
CI_DURATION=$((CI_END - CI_START))

add_measurement ci $CI_DURATION

publish_measurements

if [ -z $GIT_PERF_DISABLED ]; then
  set +e
  git perf audit -n 40 -m nvim -s "os=${VERSION_RUNNER_OS}" --min-measurements 10
  nvim_exit=$?
  git perf audit -n 40 -m zsh -s "os=${VERSION_RUNNER_OS}" --min-measurements 10
  zsh_exit=$?
  git perf audit -n 40 -m ci -s "os=${VERSION_RUNNER_OS}" --min-measurements 10
  ci_exit=$?
  set -e
fi

if [[ $zsh_exit -ne 0 ]] || [[ $nvim_exit -ne 0 ]] || [[ $ci_exit -ne 0 ]]; then
  echo "zsh: $zsh_exit"
  echo "nvim: $nvim_exit"
  echo "ci: $ci_exit"
  exit 1
fi

