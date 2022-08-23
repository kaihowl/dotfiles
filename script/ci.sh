#!/bin/bash

set -e
set -x

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
    -e "s/^.*${word_begin}[dD]eprecat.*$/::notice:: &/" \
    -e "s/^.*${word_begin}[wW]arning${word_end}.*$/::warning:: &/" \
    -e "s/^.*${word_begin}[eE]rror${word_end}.*$/::error:: &/"
}

source common/perf.sh
CI_START=$(date +%s)

"${stdbuf[@]}" ./script/bootstrap > >(decorate) 2>&1

INSTALL_START=$(date +%s)
"${stdbuf[@]}" ./script/install > >(decorate) 2>&1
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

set +e
git perf audit -n 40 -m nvim -s "os=${RUNNER_OS}"
nvim_exit=$?
git perf audit -n 40 -m zsh -s "os=${RUNNER_OS}"
zsh_exit=$?
git perf audit -n 40 -m ci -s "os=${RUNNER_OS}"
ci_exit=$?
set -e

if [[ $zsh_exit -ne 0 ]] || [[ $nvim_exit -ne 0 ]] || [[ $ci_exit -ne 0 ]]; then
  echo $zsh_exit
  echo $nvim_exit
  echo $ci_exit
  exit 1
fi

