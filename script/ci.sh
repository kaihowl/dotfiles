#!/bin/bash

function decorate() {
  sed \
    -e 's/^.*deprecat.*$/::warning:: &/' \
    -e 's/^.*warning.*$/::warning:: &/' \
    -e 's/^.*error.*$/::error:: &/'
}

./script/bootstrap 2>&1 | decorate
./script/install 2>&1 | decorate
# There is no actual error to silence. This is a parsing error due to the file name "test".
# shellcheck disable=SC2266
./script/test 2>&1 | decorate
